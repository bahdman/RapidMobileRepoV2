import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/core/widgets/rapid_date_picker.dart';
import 'package:rapid_app/core/widgets/rapid_text_field.dart';
import 'package:rapid_app/route_names.dart';

class CreateAccountScreen extends StatefulWidget {
  final String? onboardingToken;
  const CreateAccountScreen({super.key, this.onboardingToken});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _agreedToTerms = false;

  // Date of birth
  int? _selectedMonth;
  int? _selectedDay;
  int? _selectedYear;

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  bool get _isFormComplete =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _selectedMonth != null &&
      _selectedDay != null &&
      _selectedYear != null &&
      _agreedToTerms;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(() => setState(() {}));
    _lastNameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    _unfocus();
    final now = DateTime.now();
    final pickerKey = GlobalKey<RapidDatePickerState>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xffF7F7F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 8.h),
              RapidDatePicker(
                key: pickerKey,
                initialMonth: _selectedMonth ?? now.month,
                initialDay: _selectedDay ?? now.day,
                initialYear: _selectedYear ?? (now.year - 18),
                maxYear: now.year,
              ),
              Padding(
                padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 24.h),
                child: RapidButton(
                  text: 'Confirm',
                  onPressed: () {
                    final date = pickerKey.currentState!.selectedDate;
                    setState(() {
                      _selectedMonth = date.month;
                      _selectedDay = date.day;
                      _selectedYear = date.year;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _unfocus,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffoldBg : Colors.white,
        appBar: AppBar(
        toolbarHeight: 75.h,
          backgroundColor: isDark ? AppColors.darkScaffoldBg : Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
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
                  'Create an account',
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : Colors.black,
                  ),
                ),
                // SizedBox(height: 8.h),
                // Text(
                //   'Step 1 of 3: Personal info',
                //   style: TextStyle(
                //     fontSize: 14.sp,
                //     color: AppColors.grey500,
                //     fontWeight: FontWeight.w400,
                //   ),
                // ),
                SizedBox(height: 28.h),

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
                SizedBox(height: 24.h),

                // Date of Birth Pickers
                GestureDetector(
                  onTap: _showDatePicker,
                  child: Row(
                    children: [
                      _buildDateChip(
                        label: _selectedMonth != null
                            ? _selectedMonth.toString().padLeft(2, '0')
                            : 'MM',
                        isSelected: _selectedMonth != null,
                      ),
                      SizedBox(width: 12.w),
                      _buildDateChip(
                        label: _selectedDay != null
                            ? _selectedDay.toString().padLeft(2, '0')
                            : 'DD',
                        isSelected: _selectedDay != null,
                      ),
                      SizedBox(width: 12.w),
                      _buildDateChip(
                        label: _selectedYear != null
                            ? _selectedYear.toString()
                            : 'YYYY',
                        isSelected: _selectedYear != null,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                // Terms Checkbox
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _agreedToTerms = !_agreedToTerms;
                    });
                  },
                  child: Row(
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
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.grey400,
                            width: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDark ? AppColors.darkTextSub : AppColors.grey600,
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
                ),

                const Spacer(),

                // Continue Button
                RapidButton(
                  text: 'Continue',
                  onPressed: _isFormComplete
                      ? () {
                          final dob = '${_selectedYear!}-${_selectedMonth.toString().padLeft(2, '0')}-${_selectedDay.toString().padLeft(2, '0')}';
                          context.pushNamed(
                            AppRoutes.createPassword,
                            extra: {
                              'onboardingToken': widget.onboardingToken,
                              'firstName': _firstNameController.text.trim(),
                              'lastName': _lastNameController.text.trim(),
                              'dob': dob,
                              'acceptTerms': _agreedToTerms,
                              'nextRoute': AppRoutes.accountSuccess,
                            },
                          );
                        }
                      : null,
                ),
                SizedBox(height: 24.h),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip({required String label, required bool isSelected}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.primaryTxtFieldBg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            Assets.arrowDown,
            colorFilter: isDark
                ? const ColorFilter.mode(AppColors.darkTextSub, BlendMode.srcIn)
                : null,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w400,
              color: isDark ? AppColors.darkTextSub : const Color(0xff5F5858),
            ),
          ),
        ],
      ),
    );
  }
}
