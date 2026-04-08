import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/features/home/presentation/screens/code_search_screen.dart';
import 'package:rapid_app/route_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            //top section
            Container(
              padding: EdgeInsets.only(top: 10.h, bottom: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(Assets.logoWhite, height: 28.h),
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              context.pushNamed(AppRoutes.notification),
                          child: SvgPicture.asset(Assets.notification),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Hero(
                    tag: kInputCodeHeroTag,
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () => context.pushNamed(AppRoutes.codeSearch),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 20.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: 'Input code',
                              hintStyle: TextStyle(
                                color: AppColors.hintGrey,
                                fontSize: 15.sp,
                              ),
                              border: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _tagItem('UP0903'),
                        _tagItem('CU0402'),
                        _tagItem('BI0903'),
                        _tagItem('BI0903'),
                        _tagItem('BI0903'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //connect your vehicle
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Connect to your vehicle
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                      ).copyWith(top: 24.h),
                      child: Text(
                        'Connect to your vehicle',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDarkGrey,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Connect buttons
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: RapidButton(
                              text: 'Wifi',
                              onPressed: () {},
                              backgroundColor: AppColors.btnGrey,
                              textColor: AppColors.textDarkGrey,
                              height: 48,
                              borderRadius: 100.r,
                              fontWeight: FontWeight.w500,
                              icon: SvgPicture.asset(Assets.wifi),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: RapidButton(
                              text: 'Bluetooth',
                              onPressed: () =>
                                  context.pushNamed(AppRoutes.bluetooth),
                              backgroundColor: AppColors.btnGrey,
                              textColor: AppColors.textDarkGrey,
                              height: 48,
                              borderRadius: 100.r,
                              fontWeight: FontWeight.w500,
                              icon: SvgPicture.asset(Assets.bluetoothGrey),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          RapidButton(
                            text: 'Info',
                            onPressed: () {},
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            height: 48,
                            width: null, // Auto-width
                            borderRadius: 24.r,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            icon: SvgPicture.asset(Assets.infoCircleWhite),
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // History Section
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            // History header and filter button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'History',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textVeryDarkGrey,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.btnGrey,
                                    borderRadius: BorderRadius.circular(100.r),
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(Assets.filter),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Filter',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            // History Items List
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.only(bottom: 120.h),
                                physics: const BouncingScrollPhysics(),
                                itemCount: 10,
                                itemBuilder: (context, index) {
                                  return _historyItem(
                                    'Scan Report',
                                    '3rd March, 2026',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagItem(String text) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primaryDisabled,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(color: AppColors.txtFadedBlue, fontSize: 13.sp),
      ),
    );
  }

  Widget _historyItem(String title, String date) {
    return InkWell(
      onTap: () {},
      splashColor: AppColors.primaryDisabled,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textVeryDarkGrey,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textMediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset(Assets.arrowRight),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
