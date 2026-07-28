import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/core/widgets/rapid_auth_animation.dart';
import 'package:rapid_app/core/utils/snackbar_utils.dart';
import 'package:rapid_app/route_names.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusScope = FocusNode();

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
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError && state.isApiError) {
            showGlobalSnackBar(state.message, isError: true);
          } else if (state is AuthAuthenticated) {
            context.goNamed(AppRoutes.home);
          } else if (state is AuthRegisterSuccess) {
            context.pushNamed(
              AppRoutes.personalInfo,
              extra: state.user,
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isGoogleLoading = state is AuthLoading;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Scaffold(
              backgroundColor: isDark ? AppColors.darkScaffoldBg : Colors.white,
              appBar: AppBar(
                backgroundColor: isDark ? AppColors.darkScaffoldBg : Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              body: SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
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
                        color: isDark ? AppColors.darkTextPrimary : Colors.black,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Phone Input Field
                    Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.grey100,
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
                              color: isDark ? AppColors.darkTextSub : AppColors.grey800,
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
                                color: isDark ? AppColors.darkTextPrimary : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 20.w),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                     RapidButton(
                      text: 'Continue',
                      onPressed: () {
                        final phone = _phoneController.text.trim();
                        context.pushNamed(
                          AppRoutes.phoneAuth,
                          extra: phone,
                        );
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
                        context.pushNamed(AppRoutes.login);
                      },
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.grey100,
                      textColor: isDark ? AppColors.darkTextPrimary : Colors.black,
                      isOutline: false,
                    ),
                    SizedBox(height: 16.h),

                    // Sign in with Apple
                    // _buildAuthButton(
                    //   label: 'Sign in with Apple',
                    //   onTap: () {
                    //     //test
                    //     context.pushNamed(AppRoutes.home);
                    //   },
                    //   svgIcon: Assets.apple,
                    // ),
                    // SizedBox(height: 16.h),

                    // Sign in with Google
                    _buildAuthButton(
                      label: 'Sign in with Google',
                      isLoading: isGoogleLoading,
                      onTap: () {
                        context.read<AuthBloc>().add(GoogleSignInRequested());
                      },
                      svgIcon: Assets.google,
                    ),
                    // SizedBox(height: 16.h),

                    // // Sign in with Facebook
                    // _buildAuthButton(
                    //   label: 'Sign in with Facebook',
                    //   onTap: () {},
                    //   svgIcon: Assets.facebook,
                    // ),

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
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
              ),
              RapidAuthLoadingOverlay(
                isVisible: isGoogleLoading,
                message: 'Authenticating with Google...',
              ),
            ],
          ),
        ),
      );
      },
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
    bool isLoading = false,
  }) {
    return RapidButton(
      text: label,
      isLoading: isLoading,
      onPressed: onTap,
      isOutline: isOutline,
      backgroundColor: backgroundColor,
      textColor: textColor,
      isFullWidthLeading: true,
      icon: svgIcon != null ? SvgPicture.asset(svgIcon) : null,
    );
  }
}
