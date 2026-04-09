import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/route_names.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final TextEditingController _firstNameController = TextEditingController(
    text: 'Timothy',
  );
  final TextEditingController _lastNameController = TextEditingController(
    text: 'Oke',
  );
  bool _agreedToTerms = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
          child: Column(
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
              _buildTextField(
                controller: _firstNameController,
                hint: 'First name',
              ),
              SizedBox(height: 16.h),

              // Last Name Field
              _buildTextField(
                controller: _lastNameController,
                hint: 'Last name',
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
                    color: Color(0xffB8FFDC),
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
              ElevatedButton(
                onPressed: _agreedToTerms
                    ? () {
                        // Registration complete logic
                        context.goNamed(AppRoutes.home);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.5,
                  ),
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Complete',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          filled: false,
          hintStyle: TextStyle(color: AppColors.grey400),
          contentPadding: EdgeInsets.only(bottom: 4.h),
        ),
      ),
    );
  }
}
