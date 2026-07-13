import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/utils/shared_prefs_helper.dart';
import 'package:rapid_app/core/widgets/rapid_auth_animation.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:rapid_app/route_names.dart';
import 'package:rapid_app/core/services/user_service.dart';
import 'package:rapid_app/core/widgets/user_avatar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _displayName = 'User';
  String? _avatar;

  @override
  void initState() {
    super.initState();
    _fetchProfileName();
  }

  Future<void> _fetchProfileName() async {
    try {
      final userService = context.read<UserService>();
      // We pass refresh: true to bypass the cache to ensure we get latest if updated
      final profile = await userService.getUserProfile(refresh: true);
      if (profile != null && mounted) {
        final fullName = '${profile.firstName} ${profile.lastName}'.trim();
        setState(() {
          _displayName = fullName.isNotEmpty ? fullName : 'User';
          _avatar = profile.avatar;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile name for AccountScreen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = context.read<SharedPrefsHelper>();
    final userId = sharedPrefs.getUser() ?? '';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          // Clear any local state or navigate to auth
          context.goNamed(AppRoutes.auth);
        } else if (state is AuthError && state.isApiError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Header: Avatar, Name & Badge
                        SizedBox(height: 30.h),
                        Center(
                          child: Column(
                            children: [
                              UserAvatar(
                                avatar: _avatar ?? 'https://i.pravatar.cc/150?img=3',
                                size: 60.w,
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                _displayName,
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCCDCEF),
                                  borderRadius: BorderRadius.circular(100.r),
                                  border: Border.all(color: Color(0xffE2E8F0)),
                                ),
                                child: Text(
                                  'Free Plan',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF004999),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Upgrade Card
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(Assets.shield),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Unlimited scans, deeper diagnostics, and full vehicle insights.',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        height: 1.4,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Upgrade to Premium',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xffCCE4FF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Section 1: Profile & Subscription
                        _buildGroupedCard([
                          _buildMenuItem(
                            svg: Assets.profile,
                            title: 'Profile Setup',
                            subtitle: 'Name, photo, phone',
                            onTap: () async {
                              await context.pushNamed(AppRoutes.profile);
                              _fetchProfileName();
                            },
                          ),
                          _buildMenuItem(
                            svg: Assets.subscriptions,
                            title: 'Subscription',
                            subtitle: 'Plan & Billing',
                            onTap: () => context.pushNamed(AppRoutes.subscription),
                            showDivider: false,
                          ),
                        ]),
                        SizedBox(height: 16.h),

                        // Section 2: Schedules & Refer
                        _buildGroupedCard([
                          _buildMenuItem(
                            svg: Assets.schedule,
                            title: 'Schedules',
                            subtitle: 'Auto scan sessions',
                            onTap: () => context.pushNamed(AppRoutes.schedules),
                          ),
                          _buildMenuItem(
                            svg: Assets.refer,
                            title: 'Refer a Friend',
                            subtitle: 'Earn free months',
                            onTap: () => context.pushNamed(AppRoutes.refer),
                            showDivider: false,
                          ),
                        ]),
                        SizedBox(height: 16.h),

                        // Section 3: Settings
                        _buildGroupedCard([
                          _buildMenuItem(
                            svg: Assets.settings,
                            title: 'Settings',
                            subtitle: 'Notifications & privacy',
                            onTap: () => context.pushNamed(AppRoutes.settings),
                            showDivider: false,
                          ),
                        ]),
                        SizedBox(height: 32.h),

                        // Sign Out Button
                        SizedBox(
                          width: double.infinity,
                          height: 64.h,
                          child: OutlinedButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(LogoutRequested(userId: userId));
                            },
                            style: OutlinedButton.styleFrom(
                              overlayColor: AppColors.red.withValues(alpha: 0.1),
                              side: const BorderSide(color: AppColors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60.r),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(Assets.logout),
                                SizedBox(width: 12.w),
                                Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 48.h),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
                  ),
                ),
                RapidAuthLoadingOverlay(
                  isVisible: state is AuthLoading,
                  message: 'Signing out safely...',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required String svg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final subColor = isDark ? AppColors.darkTextSub : const Color(0xFF9CA3AF);
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
            child: Row(
              children: [
                SvgPicture.asset(svg),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: subColor,
                  size: 20.w,
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              color: isDark ? AppColors.darkBorder : AppColors.grey200,
              thickness: 1,
              height: 0.5,
            ),
        ],
      ),
    );
  }
}
