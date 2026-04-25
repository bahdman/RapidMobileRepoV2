import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/core/widgets/rapid_auth_animation.dart';
import 'package:rapid_app/route_names.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rapid_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:rapid_app/features/auth/data/models/auth_models.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusScope = FocusNode();
  String _selectedMethod = 'sms';

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
        toolbarHeight: 75.h,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.w),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is RequestOtpSuccess) {
                final phone = _phoneController.text.trim();
                final fullContact = '+234$phone';
                context.pushNamed(AppRoutes.phoneOtp, extra: {
                  'challengeId': state.response.challengeId,
                  'contact': fullContact,
                });
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    Text(
                      'Enter your number',
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Phone Input Field
                    Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryTxtFieldBg,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 16.w),
                          SvgPicture.asset(Assets.ngFlag),
                          SizedBox(width: 12.w),
                          SvgPicture.asset(Assets.arrowDown),
                          SizedBox(width: 16.w),
                          Text(
                            '+234',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              focusNode: _phoneFocusScope,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                filled: false,
                                border: InputBorder.none,
                                hintText: '81000531338',
                                hintStyle: TextStyle(
                                  color: AppColors.grey400,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20.w),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Use SMS Option
                    GestureDetector(
                      onTap: () => setState(() => _selectedMethod = 'sms'),
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.transparent),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(
                          children: [
                            SvgPicture.asset(Assets.sms),
                            SizedBox(width: 16.w),
                            Text(
                              'Use SMS',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            _buildRadioObject(_selectedMethod == 'sms'),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.h, bottom: 5.h),
                      child: const Divider(color: AppColors.grey200, height: 1),
                    ),

                    // Use Whatsapp Option
                    GestureDetector(
                      onTap: () => setState(() => _selectedMethod = 'whatsapp'),
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.transparent),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Row(
                          children: [
                            SvgPicture.asset(Assets.whatsapp),
                            SizedBox(width: 16.w),
                            Text(
                              'Use Whatsapp',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            _buildRadioObject(_selectedMethod == 'whatsapp'),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                    Text(
                      'Rapid will not send anything without your consent.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 32.h),
                    RapidButton(
                      text: 'Continue',
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        final phone = _phoneController.text.trim();
                        if (phone.isEmpty) return;
                        
                        final fullContact = '+234$phone';
                        context.read<AuthBloc>().add(
                          RequestOtpRequested(RequestOtpRequest(contact: fullContact)),
                        );
                      },
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
                  ),
                  RapidAuthLoadingOverlay(
                    isVisible: state is AuthLoading,
                    message: 'Sending verification code...',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRadioObject(bool isSelected) {
    return Container(
      height: 24.w,
      width: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.grey200,
          width: isSelected ? 6.5.w : 1.5.w,
        ),
        color: Colors.white,
      ),
    );
  }
}
