import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// ── Transport types ───────────────────────────────────────────────────────────

enum ObdTransport { ble, wifi }

// ── Discovered device representation ─────────────────────────────────────────

class ObdAdapter {
  final String id;
  final String name;
  final ObdTransport transport;
  /// BLE device reference (null for WiFi)
  final BluetoothDevice? bleDevice;
  /// Signal strength in dBm (null for WiFi)
  final int? rssi;

  const ObdAdapter({
    required this.id,
    required this.name,
    required this.transport,
    this.bleDevice,
    this.rssi,
  });

  bool get isWifi => transport == ObdTransport.wifi;
  bool get isBle => transport == ObdTransport.ble;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ObdAdapter && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ObdAdapter($name [$transport])';
}

// ── ELM327 service / characteristic UUIDs ────────────────────────────────────
// Most BLE OBD-II dongles expose a transparent UART service. Common ones:
//   • Vlink / generic : 0xFFE0 / 0xFFE1
//   • Nordic UART     : 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
//                       TX 6E400002 / RX 6E400003
class _BleUuids {
  // Generic UART (most cheap adapters)
  static const String genericService = '0000ffe0-0000-1000-8000-00805f9b34fb';
  static const String genericChar = '0000ffe1-0000-1000-8000-00805f9b34fb';

  // Nordic UART
  static const String nuartService = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String nuartTx = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';
  static const String nuartRx = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';
}

// ── WiFi constants (standard ELM327 WiFi adapter defaults) ───────────────────
class _WifiDefaults {
  static const String host = '192.168.0.10';
  static const int port = 35000;
}

// ── Service ───────────────────────────────────────────────────────────────────

class ObdConnectionService {
  // BLE state
  StreamSubscription<List<ScanResult>>? _bleScanSub;
  BluetoothDevice? _connectedBleDevice;
  BluetoothCharacteristic? _writeChar;
  BluetoothCharacteristic? _notifyChar;
  StreamSubscription<List<int>>? _bleNotifySub;

  // WiFi state
  Socket? _wifiSocket;

  // Shared response buffer
  final _responseBuffer = StringBuffer();
  Completer<String>? _pendingResponse;

  // Public streams
  final _adaptersController = StreamController<List<ObdAdapter>>.broadcast();
  final _connectionController =
      StreamController<ObdConnectionEvent>.broadcast();

  Stream<List<ObdAdapter>> get adaptersStream => _adaptersController.stream;
  Stream<ObdConnectionEvent> get connectionStream =>
      _connectionController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  ObdAdapter? _activeAdapter;
  ObdAdapter? get activeAdapter => _activeAdapter;

  // ── Permission handling ────────────────────────────────────────────────────

