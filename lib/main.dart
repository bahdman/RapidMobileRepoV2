import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rapid_app/core/theme/app_theme.dart';
import 'package:rapid_app/core/services/api_service.dart';
import 'package:rapid_app/core/utils/shared_prefs_helper.dart';
import 'package:rapid_app/features/notifications/presentation/screens/bloc/notification_bloc.dart';
import 'package:rapid_app/features/bluetooth/presentation/screens/bloc/bluetooth_bloc.dart';
import 'package:rapid_app/features/bluetooth/presentation/screens/bloc/obd_scan_bloc.dart';
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => NotificationBloc(apiService)),
          BlocProvider(create: (context) => BluetoothBloc()),
          BlocProvider(create: (context) => ObdScanBloc()),
          BlocProvider(create: (context) => AuthBloc(authRepository, sharedPrefsHelper)),
        ],
        child: MainApp(router: router),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  final dynamic router;
  const MainApp({super.key, required this.router});

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
          routerConfig: router,
        );
      },
    );
  }
}
