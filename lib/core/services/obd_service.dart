import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:obd2/obd2.dart';

/// Telemetry snapshot emitted during an active scan session.
class ObdTelemetrySnapshot {
  final double? rpm;
  final double? speedKmh;
  final double? coolantTempC;
  final double? engineLoadPct;
  final double? throttlePct;
  final double? fuelLevelPct;
  final double? intakeTempC;

  const ObdTelemetrySnapshot({
    this.rpm,
    this.speedKmh,
    this.coolantTempC,
    this.engineLoadPct,
    this.throttlePct,
    this.fuelLevelPct,
    this.intakeTempC,
  });

  ObdTelemetrySnapshot copyWith({
    double? rpm,
    double? speedKmh,
    double? coolantTempC,
    double? engineLoadPct,
    double? throttlePct,
    double? fuelLevelPct,
    double? intakeTempC,
  }) {
    return ObdTelemetrySnapshot(
      rpm: rpm ?? this.rpm,
      speedKmh: speedKmh ?? this.speedKmh,
      coolantTempC: coolantTempC ?? this.coolantTempC,
      engineLoadPct: engineLoadPct ?? this.engineLoadPct,
      throttlePct: throttlePct ?? this.throttlePct,
      fuelLevelPct: fuelLevelPct ?? this.fuelLevelPct,
      intakeTempC: intakeTempC ?? this.intakeTempC,
    );
  }
}

/// Result of a full OBD diagnostic scan.
class ObdScanResult {
  /// List of raw DTC strings (e.g. ['P0420', 'P0171']).
  final List<String> dtcCodes;

  /// Health score computed from the number and severity of DTCs (0–100).
  final int healthScore;

  /// Last telemetry snapshot captured during the scan.
  final ObdTelemetrySnapshot telemetry;

  const ObdScanResult({
    required this.dtcCodes,
    required this.healthScore,
    required this.telemetry,
  });
}

/// Service that manages BLE device discovery and OBD-II protocol communication.
///
/// Usage:
/// ```dart
/// final service = ObdService();
/// await service.startScan();
/// service.foundDevices.listen((devices) { ... });
/// await service.connectToDevice(device);
/// final result = await service.runDiagnosticScan(onProgress: (p) { ... });
/// await service.disconnect();
/// ```
class ObdService {
  ObdService._();
  static final ObdService instance = ObdService._();

  BluetoothAdapterOBD2? _adapter;
  BluetoothDevice? _connectedDevice;

  // ── BLE Scan ─────────────────────────────────────────────────────────────

  /// Stream of nearby BLE devices found during a scan.
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  bool get isScanning => FlutterBluePlus.isScanningNow;

