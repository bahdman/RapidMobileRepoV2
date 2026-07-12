import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/utils/shared_prefs_helper.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/core/widgets/rapid_text_field.dart';
import 'package:rapid_app/core/widgets/rapid_auth_animation.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:rapid_app/features/auth/data/models/auth_models.dart';
import 'package:rapid_app/core/utils/snackbar_utils.dart';
import 'package:rapid_app/route_names.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ── Mode: defaults based on SharedPrefs ──
  late bool _isLogin;

  // ── Controllers ──
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _stayUpToDate = true;

  // ── Animation ──
  late final AnimationController _switchController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    // Show Login first if the user has previously completed sign-up,
    // otherwise default to Sign Up.
    final prefs = context.read<SharedPrefsHelper>();
    _isLogin = prefs.hasRegistered();

    _switchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _switchController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Fades out → flips mode → fades back in.
  Future<void> _toggleMode() async {
    FocusScope.of(context).unfocus();
    await _switchController.reverse();
    setState(() {
      _isLogin = !_isLogin;
      _emailController.clear();
      _passwordController.clear();
    });
    await _switchController.forward();
  }

  // ── Login handler ──
  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      showGlobalSnackBar('Please enter your email address', isError: true);
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      showGlobalSnackBar('Please enter a valid email address', isError: true);
      return;
    }
    if (password.isEmpty) {
      showGlobalSnackBar('Please enter your password', isError: true);
      return;
    }

    context.read<AuthBloc>().add(
          AppAuthLoginRequested(
            AppAuthLoginRequest(email: email, password: password),
          ),
        );
  }

  // ── Sign-up handler ──
  void _handleSignUp() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      showGlobalSnackBar('Please enter your email address', isError: true);
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      showGlobalSnackBar('Please enter a valid email address', isError: true);
      return;
    }

    context.pushNamed(
      AppRoutes.createPassword,
      extra: {'email': email},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.goNamed(AppRoutes.home);
        } else if (state is AuthError && state.isApiError) {
          showGlobalSnackBar(state.message, isError: true);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
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
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: _isLogin
                            ? _buildLoginContent(isLoading)
                            : _buildSignUpContent(),
                      ),
                    ),
                    RapidAuthLoadingOverlay(
                      isVisible: isLoading,
                      message: 'Signing you in...',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Login content ──────────────────────────────────────────
  Widget _buildLoginContent(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),

        SvgPicture.asset(Assets.onboardingEmail),
        SizedBox(height: 16.h),

        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 21.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),

        Text(
          'Sign in to your account to continue.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.grey800,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 28.h),

        // Email
        Text(
          'Email address',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey800,
          ),
        ),
        SizedBox(height: 8.h),
        RapidTextField(
          controller: _emailController,
          hintText: 'some@email.com',
          keyboardType: TextInputType.emailAddress,
          backgroundColor: AppColors.primaryTxtFieldBg,
          inactiveBorderColor: Colors.transparent,
        ),
        SizedBox(height: 20.h),

        // Password
        Text(
          'Password',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey800,
          ),
        ),
        SizedBox(height: 8.h),
        RapidTextField(
          controller: _passwordController,
          hintText: 'Enter your password',
          obscureText: true,
          backgroundColor: AppColors.primaryTxtFieldBg,
          inactiveBorderColor: Colors.transparent,
        ),
        SizedBox(height: 36.h),

        RapidButton(
          text: 'Sign in',
          isLoading: isLoading,
          onPressed: isLoading ? null : _handleLogin,
        ),
        SizedBox(height: 24.h),

        // Toggle to sign up
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey800,
                fontWeight: FontWeight.w400,
              ),
              children: [
                const TextSpan(text: "Don't have an account? "),
                TextSpan(
                  text: 'Sign up',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _toggleMode,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 32.h),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.04, end: 0);
  }

  // ── Sign-up content ────────────────────────────────────────
  Widget _buildSignUpContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),

        SvgPicture.asset(Assets.onboardingEmail),
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

        // Email
        RapidTextField(
          controller: _emailController,
          hintText: 'some@email.com',
          keyboardType: TextInputType.emailAddress,
          backgroundColor: AppColors.primaryTxtFieldBg,
          inactiveBorderColor: Colors.transparent,
        ),
        SizedBox(height: 24.h),

        // Stay up to date checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: Checkbox(
                value: _stayUpToDate,
                onChanged: (val) {
                  setState(() => _stayUpToDate = val ?? false);
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

        RapidButton(
          text: 'Continue',
          onPressed: _handleSignUp,
        ),
        SizedBox(height: 24.h),

        // Toggle to login
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey800,
                fontWeight: FontWeight.w400,
              ),
              children: [
                const TextSpan(text: 'Already have an account? '),
                TextSpan(
                  text: 'Log in',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _toggleMode,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 32.h),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.04, end: 0);
  }
}
