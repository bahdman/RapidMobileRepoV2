import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rapid_app/core/services/obd_connection_service.dart';

// ── Re-export ObdAdapter as the "BluetoothDevice" type the UI already uses ───
// This keeps the existing screens working with zero UI changes.
typedef BluetoothDevice = ObdAdapter;

// ── Events ────────────────────────────────────────────────────────────────────

abstract class BluetoothEvent extends Equatable {
  const BluetoothEvent();
  @override
  List<Object?> get props => [];
}

class StartSearch extends BluetoothEvent {
  final bool isWifiOnly;
  const StartSearch({this.isWifiOnly = false});

  @override
  List<Object?> get props => [isWifiOnly];
}

class DeviceSelected extends BluetoothEvent {
  final BluetoothDevice device;
  const DeviceSelected(this.device);
  @override
  List<Object?> get props => [device];
}

class DisconnectDevice extends BluetoothEvent {}

class _AdaptersUpdated extends BluetoothEvent {
  final List<BluetoothDevice> devices;
  const _AdaptersUpdated(this.devices);
  @override
  List<Object?> get props => [devices];
}

class _ConnectionResult extends BluetoothEvent {
  final ObdConnectionEvent event;
  const _ConnectionResult(this.event);
  @override
  List<Object?> get props => [event];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class BluetoothState extends Equatable {
  const BluetoothState();
  @override
  List<Object?> get props => [];
}

class BluetoothInitial extends BluetoothState {}

class BluetoothPermissionDenied extends BluetoothState {}

class BluetoothSearching extends BluetoothState {}

class BluetoothDevicesFound extends BluetoothState {
  final List<BluetoothDevice> devices;
  final bool isScanning;

  const BluetoothDevicesFound(this.devices, {this.isScanning = true});

  @override
  List<Object?> get props => [devices, isScanning];
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

// ── Bloc ──────────────────────────────────────────────────────────────────────

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final ObdConnectionService _connectionService;

  StreamSubscription<List<ObdAdapter>>? _adaptersSub;
  StreamSubscription<ObdConnectionEvent>? _connectionSub;

  BluetoothBloc(this._connectionService) : super(BluetoothInitial()) {
    // Internal events piped from service streams
    on<_AdaptersUpdated>(_onAdaptersUpdated);
    on<_ConnectionResult>(_onConnectionResult);

    // Public events
    on<StartSearch>(_onStartSearch);
    on<DeviceSelected>(_onDeviceSelected);
    on<DisconnectDevice>(_onDisconnect);
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onStartSearch(
    StartSearch event,
    Emitter<BluetoothState> emit,
  ) async {
    if (state is BluetoothConnecting || state is BluetoothConnected) return;

    // 1. Request permissions first
    final granted = await _connectionService.requestPermissions();
    if (!granted) {
      emit(BluetoothPermissionDenied());
      return;
    }

    // 2. Verify radio/network hardware state depending on transport mode
    if (event.isWifiOnly) {
      final isWifiOn = await _connectionService.isWifiConnected();
      if (!isWifiOn) {
        emit(const BluetoothError(
            'Wi-Fi is turned off or disconnected. Please turn on Wi-Fi and connect to your OBD adapter\'s network in settings.'));
        return;
      }
    } else {
      final isBtOn = await _connectionService.isBluetoothOn();
      if (!isBtOn) {
        emit(const BluetoothError(
            'Bluetooth is turned off. Please turn on Bluetooth in your settings to discover OBD adapters.'));
        return;
      }
    }

    emit(BluetoothSearching());

    List<BluetoothDevice> lastDiscovered = [];

    // 3. Subscribe to adapter discovery stream
    await _adaptersSub?.cancel();
    _adaptersSub = _connectionService.adaptersStream.listen((adapters) {
      lastDiscovered = adapters;
      if (!isClosed) add(_AdaptersUpdated(adapters));
    });

    // 4. Subscribe to connection events
    await _connectionSub?.cancel();
    _connectionSub = _connectionService.connectionStream.listen((event) {
      if (!isClosed) add(_ConnectionResult(event));
    });

    // 5. Start scan (returns after timeout or error)
    try {
      await _connectionService.startScan(isWifiOnly: event.isWifiOnly);
    } catch (e) {
      if (!isClosed) emit(BluetoothError(e.toString().replaceAll('Exception: ', '')));
      return;
    }

    // 6. Notify scan stopped
    if (!isClosed && (state is BluetoothSearching || state is BluetoothDevicesFound)) {
      emit(BluetoothDevicesFound(lastDiscovered, isScanning: false));
    }
  }

  void _onAdaptersUpdated(
    _AdaptersUpdated event,
    Emitter<BluetoothState> emit,
  ) {
    // Don't overwrite connecting/connected states
    if (state is BluetoothConnecting || state is BluetoothConnected) return;
    emit(BluetoothDevicesFound(event.devices, isScanning: true));
  }

  Future<void> _onDeviceSelected(
    DeviceSelected event,
    Emitter<BluetoothState> emit,
  ) async {
    emit(BluetoothConnecting(event.device));
    try {
      await _connectionService.connect(event.device);
      // Connection result will come via _connectionSub → _ConnectionResult
    } catch (e) {
      emit(BluetoothError(e.toString()));
    }
  }

  void _onConnectionResult(
    _ConnectionResult event,
    Emitter<BluetoothState> emit,
  ) {
    final e = event.event;
    if (e.isConnected) {
      emit(BluetoothConnected(e.adapter));
    } else if (e.isError) {
      emit(BluetoothError(e.errorMessage ?? 'Connection failed'));
    }
  }

  Future<void> _onDisconnect(
    DisconnectDevice event,
    Emitter<BluetoothState> emit,
  ) async {
    await _connectionService.disconnect();
    emit(BluetoothInitial());
  }

  @override
  Future<void> close() async {
    await _adaptersSub?.cancel();
    await _connectionSub?.cancel();
    return super.close();
  }
}
