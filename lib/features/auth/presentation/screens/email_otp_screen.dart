import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/core/widgets/rapid_auth_animation.dart';
import 'package:rapid_app/core/utils/snackbar_utils.dart';
import 'package:rapid_app/route_names.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:rapid_app/features/auth/data/models/auth_models.dart';

class EmailOtpScreen extends StatefulWidget {
  final String challengeId;
  final String contact;

  const EmailOtpScreen({
    super.key,
    required this.challengeId,
    required this.contact,
  });

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  Timer? _timer;
  int _countdownSeconds = 30;
  late String _challengeId;
  bool _isCodeComplete = false;

  @override
  void initState() {
    super.initState();
    _challengeId = widget.challengeId;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _countdownSeconds = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  bool get _isPinComplete => _pinController.text.length == 6;

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
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

    return Scaffold(
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
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthNeedsOnboarding) {
                context.pushNamed(AppRoutes.createAccount, extra: state.onboardingToken);
              } else if (state is AuthAuthenticated) {
                context.goNamed(AppRoutes.home);
              } else if (state is RequestOtpSuccess) {
                showGlobalSnackBar('Verification code resent successfully!');
                setState(() {
                  _challengeId = state.response.challengeId;
                });
                _startTimer();
              } else if (state is AuthError && state.isApiError) {
                showGlobalSnackBar(state.message, isError: true);
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 24.h),
                          Text(
                            'Enter the code',
                            style: TextStyle(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          
                          // OTP Input Boxes
                          Center(
                            child: Pinput(
                              length: 6,
                              controller: _pinController,
                              focusNode: _focusNode,
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
                                  _isCodeComplete = value.length == 6;
                                });
                              },
                              onCompleted: (pin) {
                                setState(() {
                                  _isCodeComplete = true;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 24.h),

                          GestureDetector(
                            onTap: _countdownSeconds > 0
                                ? null
                                : () {
                                    context.read<AuthBloc>().add(
                                          RequestOtpRequested(RequestOtpRequest(
                                            contact: widget.contact,
                                          )),
                                        );
                                  },
                            child: Text(
                              _countdownSeconds > 0
                                  ? 'Resend code in ${_countdownSeconds}s'
                                  : 'Resend code',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                color: _countdownSeconds > 0
                                    ? AppColors.grey500
                                    : AppColors.primary,
                              ),
                            ),
                          ),

                          SizedBox(height: 48.h),

                          // Animated Continue Button
                          if (_isCodeComplete)
                            RapidButton(
                              text: 'Continue',
                              isLoading: state is AuthLoading,
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                      VerifyOtpRequested(VerifyOtpRequest(
                                        challengeId: _challengeId,
                                        otp: _pinController.text,
                                      )),
                                    );
                              },
                            ),
                          SizedBox(height: 32.h),
                        ],
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
                    ),
                  ),
                  RapidAuthLoadingOverlay(
                    isVisible: state is AuthLoading,
                    message: 'Verifying code...',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
