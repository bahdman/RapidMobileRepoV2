import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/core/widgets/rapid_text_field.dart';
import 'package:rapid_app/core/widgets/rapid_auth_animation.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:rapid_app/features/auth/data/models/auth_models.dart';
import 'package:rapid_app/core/utils/snackbar_utils.dart';
import 'package:rapid_app/route_names.dart';

class CreatePasswordScreen extends StatefulWidget {
  /// The email address collected from EmailAuthScreen.
  final String? email;

  /// Optional route name to navigate to on Continue (used by CreateAccountScreen flow).
  final String? nextRoute;

  final String? onboardingToken;
  final String? firstName;
  final String? lastName;
  final String? dob;
  final bool? acceptTerms;

  const CreatePasswordScreen({
    super.key,
    this.email,
    this.nextRoute,
    this.onboardingToken,
    this.firstName,
    this.lastName,
    this.dob,
    this.acceptTerms,
  });

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

  void _showOtpDialog(String challengeId, String email) {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        void onAlright() {
          Navigator.of(dialogContext).pop(); // Close dialog
          context.pushNamed(
            AppRoutes.emailOtp,
            extra: {
              'challengeId': challengeId,
              'contact': email,
            },
          );
        }

        final Widget actionText = Text(
          'Alright',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        );

        final platform = Theme.of(dialogContext).platform;
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
              'We sent an OTP to verify your account to $email',
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

  void _handleContinue() {
    final password = _passwordController.text;
    final retypePassword = _retypePasswordController.text;

    if (password.length < 8) {
      showGlobalSnackBar('Password must be at least 8 characters', isError: true);
      return;
    }

    if (password != retypePassword) {
      showGlobalSnackBar('Passwords do not match', isError: true);
      return;
    }

    if (widget.onboardingToken != null) {
      // This is the onboarding flow (from CreateAccountScreen)
      context.read<AuthBloc>().add(
            CompleteOnboardingRequested(CompleteOnboardingRequest(
              onboardingToken: widget.onboardingToken!,
              firstName: widget.firstName ?? '',
              lastName: widget.lastName ?? '',
              dob: widget.dob ?? '',
              acceptTerms: widget.acceptTerms ?? true,
              password: password,
              confirmPassword: retypePassword,
            )),
          );
    } else if (widget.email != null) {
      // Email sign-up flow: fire CreateEmailAccountRequested
      context.read<AuthBloc>().add(
            CreateEmailAccountRequested(CreateEmailAccountRequest(
              email: widget.email!,
              password: password,
              confirmPassword: retypePassword,
            )),
          );
    } else {
      // Fallback
      if (widget.nextRoute != null) {
        context.pushNamed(widget.nextRoute!);
      } else {
        _showOtpDialog('placeholder_id', 'your email');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is CreateEmailAccountSuccess) {
          // Account created, show OTP dialog
          _showOtpDialog(state.response.userId, state.response.email);
        } else if (state is AuthAuthenticated) {
          context.goNamed(AppRoutes.home);
        } else if (state is AuthError && state.isApiError) {
          showGlobalSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 75.h,
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
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),

                      SvgPicture.asset(Assets.onboardingPwd),
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
                        backgroundColor: AppColors.primaryTxtFieldBg,
                        inactiveBorderColor: Colors.transparent,
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
                        backgroundColor: AppColors.primaryTxtFieldBg,
                        inactiveBorderColor: Colors.transparent,
                      ),

                      SizedBox(height: 30.h),

                      // Continue Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return RapidButton(
                            text: 'Continue',
                            isLoading: state is AuthLoading,
                            onPressed: _handleContinue,
                          );
                        },
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return RapidAuthLoadingOverlay(
                      isVisible: state is AuthLoading,
                      message: 'Creating your account...',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