  /// Begins a BLE scan for up to [timeout] seconds.
  /// Results are emitted via [scanResults].
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
    // license: '' = non-commercial / personal use (flutter_blue_plus 2.x requirement).
    await FlutterBluePlus.startScan(timeout: timeout);

  }

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  // ── Connection ────────────────────────────────────────────────────────────

  bool get isConnected => _connectedDevice != null;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Connects to a BLE [device] and initialises the ELM327 OBD adapter.
  Future<void> connectToDevice(BluetoothDevice device) async {
    // License.nonprofit = non-commercial / personal use (flutter_blue_plus 2.x requirement).
    await device.connect(
      timeout: const Duration(seconds: 15),
      license: License.nonprofit,
    );
    _connectedDevice = device;
    _adapter = BluetoothAdapterOBD2();
    await _adapter!.connect(device);
  }

  /// Disconnects from the current device and cleans up resources.
  Future<void> disconnect() async {
    try {
      await _adapter?.disconnect();
      await _connectedDevice?.disconnect();
    } finally {
      _adapter = null;
      _connectedDevice = null;
    }
  }

  // ── Diagnostic Scan ───────────────────────────────────────────────────────

  /// Runs a full diagnostic scan:
  ///   1. Detects which telemetry PIDs the adapter supports.
  ///   2. Streams live telemetry while reporting progress via [onProgress].
  ///   3. Reads all stored DTCs.
  ///   4. Returns an [ObdScanResult].
  ///
  /// [onProgress] receives values from 0.0 to 1.0.
  Future<ObdScanResult> runDiagnosticScan({
    required void Function(double progress) onProgress,
    Duration scanDuration = const Duration(seconds: 12),
  }) async {
    if (_adapter == null) {
      throw StateError('ObdService: not connected to any device.');
    }

    final protocol = _adapter!.protocol;
    ObdTelemetrySnapshot snapshot = const ObdTelemetrySnapshot();

    // ── Phase 1: Detect supported PIDs (0–30%) ────────────────────────────
    onProgress(0.05);
    final supported = await protocol.telemetry.detectSupportedTelemetry();
    onProgress(0.30);

    // Build PID list from what the ECU actually supports.
    final pids = <DetailedPID>[
      if (supported.contains(Telemetry.rpm)) Telemetry.rpm,
      if (supported.contains(Telemetry.speed)) Telemetry.speed,
      if (supported.contains(Telemetry.coolantTemperature))
        Telemetry.coolantTemperature,
      if (supported.contains(Telemetry.engineLoad)) Telemetry.engineLoad,
      if (supported.contains(Telemetry.throttlePosition))
        Telemetry.throttlePosition,
      if (supported.contains(Telemetry.fuelLevel)) Telemetry.fuelLevel,
      if (supported.contains(Telemetry.intakeAirTemperature))
        Telemetry.intakeAirTemperature,
    ];

    // ── Phase 2: Stream telemetry for scanDuration (30–75%) ───────────────
    final progressCompleter = Completer<void>();
    final elapsed = Stopwatch()..start();
    final totalMs = scanDuration.inMilliseconds.toDouble();

    TelemetrySession? session;
    if (pids.isNotEmpty) {
      session = protocol.telemetry.stream(
        detailedPIDs: pids,
        onData: (TelemetryData data) {
          snapshot = ObdTelemetrySnapshot(
            rpm: data.get(Telemetry.rpm) as double?,
            speedKmh: data.get(Telemetry.speed) as double?,
            coolantTempC: data.get(Telemetry.coolantTemperature) as double?,
            engineLoadPct: data.get(Telemetry.engineLoad) as double?,
            throttlePct: data.get(Telemetry.throttlePosition) as double?,
            fuelLevelPct: data.get(Telemetry.fuelLevel) as double?,
            intakeTempC: data.get(Telemetry.intakeAirTemperature) as double?,
          );

          final telemetryProgress = (elapsed.elapsedMilliseconds / totalMs).clamp(0.0, 1.0);
          onProgress(0.30 + telemetryProgress * 0.45); // 30% → 75%

          if (elapsed.elapsedMilliseconds >= totalMs && !progressCompleter.isCompleted) {
            progressCompleter.complete();
          }
        },
      );

      // Safety timeout in case onData never fires enough times.
      await Future.any([
        progressCompleter.future,
        Future.delayed(scanDuration + const Duration(seconds: 3)),
      ]);
      session.stop();
    }

    onProgress(0.75);

    // ── Phase 3: Read DTCs (75–95%) ───────────────────────────────────────
    List<String> dtcCodes = [];
    try {
      final readCodes = ReadCodes(_adapter!);
      final rawCodes = await readCodes.getDTCs();
      dtcCodes = rawCodes.map((e) => e.toString()).toList();
    } catch (_) {
      // Some adapters/vehicles may not support Mode 03 — continue gracefully.
    }
    onProgress(0.95);

    // ── Phase 4: Compute health score ─────────────────────────────────────
    final healthScore = _computeHealthScore(dtcCodes);
    onProgress(1.0);

    return ObdScanResult(
      dtcCodes: dtcCodes,
      healthScore: healthScore,
      telemetry: snapshot,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Simple health score formula:
  ///   Start at 100. Each DTC deducts points based on known severity prefixes.
  ///   P0xxx (powertrain) = -15, C0xxx (chassis) = -12, B1xxx (body) = -8,
  ///   U0xxx (network) = -10, unknown = -10.
  int _computeHealthScore(List<String> codes) {
    int score = 100;
    for (final code in codes) {
      final prefix = code.isNotEmpty ? code[0].toUpperCase() : '';
      switch (prefix) {
        case 'P':
          score -= 15;
        case 'C':
          score -= 12;
        case 'B':
          score -= 8;
        case 'U':
          score -= 10;
        default:
          score -= 10;
      }
    }
    return score.clamp(0, 100);
  }
}
