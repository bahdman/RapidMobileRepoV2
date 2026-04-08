import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_app_bar.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlanIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const RapidAppBar(title: 'Subscription'),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  _buildPlanCard(
                    index: 0,
                    title: 'Free Plan',
                    price: '\$0',
                    subtitle: '/month',
                    isCurrent: true,
                    features: [
                      '5 code lookups/day',
                      'Basic scan reports',
                      '1 vehicle profile',
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildPlanCard(
                    index: 1,
                    title: 'Rapid Premium',
                    price: '\$9.99',
                    subtitle: '/month',
                    isCurrent: false,
                    isRecommended: true,
                    features: [
                      'Unlimited sub-scans',
                      'Advanced AI diagnostics',
                      'Priority support',
                      'Unlimited vehicle profiles',
                    ],
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Change Plan',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 32.h),
                child: Text(
                  'Rapid V1.2',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textMediumGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String subtitle,
    required bool isCurrent,
    bool isRecommended = false,
    required List<String> features,
  }) {
    final isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor2,
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xffCCDCEF),
                      borderRadius: BorderRadius.circular(100.r),
                      border: Border.all(color: Color(0xffE2E8F0)),
                    ),
                    child: Text(
                      'Current',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (isRecommended)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Text(
                      'Recommended',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textMediumGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            const Divider(color: AppColors.borderColor2),
            SizedBox(height: 24.h),
            ...features.map(
              (feature) => _buildFeatureItem(
                feature,
                isPremium: title.contains('Premium'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, {required bool isPremium}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          SvgPicture.asset(
            Assets.checkCircleGreen,
            width: 20.w,
            colorFilter: ColorFilter.mode(
              isPremium ? AppColors.primary : AppColors.tertiaryGreen,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
