import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/core/widgets/rapid_text_field.dart';
import 'package:rapid_app/route_names.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _stayUpToDate = true;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 100.w,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primary,
                size: 20.w,
              ),
              SizedBox(width: 4.w),
              Text(
                'Back',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),

                // @ Icon in a rounded container style
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.grey200, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '@',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: AppColors.grey400,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  'Get going with email',
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),

                Text(
                  "It's helpful to provide a good reason for why the email address is required.",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey800,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 20.h),

                // Email Input Field
                RapidTextField(
                  controller: _emailController,
                  hintText: 'some@email.com',
                  keyboardType: TextInputType.emailAddress,
                  backgroundColor: AppColors.grey100,
                  inactiveBorderColor: Colors.transparent,
                ),
                SizedBox(height: 24.h),

                // Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: Checkbox(
                        value: _stayUpToDate,
                        onChanged: (val) {
                          setState(() {
                            _stayUpToDate = val ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        side: BorderSide(color: AppColors.grey800, width: 1.5),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Stay up to date with the latest news and resources delivered directly to your inbox',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey800,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),

                // Continue Button
                RapidButton(
                  text: 'Continue',
                  onPressed: () {
                    context.pushNamed(AppRoutes.createPassword);
                  },
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
