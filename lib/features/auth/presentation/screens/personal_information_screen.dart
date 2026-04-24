import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/core/widgets/rapid_text_field.dart';
import 'package:rapid_app/features/auth/data/models/auth_models.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:rapid_app/route_names.dart';

class PersonalInformationScreen extends StatefulWidget {
  final GoogleAuthUser? user;
  const PersonalInformationScreen({super.key, this.user});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  bool _agreedToTerms = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.user?.firstName ?? 'Timothy',
    );
    _lastNameController = TextEditingController(
      text: widget.user?.lastName ?? 'Oke',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.pushNamed(AppRoutes.accountSuccess);
        } else if (state is AuthError && state.isApiError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 75.h,
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 80.w,
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 8.w),
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Confirm your name(s)',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.grey500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 26.h),

                    // First Name Field
                    RapidTextField(
                      controller: _firstNameController,
                      hintText: 'First name',
                      backgroundColor: AppColors.primaryTxtFieldBg,
                    ),
                    SizedBox(height: 16.h),

                    // Last Name Field
                    RapidTextField(
                      controller: _lastNameController,
                      hintText: 'Last name',
                      backgroundColor: AppColors.primaryTxtFieldBg,
                    ),
                    SizedBox(height: 32.h),

                    // Info Banner
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppColors.green2,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Text(
                        'You can edit your information in the account section after completion',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xffB8FFDC),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Terms Checkbox
                    Row(
                      children: [
                        SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreedToTerms = value ?? false;
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
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.grey600,
                              ),
                              children: [
                                const TextSpan(text: 'I agree to follow the '),
                                TextSpan(
                                  text: 'terms of use',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Complete Button
                    RapidButton(
                      text: 'Complete',
                      isLoading: isLoading,
                      onPressed: _agreedToTerms
                          ? () {
                              if (widget.user != null) {
                                // For Google Users
                                context.read<AuthBloc>().add(
                                      TermsAccepted(
                                        userId: widget.user!.id,
                                        acceptTerms: true,
                                      ),
                                    );
                              } else {
                                // Default navigation for manual flow
                                context.pushNamed(AppRoutes.accountSuccess);
                              }
                            }
                          : null,
                    ),
                    SizedBox(height: 24.h),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
              },
            ),
          ),
        ),
      ),
    );
  }
}
