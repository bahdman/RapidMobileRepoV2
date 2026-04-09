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
  final int _selectedPlanIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const RapidAppBar(title: 'Subscription'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  _buildPlanCard(
                    title: 'Free',
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
                    title: 'Pro',
                    price: '\$9.99',
                    subtitle: '/month',
                    isCurrent: false,
                    isRecommended: true,
                    buttonText: 'Upgrade to Pro',
                    features: [
                      'Unlimited code lookups',
                      'Full scan reports',
                      '3 vehicle profiles',
                      'Driving score',
                      'Priority support',
                    ],
                  ),
                  SizedBox(height: 32.h),
                  _buildPlanCard(
                    title: 'Premium',
                    price: '\$19.99',
                    subtitle: '/month',
                    isCurrent: false,
                    buttonText: 'Choose Premium',
                    isOutlinedButton: true,
                    features: [
                      'Everything in Pro',
                      'Unlimited vehicles',
                      'Auto-scheduled scans',
                      'Repair cost estimates',
                      '24/7 live support',
                    ],
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 32.h, top: 16.h),
            child: Text(
              'Rapid V1.2',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.grey500,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String subtitle,
    required bool isCurrent,
    bool isRecommended = false,
    String? buttonText,
    bool isOutlinedButton = false,
    required List<String> features,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isRecommended ? AppColors.primary : AppColors.borderColor2,
              width: isRecommended ? 1.w : 1.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
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
                        padding: EdgeInsets.only(bottom: 6.h, left: 2.w),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.black200,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (isCurrent)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(100.r),
                        border: Border.all(color: const Color(0xffE2E8F0)),
                      ),
                      child: Text(
                        'Current',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 24.h),
              ...features.map((feature) => _buildFeatureItem(feature)),
              if (buttonText != null) ...[
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOutlinedButton
                          ? Colors.white
                          : AppColors.primary,
                      foregroundColor: isOutlinedButton
                          ? Colors.black
                          : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.r),
                        side: isOutlinedButton
                            ? BorderSide(color: AppColors.borderColor2)
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isRecommended)
          Positioned(
            top: -16.h,
            left: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(Assets.whiteBulb),
                  SizedBox(width: 8.w),
                  Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          SvgPicture.asset(Assets.doubleTickBlue),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey800,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
