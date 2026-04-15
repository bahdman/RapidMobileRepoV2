import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/widgets/page_holder.dart';
import 'package:rapid_app/features/home/presentation/screens/home_screen.dart';
import 'package:rapid_app/features/home/presentation/screens/code_search_screen.dart';
import 'package:rapid_app/features/history/presentation/screens/history_screen.dart';
import 'package:rapid_app/features/account/presentation/screens/account_screen.dart';
import 'package:rapid_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:rapid_app/features/bluetooth/presentation/screens/bluetooth_screen.dart';
import 'package:rapid_app/features/bluetooth/presentation/screens/scanning_screen.dart';
import 'package:rapid_app/features/bluetooth/presentation/screens/vehicle_report_screen.dart';
import 'package:rapid_app/features/bluetooth/presentation/screens/issue_detail_screen.dart';
import 'package:rapid_app/features/history/presentation/screens/scan_report_screen.dart';
import 'package:rapid_app/features/account/presentation/screens/profile_screen.dart';
import 'package:rapid_app/features/account/presentation/screens/subscription_screen.dart';
import 'package:rapid_app/features/account/presentation/screens/schedules_screen.dart';
import 'package:rapid_app/features/account/presentation/screens/settings_screen.dart';
import 'package:rapid_app/features/account/presentation/screens/refer_a_friend_screen.dart';
import 'package:rapid_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:rapid_app/features/auth/presentation/screens/email_auth_screen.dart';
import 'package:rapid_app/features/auth/presentation/screens/create_password_screen.dart';
import 'package:rapid_app/features/auth/presentation/screens/email_otp_screen.dart';
import 'package:rapid_app/features/auth/presentation/screens/personal_information_screen.dart';
import 'package:rapid_app/features/auth/presentation/screens/phone_auth_screen.dart';
import 'package:rapid_app/features/auth/presentation/screens/phone_otp_screen.dart';
import 'package:rapid_app/features/auth/presentation/screens/create_account_screen.dart';
import 'package:rapid_app/features/auth/presentation/screens/account_success_screen.dart';
import 'package:rapid_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:rapid_app/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:rapid_app/route_names.dart';
import 'package:rapid_app/core/models/issue.dart';

CustomTransitionPage<T> _fadeSlidePageTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: child,
        ),
      );
    },
  );
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(String initialRoute) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialRoute,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PageHolder(child: navigationShell);
        },
        branches: [
          // Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/${AppRoutes.home}',
                name: AppRoutes.home,
                pageBuilder: (context, state) => _fadeSlidePageTransition(
                  context: context,
                  state: state,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          // History
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/${AppRoutes.history}',
                name: AppRoutes.history,
                pageBuilder: (context, state) => _fadeSlidePageTransition(
                  context: context,
                  state: state,
                  child: const HistoryScreen(),
                ),
              ),
            ],
          ),
          // Account
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/${AppRoutes.account}',
                name: AppRoutes.account,
                pageBuilder: (context, state) => _fadeSlidePageTransition(
                  context: context,
                  state: state,
                  child: const AccountScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      
      GoRoute(
        path: '/${AppRoutes.splash}',
        name: AppRoutes.splash,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ), 
      ),

      GoRoute(
        path: '/${AppRoutes.onboarding}',
        name: AppRoutes.onboarding,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),

      GoRoute(
        path: '/${AppRoutes.auth}',
        name: AppRoutes.auth,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const AuthScreen(),
        ),
      ),

      GoRoute(
        path: '/${AppRoutes.emailAuth}',
        name: AppRoutes.emailAuth,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const EmailAuthScreen(),
        ),
      ),

      GoRoute(
        path: '/${AppRoutes.createPassword}',
        name: AppRoutes.createPassword,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final nextRoute = state.extra as String?;
          return _fadeSlidePageTransition(
            context: context,
            state: state,
            child: CreatePasswordScreen(nextRoute: nextRoute),
          );
        },
      ),

      GoRoute(
        path: '/${AppRoutes.emailOtp}',
        name: AppRoutes.emailOtp,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const EmailOtpScreen(),
        ),
      ),

      GoRoute(
        path: '/${AppRoutes.phoneAuth}',
        name: AppRoutes.phoneAuth,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const PhoneAuthScreen(),
        ),
      ),

      GoRoute(
        path: '/${AppRoutes.phoneOtp}',
        name: AppRoutes.phoneOtp,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const PhoneOtpScreen(),
        ),
      ),

      GoRoute(
        path: '/${AppRoutes.createAccount}',
        name: AppRoutes.createAccount,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const CreateAccountScreen(),
        ),
      ),

      GoRoute(
        path: '/${AppRoutes.accountSuccess}',
        name: AppRoutes.accountSuccess,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const AccountSuccessScreen(),
        ),
      ),

      GoRoute(
        path: '/${AppRoutes.personalInfo}',
        name: AppRoutes.personalInfo,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const PersonalInformationScreen(),
        ),
      ),

      // Full screen routes
      GoRoute(
        path: '/${AppRoutes.notification}',
        name: AppRoutes.notification,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/${AppRoutes.bluetooth}',
        name: AppRoutes.bluetooth,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const BluetoothScreen(),
        ),
      ),
      GoRoute(
        path: '/${AppRoutes.codeSearch}',
        name: AppRoutes.codeSearch,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final query = state.extra as String?;
          return _fadeSlidePageTransition(
            context: context,
            state: state,
            child: CodeSearchScreen(initialSearchQuery: query),
          );
        },
      ),
      GoRoute(
        path: '/${AppRoutes.scanning}',
        name: AppRoutes.scanning,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const ScanningScreen(),
        ),
      ),
      GoRoute(
        path: '/${AppRoutes.vehicleReport}',
        name: AppRoutes.vehicleReport,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const VehicleReportScreen(),
        ),
      ),
      GoRoute(
        path: '/${AppRoutes.issueDetail}',
        name: AppRoutes.issueDetail,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final issue = state.extra as DiagnosticIssue;
          return _fadeSlidePageTransition(
            context: context,
            state: state,
            child: IssueDetailScreen(issue: issue),
          );
        },
      ),
      GoRoute(
        path: '/${AppRoutes.scanReport}',
        name: AppRoutes.scanReport,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return _fadeSlidePageTransition(
            context: context,
            state: state,
            child: ScanReportScreen(
              issue: data['issue'] as DiagnosticIssue,
              date: data['date'] as DateTime,
            ),
          );
        },
      ),
      GoRoute(
        path: '/${AppRoutes.profile}',
        name: AppRoutes.profile,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/${AppRoutes.subscription}',
        name: AppRoutes.subscription,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const SubscriptionScreen(),
        ),
      ),
      GoRoute(
        path: '/${AppRoutes.schedules}',
        name: AppRoutes.schedules,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const SchedulesScreen(),
        ),
      ),
      GoRoute(
        path: '/${AppRoutes.settings}',
        name: AppRoutes.settings,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/${AppRoutes.refer}',
        name: AppRoutes.refer,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePageTransition(
          context: context,
          state: state,
          child: const ReferAFriendScreen(),
        ),
      ),
    ],
  );
}
