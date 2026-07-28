import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_app/core/services/obd_connection_service.dart';
import 'package:rapid_app/features/bluetooth/presentation/screens/bloc/bluetooth_bloc.dart';

class MockObdConnectionService extends ObdConnectionService {
  bool permissionsGranted = true;
  bool btOn = true;

  @override
  Future<bool> requestPermissions() async => permissionsGranted;

  @override
  Future<bool> isBluetoothOn() async => btOn;

  @override
  Future<void> startScan({Duration timeout = const Duration(seconds: 12)}) async {}
}

void main() {
  group('BluetoothBloc Tests', () {
    late MockObdConnectionService mockService;
    late BluetoothBloc bloc;

    setUp(() {
      mockService = MockObdConnectionService();
      bloc = BluetoothBloc(mockService);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is BluetoothInitial', () {
      expect(bloc.state, isA<BluetoothInitial>());
    });

    test('Emits BluetoothPermissionDenied when permissions are not granted', () async {
      mockService.permissionsGranted = false;
      bloc.add(StartSearch());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BluetoothPermissionDenied>(),
        ]),
      );
    });

    test('Emits BluetoothError when Bluetooth is turned off', () async {
      mockService.permissionsGranted = true;
      mockService.btOn = false;
      bloc.add(StartSearch());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BluetoothError>(),
        ]),
      );
    });
  });
}
