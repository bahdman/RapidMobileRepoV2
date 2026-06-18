import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:rapid_app/core/services/obd_service.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class BluetoothEvent extends Equatable {
  const BluetoothEvent();
  @override
  List<Object?> get props => [];
}

/// Begin BLE scan for nearby OBD adapters.
class StartSearch extends BluetoothEvent {}

/// Stop BLE scan.
class StopSearch extends BluetoothEvent {}

/// User picked a device from the list.
class DeviceSelected extends BluetoothEvent {
  final BluetoothDevice device;
  const DeviceSelected(this.device);
  @override
  List<Object?> get props => [device];
}

/// Internal: BLE scan results updated.
class _ScanResultsUpdated extends BluetoothEvent {
  final List<BluetoothDevice> devices;
  const _ScanResultsUpdated(this.devices);
  @override
  List<Object?> get props => [devices];
}

// ── Domain model ─────────────────────────────────────────────────────────────

/// Lightweight device model used across UI layers.
class BluetoothDevice extends Equatable {
  final String id;
  final String name;

  /// The underlying flutter_blue_plus device — kept for connection later.
  final fbp.BluetoothDevice nativeDevice;

  const BluetoothDevice({
    required this.id,
    required this.name,
    required this.nativeDevice,
  });

  @override
  List<Object?> get props => [id];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class BluetoothState extends Equatable {
  const BluetoothState();
  @override
  List<Object?> get props => [];
}

class BluetoothInitial extends BluetoothState {}

class BluetoothSearching extends BluetoothState {}

class BluetoothDevicesFound extends BluetoothState {
  final List<BluetoothDevice> devices;
  const BluetoothDevicesFound(this.devices);
  @override
  List<Object?> get props => [devices];
}

class BluetoothConnecting extends BluetoothState {
  final BluetoothDevice device;
  const BluetoothConnecting(this.device);
  @override
  List<Object?> get props => [device];
}

class BluetoothConnected extends BluetoothState {
  final BluetoothDevice device;
  const BluetoothConnected(this.device);
  @override
  List<Object?> get props => [device];
}

class BluetoothError extends BluetoothState {
  final String message;
  const BluetoothError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final ObdService _obd = ObdService.instance;
  StreamSubscription<List<fbp.ScanResult>>? _scanSub;

  BluetoothBloc() : super(BluetoothInitial()) {
    on<StartSearch>(_onStartSearch);
    on<StopSearch>(_onStopSearch);
    on<DeviceSelected>(_onDeviceSelected);
    on<_ScanResultsUpdated>(_onScanResultsUpdated);
  }

  // ── Handlers ────────────────────────────────────────────────────────────

  Future<void> _onStartSearch(
    StartSearch event,
    Emitter<BluetoothState> emit,
  ) async {
    emit(BluetoothSearching());

    // Cancel any existing subscription before starting fresh.
    await _scanSub?.cancel();

    try {
      // Subscribe to scan results BEFORE starting the scan.
      _scanSub = _obd.scanResults.listen((results) {
        final devices = results
            .where((r) => r.device.platformName.isNotEmpty)
            .map(
              (r) => BluetoothDevice(
                id: r.device.remoteId.str,
                name: r.device.platformName,
                nativeDevice: r.device,
              ),
            )
            .toList();

        if (!isClosed) {
          add(_ScanResultsUpdated(devices));
        }
      });

      await _obd.startScan(timeout: const Duration(seconds: 12));
    } catch (e) {
      emit(BluetoothError('Scan failed: $e'));
    }
  }

  void _onScanResultsUpdated(
    _ScanResultsUpdated event,
    Emitter<BluetoothState> emit,
  ) {
    if (event.devices.isNotEmpty) {
      emit(BluetoothDevicesFound(event.devices));
    }
  }

  Future<void> _onStopSearch(
    StopSearch event,
    Emitter<BluetoothState> emit,
  ) async {
    await _scanSub?.cancel();
    _scanSub = null;
    await _obd.stopScan();
  }

  Future<void> _onDeviceSelected(
    DeviceSelected event,
    Emitter<BluetoothState> emit,
  ) async {
    // Stop scan so we don't waste BLE bandwidth during connection.
    await _scanSub?.cancel();
    _scanSub = null;
    await _obd.stopScan();

    emit(BluetoothConnecting(event.device));
    try {
      await _obd.connectToDevice(event.device.nativeDevice);
      emit(BluetoothConnected(event.device));
    } catch (e) {
      emit(BluetoothError('Connection failed: $e'));
    }
  }

  @override
  Future<void> close() async {
    await _scanSub?.cancel();
    return super.close();
  }
}
