import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rapid_app/core/services/api_service.dart';

// Events
abstract class BluetoothEvent extends Equatable {
  const BluetoothEvent();
  @override
  List<Object?> get props => [];
}

class StartSearch extends BluetoothEvent {}

class DeviceSelected extends BluetoothEvent {
  final BluetoothDevice device;
  const DeviceSelected(this.device);
  @override
  List<Object?> get props => [device];
}

// States
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

class BluetoothDevice extends Equatable {
  final String id;
  final String name;
  const BluetoothDevice(this.id, this.name);
  @override
  List<Object?> get props => [id, name];
}

// Bloc
class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final ApiService _apiService;

  BluetoothBloc(this._apiService) : super(BluetoothInitial()) {
    on<StartSearch>((event, emit) async {
      emit(BluetoothSearching());
      // Simulate search delay
      await Future.delayed(const Duration(seconds: 6));
      emit(const BluetoothDevicesFound([BluetoothDevice('1', 'OBD-II')]));
    });

    on<DeviceSelected>((event, emit) async {
      emit(BluetoothConnecting(event.device));
      // Simulate connection delay
      await Future.delayed(const Duration(seconds: 2));
      emit(BluetoothConnected(event.device));
    });
  }
}
