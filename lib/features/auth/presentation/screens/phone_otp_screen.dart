import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/route_names.dart';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  bool _isCodeComplete = false;

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 72.w,
      height: 83.1.h,
      textStyle: TextStyle(
        fontSize: 35.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200, width: 1),
      ),
    );

    return GestureDetector(
      onTap: _unfocus,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.w),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Text(
                    'Enter the code',
                    style: TextStyle(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Pinput for 4 digit OTP
                  Center(
                    child: Pinput(
                      length: 4,
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          color: Colors.white,
                        ),
                      ),
                      submittedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          color: Colors.white,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isCodeComplete = value.length == 4;
                        });
                      },
                      onCompleted: (pin) {
                        setState(() {
                          _isCodeComplete = true;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Resend Code
                  GestureDetector(
                    onTap: () {
                      // Logic to resend code
                    },
                    child: Text(
                      'Resend code',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  SizedBox(height: 48.h),

                  // Continue Button
                  if (_isCodeComplete)
                    RapidButton(
                      text: 'Continue',
                      onPressed: () {
                        context.pushNamed(AppRoutes.createAccount);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
