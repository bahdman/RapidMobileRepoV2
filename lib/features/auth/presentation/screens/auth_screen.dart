import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/route_names.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusScope = FocusNode();

  // Simple SVG strings for social icons since they might not be in assets
  final String googleSvg =
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48"><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/><path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/></svg>''';
  final String appleSvg =
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512"><path fill="#000000" d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"/></svg>''';
  final String facebookSvg =
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path fill="#1877F2" d="M504 256C504 119 393 8 256 8S8 119 8 256c0 123.78 90.69 226.38 209.25 245V327.69h-63V256h63v-54.64c0-62.15 37-96.48 93.67-96.48 27.14 0 55.52 4.84 55.52 4.84v61h-31.28c-30.8 0-40.41 19.12-40.41 38.73V256h68.78l-11 71.69h-57.78V501C413.31 482.38 504 379.78 504 256z"/></svg>''';

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusScope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocus,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30.h),
                Text(
                  'Enter your number',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 24.h),

                // Phone Input Field
                Container(
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 20.w),
                      SvgPicture.asset(Assets.ngFlag),
                      SizedBox(width: 12.w),
                      SvgPicture.asset(Assets.arrowDown),

                      SizedBox(width: 12.w),
                      Text(
                        '+234 | ',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey800,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          focusNode: _phoneFocusScope,
                          decoration: InputDecoration(
                            filled: false,
                            border: InputBorder.none,
                            hintText: '',
                            contentPadding: EdgeInsets.only(bottom: 2.h),
                          ),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 20.w),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Continue Button
                RapidButton(
                  text: 'Continue',
                  onPressed: () {
                    context.pushNamed(AppRoutes.phoneAuth);
                  },
                ),

                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppColors.grey200, thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: AppColors.grey200, thickness: 1),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Use Email
                _buildAuthButton(
                  label: 'Use Email',
                  onTap: () {
                    context.pushNamed(AppRoutes.emailAuth);
                  },
                  backgroundColor: AppColors.grey100,
                  textColor: Colors.black,
                  isOutline: false,
                ),
                SizedBox(height: 16.h),

                // Sign in with Apple
                _buildAuthButton(
                  label: 'Sign in with Apple',
                  onTap: () {
                    //test
                    context.pushNamed(AppRoutes.home);
                  },
                  svgIcon: appleSvg,
                ),
                SizedBox(height: 16.h),

                // Sign in with Google
                _buildAuthButton(
                  label: 'Sign in with Google',
                  onTap: () {
                    // Simulate Google Sign In and navigation to Personal Information Step
                    context.pushNamed(AppRoutes.personalInfo);
                  },
                  svgIcon: googleSvg,
                ),
                SizedBox(height: 16.h),

                // Sign in with Facebook
                _buildAuthButton(
                  label: 'Sign in with Facebook',
                  onTap: () {},
                  svgIcon: facebookSvg,
                ),

                SizedBox(height: 48.h),

                // Terms & Conditions
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.grey500,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(text: 'By signing up, you agree to our '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: ',\nacknowledge our '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text:
                            ", and confirm that you're\nover 18. We may send promotions related to our services -\nyou can unsubscribe anytime in Communication Settings\nunder your profile.",
                      ),
                    ],
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

  Widget _buildAuthButton({
    required String label,
    required VoidCallback onTap,
    String? svgIcon,
    Color? backgroundColor,
    Color? textColor,
    bool isOutline = true,
  }) {
    return RapidButton(
      text: label,
      onPressed: onTap,
      isOutline: isOutline,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: svgIcon != null
          ? SvgPicture.string(svgIcon, width: 20.w, height: 20.h)
          : null,
    );
  }
}
