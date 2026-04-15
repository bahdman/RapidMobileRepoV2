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

// ── Vertical Transition for Tabs ──
CustomTransitionPage<T> _tabFadeSlideUpTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutQuart);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(curve),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        ),
      );
    },
  );
}

CustomTransitionPage<T> _fadeTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(String initialRoute) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialRoute,
    routes: [
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return PageHolder(child: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return _AnimatedBranchContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          );
        },
        branches: [
          // Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/${AppRoutes.home}',
                name: AppRoutes.home,
                pageBuilder: (context, state) => _tabFadeSlideUpTransition(
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
                pageBuilder: (context, state) => _tabFadeSlideUpTransition(
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
                pageBuilder: (context, state) => _tabFadeSlideUpTransition(
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
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/${AppRoutes.onboarding}',
        name: AppRoutes.onboarding,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),

      GoRoute(
        path: '/${AppRoutes.auth}',
        name: AppRoutes.auth,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AuthScreen(),
      ),

      GoRoute(
        path: '/${AppRoutes.emailAuth}',
        name: AppRoutes.emailAuth,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EmailAuthScreen(),
      ),

      GoRoute(
        path: '/${AppRoutes.createPassword}',
        name: AppRoutes.createPassword,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final nextRoute = state.extra as String?;
          return CreatePasswordScreen(nextRoute: nextRoute);
        },
      ),

      GoRoute(
        path: '/${AppRoutes.emailOtp}',
        name: AppRoutes.emailOtp,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EmailOtpScreen(),
      ),

      GoRoute(
        path: '/${AppRoutes.phoneAuth}',
        name: AppRoutes.phoneAuth,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PhoneAuthScreen(),
      ),

      GoRoute(
        path: '/${AppRoutes.phoneOtp}',
        name: AppRoutes.phoneOtp,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PhoneOtpScreen(),
      ),

      GoRoute(
        path: '/${AppRoutes.createAccount}',
        name: AppRoutes.createAccount,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreateAccountScreen(),
      ),

      GoRoute(
        path: '/${AppRoutes.accountSuccess}',
        name: AppRoutes.accountSuccess,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AccountSuccessScreen(),
      ),

      GoRoute(
        path: '/${AppRoutes.personalInfo}',
        name: AppRoutes.personalInfo,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PersonalInformationScreen(),
      ),

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
        pageBuilder: (context, state) {
          final query = state.extra as String?;
          return _fadeTransition(
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

// ── Persistent Tab Transition Container ──
class _AnimatedBranchContainer extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;

  const _AnimatedBranchContainer({
    required this.currentIndex,
    required this.children,
  });

  @override
  State<_AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<_AnimatedBranchContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(_AnimatedBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _currentIndex = widget.currentIndex;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final isActive = index == _currentIndex;

        return Offstage(
          offstage: !isActive, // Preserve branch state
          child: TickerMode(
            enabled: isActive,
            child: isActive
                ? FadeTransition(
                    opacity: _controller,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.02),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeOutQuart,
                      )),
                      child: child,
                    ),
                  )
                : child, // When offstage, just hold the widget without active animation
          ),
        );
      }).toList(),
    );
  }
}
