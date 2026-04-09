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
import 'package:rapid_app/route_names.dart';
import 'package:rapid_app/core/models/issue.dart';
import 'package:rapid_app/core/models/scan_history.dart';

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
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // History
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/${AppRoutes.history}',
                name: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          // Account
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/${AppRoutes.account}',
                name: AppRoutes.account,
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Full screen routes
      GoRoute(
        path: '/${AppRoutes.notification}',
        name: AppRoutes.notification,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.bluetooth}',
        name: AppRoutes.bluetooth,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const BluetoothScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.codeSearch}',
        name: AppRoutes.codeSearch,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const CodeSearchScreen(),
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/${AppRoutes.scanning}',
        name: AppRoutes.scanning,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ScanningScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.vehicleReport}',
        name: AppRoutes.vehicleReport,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const VehicleReportScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.issueDetail}',
        name: AppRoutes.issueDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final issue = state.extra as DiagnosticIssue;
          return IssueDetailScreen(issue: issue);
        },
      ),
      GoRoute(
        path: '/${AppRoutes.scanReport}',
        name: AppRoutes.scanReport,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ScanReportScreen(
            issue: data['issue'] as DiagnosticIssue,
            date: data['date'] as DateTime,
          );
        },
      ),
      GoRoute(
        path: '/${AppRoutes.profile}',
        name: AppRoutes.profile,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.subscription}',
        name: AppRoutes.subscription,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.schedules}',
        name: AppRoutes.schedules,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SchedulesScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.settings}',
        name: AppRoutes.settings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/${AppRoutes.refer}',
        name: AppRoutes.refer,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ReferAFriendScreen(),
      ),
    ],
  );
}
