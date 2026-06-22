import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rapid_app/core/theme/app_theme.dart';
import 'package:rapid_app/core/services/api_service.dart';
import 'package:rapid_app/core/services/auth_event_bus.dart';
import 'package:rapid_app/core/services/obd_service.dart';
import 'package:rapid_app/core/services/device_service.dart';
import 'package:rapid_app/core/services/user_service.dart';
import 'package:rapid_app/core/services/schedule_service.dart';
import 'package:rapid_app/core/utils/shared_prefs_helper.dart';
import 'package:rapid_app/features/notifications/presentation/screens/bloc/notification_bloc.dart';
import 'package:rapid_app/features/bluetooth/presentation/screens/bloc/bluetooth_bloc.dart';
import 'package:rapid_app/features/bluetooth/presentation/screens/bloc/obd_scan_bloc.dart';
import 'package:rapid_app/core/services/obd_connection_service.dart';
import 'package:rapid_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rapid_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:rapid_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rapid_app/route_names.dart';
import 'package:rapid_app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final sharedPrefsHelper = SharedPrefsHelper(prefs);
  final apiService = ApiService(sharedPrefsHelper);
  final obdService = ObdService(apiService);
  final obdConnectionService = ObdConnectionService();
  final deviceService = DeviceService(apiService);
  final userService = UserService(apiService);
  final scheduleService = ScheduleService(apiService);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final router = buildRouter('/${AppRoutes.splash}');

  // Auth Dependencies
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiService);
  final AuthRepository authRepository = AuthRepositoryImpl(authRemoteDataSource);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: sharedPrefsHelper),
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: obdService),
        RepositoryProvider.value(value: obdConnectionService),
        RepositoryProvider.value(value: deviceService),
        RepositoryProvider.value(value: userService),
        RepositoryProvider.value(value: scheduleService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => NotificationBloc(apiService)),
          BlocProvider(
            create: (context) => BluetoothBloc(obdConnectionService),
          ),
          BlocProvider(
            create: (context) =>
                ObdScanBloc(obdService, obdConnectionService),
          ),
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository, sharedPrefsHelper),
          ),
        ],
        child: MainApp(router: router),
      ),
    ),
  );
}

class MainApp extends StatefulWidget {
  final dynamic router;
  const MainApp({super.key, required this.router});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final StreamSubscription<AuthEvent> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = AuthEventBus.instance.stream.listen(_onAuthEvent);
  }

  void _onAuthEvent(AuthEvent event) {
    if (event == AuthEvent.sessionExpired) {
      // Navigate to the auth screen, clearing the entire stack.
      // GoRouter.go replaces the entire navigation stack.
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null) {
        GoRouter.of(ctx).go('/${AppRoutes.auth}');
      }

      // Show a non-blocking dialog on top of the auth screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = rootNavigatorKey.currentContext;
        if (ctx == null) return;
        showDialog<void>(
          context: ctx,
          barrierDismissible: false,
          builder: (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Session Expired',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: const Text(
              'Your session has expired. Please log in again to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          routerConfig: widget.router,
        );
      },
    );
  }
}

