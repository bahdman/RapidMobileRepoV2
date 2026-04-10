import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/route_names.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SafeArea(
          child: Column(
            children: [
              // Header: Avatar, Name & Badge
              SizedBox(height: 30.h),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            'https://i.pravatar.cc/150?img=3',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
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
                  onTap: () => context.pushNamed(AppRoutes.profile),
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
                  onPressed: () {},
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
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFF9CA3AF),
                  size: 20.w,
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(color: AppColors.grey200, thickness: 1, height: 0.5),
        ],
      ),
    );
  }
}
