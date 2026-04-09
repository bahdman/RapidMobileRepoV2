import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_text_field.dart';
import 'package:rapid_app/route_names.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }

  void _showOtpDialog() {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        void onAlright() {
          Navigator.of(context).pop(); // Close dialog
          context.pushNamed(AppRoutes.emailOtp); // Go to OTP screen
        }

        final Widget actionText = Text(
          'Alright',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        );

        final platform = Theme.of(context).platform;
        final isIOS =
            platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

        return AlertDialog.adaptive(
          title: Text(
            'Check your email',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
          ),
          content: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'We sent an OTP to verify your password to some@email.com',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ),
          actions: <Widget>[
            isIOS
                ? CupertinoDialogAction(onPressed: onAlright, child: actionText)
                : TextButton(onPressed: onAlright, child: actionText),
          ],
        );
      },
    );
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

                // Padlock Icon
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.grey200, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.grey400,
                    size: 24.w,
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  'Create a password',
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),

                Text(
                  'At least 8 characters',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey800,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 20.h),

                // First Password Field
                RapidTextField(
                  controller: _passwordController,
                  hintText: 'Enter a password',
                  obscureText: true,
                  backgroundColor: Colors.white,
                  inactiveBorderColor: AppColors.grey200,
                ),
                SizedBox(height: 24.h),

                // Re-type Password Label
                Text(
                  'Re-type your password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey800,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 20.h),

                // Re-type Password Field
                RapidTextField(
                  controller: _retypePasswordController,
                  hintText: 'Enter a password',
                  obscureText: true,
                  backgroundColor: Colors.white,
                  inactiveBorderColor: AppColors.grey200,
                ),

                SizedBox(height: 30.h),

                // Continue Button
                ElevatedButton(
                  onPressed: _showOtpDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size(double.infinity, 56.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
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