  /// Requests all permissions needed for BLE + WiFi OBD scanning.
  /// Returns true if all required permissions were granted.
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final results = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();
      return results.values.every((s) => s.isGranted);
    } else if (Platform.isIOS) {
      final bt = await Permission.bluetooth.request();
      return bt.isGranted;
    }
    return true;
  }

  /// Checks if Bluetooth adapter is enabled on the device.
  Future<bool> isBluetoothOn() async {
    try {
      if (!await FlutterBluePlus.isSupported) return false;
      final state = await FlutterBluePlus.adapterState.first;
      if (state == BluetoothAdapterState.off) {
        if (Platform.isAndroid) {
          try {
            await FlutterBluePlus.turnOn();
            final updatedState = await FlutterBluePlus.adapterState
                .firstWhere((s) => s != BluetoothAdapterState.turningOn)
                .timeout(const Duration(seconds: 3),
                    onTimeout: () => BluetoothAdapterState.off);
            return updatedState == BluetoothAdapterState.on;
          } catch (_) {
            return false;
          }
        }
        return false;
      }
      return state == BluetoothAdapterState.on;
    } catch (_) {
      return true; // Fallback for unsupported desktop environments
    }
  }

  /// Checks if active local network / Wi-Fi interfaces exist on the device.
  Future<bool> isWifiConnected() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      return interfaces.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ── Scanning ───────────────────────────────────────────────────────────────

  /// Start scanning for BLE or WiFi OBD adapters. Discovered adapters are emitted
  /// on [adaptersStream].
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 12),
    bool isWifiOnly = false,
  }) async {
    final discovered = <ObdAdapter>{};

    if (isWifiOnly) {
      await _probeWifiAdapter(discovered);
      return;
    }

    final btOn = await isBluetoothOn();
    if (!btOn) {
      throw Exception(
          'Bluetooth is turned off. Please turn on Bluetooth in settings to discover OBD adapters.');
    }

    // 1. Probe WiFi adapter (non-blocking)
    _probeWifiAdapter(discovered);

    // 2. BLE scan
    try {
      await FlutterBluePlus.stopScan();
      await _bleScanSub?.cancel();

      _bleScanSub = FlutterBluePlus.onScanResults.listen((results) {
        for (final r in results) {
          final name = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : (r.advertisementData.advName.isNotEmpty
                  ? r.advertisementData.advName
                  : 'Unknown');
          // Filter for OBD/ELM adapters by name heuristic
          if (_isLikelyObdAdapter(name)) {
            discovered.add(
              ObdAdapter(
                id: r.device.remoteId.str,
                name: name,
                transport: ObdTransport.ble,
                bleDevice: r.device,
                rssi: r.rssi,
              ),
            );
            _adaptersController.add(discovered.toList());
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: timeout);
      await Future.delayed(timeout);
      await FlutterBluePlus.stopScan();
      await _bleScanSub?.cancel();
    } catch (e) {
      debugPrint('[OBD] BLE scan error: $e');
    }
  }

  bool _isLikelyObdAdapter(String name) {
    final lower = name.toLowerCase();
    return lower.contains('obd') ||
        lower.contains('elm') ||
        lower.contains('vlink') ||
        lower.contains('carista') ||
        lower.contains('obdii') ||
        lower.contains('scan') ||
        lower.contains('diag');
  }

  Future<void> _probeWifiAdapter(Set<ObdAdapter> discovered) async {
    final targets = [
      {'host': '192.168.0.10', 'port': 35000, 'name': 'Standard Wi-Fi OBD (192.168.0.10)'},
      {'host': '192.168.1.10', 'port': 35000, 'name': 'Vgate / iCar Wi-Fi (192.168.1.10)'},
      {'host': '192.168.0.123', 'port': 35000, 'name': 'Kiwi Wi-Fi OBD (192.168.0.123)'},
      {'host': '192.168.0.10', 'port': 2000, 'name': 'Wi-Fi Serial OBD (Port 2000)'},
      {'host': '192.168.1.1', 'port': 35000, 'name': 'Gateway Wi-Fi OBD (192.168.1.1)'},
    ];

    await Future.wait(targets.map((target) async {
      final host = target['host'] as String;
      final port = target['port'] as int;
      final name = target['name'] as String;
      try {
        final socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(seconds: 2),
        );
        socket.destroy();
        final adapter = ObdAdapter(
          id: 'wifi:$host:$port',
          name: name,
          transport: ObdTransport.wifi,
        );
        discovered.add(adapter);
        _adaptersController.add(discovered.toList());
      } catch (_) {
        // No WiFi adapter at this target IP — ignore
      }
    }));
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _bleScanSub?.cancel();
  }

  // ── Connection ─────────────────────────────────────────────────────────────

  Future<void> connect(ObdAdapter adapter) async {
    _connectionController.add(ObdConnectionEvent.connecting(adapter));
    try {
      if (adapter.isBle) {
        await _connectBle(adapter);
      } else {
        await _connectWifi(adapter);
      }
      _activeAdapter = adapter;
      _isConnected = true;
      await _initElm327();
      _connectionController.add(ObdConnectionEvent.connected(adapter));
    } catch (e) {
      _isConnected = false;
      _connectionController
          .add(ObdConnectionEvent.error(adapter, e.toString()));
      rethrow;
    }
  }

  // ── BLE connection ─────────────────────────────────────────────────────────

  Future<void> _connectBle(ObdAdapter adapter) async {
    final device = adapter.bleDevice!;
    await device.connect(timeout: const Duration(seconds: 15));
    _connectedBleDevice = device;

    // Discover services
    final services = await device.discoverServices();
    _writeChar = null;
    _notifyChar = null;

    for (final service in services) {
      final sUuid = service.uuid.str128.toLowerCase();

      if (sUuid == _BleUuids.genericService) {
        for (final c in service.characteristics) {
          final cUuid = c.uuid.str128.toLowerCase();
          if (cUuid == _BleUuids.genericChar) {
            _writeChar = c;
            _notifyChar = c; // same char for both on generic adapters
          }
        }
      } else if (sUuid == _BleUuids.nuartService) {
        for (final c in service.characteristics) {
          final cUuid = c.uuid.str128.toLowerCase();
          if (cUuid == _BleUuids.nuartTx) _writeChar = c;
          if (cUuid == _BleUuids.nuartRx) _notifyChar = c;
        }
      }
    }

    if (_notifyChar == null || _writeChar == null) {
      throw Exception(
          'OBD UART service not found on this BLE device. '
          'Supported profiles: FFE0/FFE1, Nordic UART');
    }

    // Enable notifications
    await _notifyChar!.setNotifyValue(true);
    _bleNotifySub = _notifyChar!.lastValueStream.listen(_onBleData);
  }

  void _onBleData(List<int> data) {
    final chunk = String.fromCharCodes(data);
    _responseBuffer.write(chunk);
    final buf = _responseBuffer.toString();
    // ELM327 terminates responses with '>'
    if (buf.contains('>')) {
      final response = buf.replaceAll('>', '').trim();
      _responseBuffer.clear();
      _pendingResponse?.complete(response);
      _pendingResponse = null;
    }
  }

  // ── WiFi connection ────────────────────────────────────────────────────────

  Future<void> _connectWifi(ObdAdapter adapter) async {
    String host = _WifiDefaults.host;
    int port = _WifiDefaults.port;
    if (adapter.id.startsWith('wifi:')) {
      final parts = adapter.id.split(':');
      if (parts.length >= 3) {
        host = parts[1];
        port = int.tryParse(parts[2]) ?? _WifiDefaults.port;
      }
    }

    _wifiSocket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 10),
    );
    _wifiSocket!.listen(
      _onWifiData,
      onError: (e) {
        _isConnected = false;
        _connectionController
            .add(ObdConnectionEvent.error(_activeAdapter!, e.toString()));
      },
      onDone: () {
        _isConnected = false;
      },
    );
  }

  void _onWifiData(Uint8List data) {
    final chunk = utf8.decode(data, allowMalformed: true);
    _responseBuffer.write(chunk);
    final buf = _responseBuffer.toString();
    if (buf.contains('>')) {
      final response = buf.replaceAll('>', '').trim();
      _responseBuffer.clear();
      _pendingResponse?.complete(response);
      _pendingResponse = null;
    }
  }

  // ── ELM327 protocol ───────────────────────────────────────────────────────

  /// Initialise the ELM327 chip with standard AT commands.
  Future<void> _initElm327() async {
    await _sendCommand('ATZ', waitMs: 1500);   // Reset
    await _sendCommand('ATE0');                 // Echo off
    await _sendCommand('ATL0');                 // Linefeeds off
    await _sendCommand('ATS0');                 // Spaces off
    await _sendCommand('ATH0');                 // Headers off
    await _sendCommand('ATSP0');               // Auto protocol
  }

  /// Send a raw ELM327 command and await the response string.
  Future<String> _sendCommand(
    String cmd, {
    int waitMs = 800,
    int timeoutMs = 5000,
  }) async {
    _pendingResponse = Completer<String>();
    final bytes = Uint8List.fromList(utf8.encode('$cmd\r'));

    if (_activeAdapter?.isBle == true && _writeChar != null) {
      // BLE write in chunks of 20 bytes (MTU safe)
      for (var i = 0; i < bytes.length; i += 20) {
        final end = (i + 20 > bytes.length) ? bytes.length : i + 20;
        await _writeChar!.write(bytes.sublist(i, end), withoutResponse: true);
        await Future.delayed(const Duration(milliseconds: 20));
      }
    } else if (_wifiSocket != null) {
      _wifiSocket!.add(bytes);
    }

    try {
      return await _pendingResponse!.future.timeout(
        Duration(milliseconds: timeoutMs),
        onTimeout: () => '',
      );
    } finally {
      await Future.delayed(Duration(milliseconds: waitMs));
    }
  }

  // ── OBD PID queries ───────────────────────────────────────────────────────

  /// Returns a list of active DTCs reported by Mode 03.
  /// Returns raw codes like ['P0420', 'P0171'] or empty if none.
  Future<List<String>> readDtcCodes() async {
    if (!_isConnected) throw Exception('Not connected to OBD adapter');

    // Mode 03: Request stored DTCs
    final raw = await _sendCommand('03', timeoutMs: 8000);
    return _parseDtcResponse(raw);
  }

  List<String> _parseDtcResponse(String raw) {
    final codes = <String>[];
    if (raw.isEmpty || raw.contains('NODATA') || raw.contains('NO DATA')) {
      return codes;
    }

    // Clean up whitespace and response headers
    final cleaned = raw
        .replaceAll(RegExp(r'[\r\n]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Each DTC is encoded as 2 bytes. Byte 1 high nibble = category:
    //   0 = P0, 1 = P1, 2 = P2, 3 = P3
    //   4 = C0, 5 = C1, 6 = C2, 7 = C3
    //   8 = B0, 9 = B1, A = B2, B = B3
    //   C = U0, D = U1, E = U2, F = U3
    final hexBytes = cleaned.split(' ').where((s) => s.length == 2).toList();

    // Mode 03 response: 43 <byte pairs for each DTC>
    // Strip the mode byte (43)
    final dtcBytes = hexBytes.skipWhile((b) => b == '43').toList();

    for (var i = 0; i + 1 < dtcBytes.length; i += 2) {
      final hi = int.tryParse(dtcBytes[i], radix: 16) ?? 0;
      final lo = int.tryParse(dtcBytes[i + 1], radix: 16) ?? 0;

      if (hi == 0 && lo == 0) continue; // Padding / no DTC

      final category = (hi >> 6) & 0x03;
      final highNibble = (hi >> 4) & 0x03;
      final prefix = switch (category) {
        0 => 'P',
        1 => 'C',
        2 => 'B',
        _ => 'U',
      };

      final digits =
          '${highNibble.toRadixString(16).toUpperCase()}'
          '${(hi & 0x0F).toRadixString(16).toUpperCase().padLeft(1, '0')}'
          '${lo.toRadixString(16).toUpperCase().padLeft(2, '0')}';

      codes.add('$prefix$digits');
    }

    return codes;
  }

  /// Reads a single OBD Mode 01 PID (e.g. '010C' for RPM).
  /// Returns the raw hex response string.
  Future<String> readPid(String pid) async {
    if (!_isConnected) throw Exception('Not connected to OBD adapter');
    return _sendCommand(pid, timeoutMs: 3000);
  }

  // ── Disconnect ─────────────────────────────────────────────────────────────

  Future<void> disconnect() async {
    _isConnected = false;
    await _bleNotifySub?.cancel();
    await _connectedBleDevice?.disconnect();
    _connectedBleDevice = null;
    _writeChar = null;
    _notifyChar = null;

    _wifiSocket?.destroy();
    _wifiSocket = null;

    _responseBuffer.clear();
    _activeAdapter = null;
  }

  void dispose() {
    disconnect();
    _adaptersController.close();
    _connectionController.close();
  }
}

// ── Connection events ─────────────────────────────────────────────────────────

class ObdConnectionEvent {
  final String _type; // 'connecting' | 'connected' | 'disconnected' | 'error'
  final ObdAdapter adapter;
  final String? errorMessage;

  const ObdConnectionEvent._({
    required String type,
    required this.adapter,
    this.errorMessage,
  }) : _type = type;

  factory ObdConnectionEvent.connecting(ObdAdapter a) =>
      ObdConnectionEvent._(type: 'connecting', adapter: a);

  factory ObdConnectionEvent.connected(ObdAdapter a) =>
      ObdConnectionEvent._(type: 'connected', adapter: a);

  factory ObdConnectionEvent.disconnected(ObdAdapter a) =>
      ObdConnectionEvent._(type: 'disconnected', adapter: a);

  factory ObdConnectionEvent.error(ObdAdapter a, String msg) =>
      ObdConnectionEvent._(type: 'error', adapter: a, errorMessage: msg);

  bool get isConnecting => _type == 'connecting';
  bool get isConnected => _type == 'connected';
  bool get isDisconnected => _type == 'disconnected';
  bool get isError => _type == 'error';
}
