import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';

class RapidTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Color backgroundColor;
  final Color inactiveBorderColor;
  final Widget? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const RapidTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.backgroundColor = Colors.white,
    this.inactiveBorderColor = Colors.transparent,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<RapidTextField> createState() => _RapidTextFieldState();
}

class _RapidTextFieldState extends State<RapidTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _focusNode.canRequestFocus = !widget.readOnly;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor = widget.backgroundColor;
    if (isDark) {
      if (bgColor == Colors.white ||
          bgColor == AppColors.primaryTxtFieldBg ||
          bgColor == AppColors.secondaryTxtFieldBg) {
        bgColor = AppColors.darkSurface;
      }
    }

    final textColor = isDark ? AppColors.darkTextPrimary : Colors.black;
    final hintColor = isDark ? AppColors.darkTextSub : AppColors.grey400;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: (_isFocused && !widget.readOnly)
              ? AppColors.primary
              : (isDark && widget.inactiveBorderColor == Colors.transparent
                  ? Colors.transparent
                  : (isDark ? AppColors.darkBorder : widget.inactiveBorderColor)),
          width: (_isFocused && !widget.readOnly) ? 2 : 1.5,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: _isObscured,
        keyboardType: widget.keyboardType,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: hintColor),
          filled: false,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
          prefixIcon: widget.prefixIcon != null
              ? Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: widget.prefixIcon,
                )
              : null,
          prefixIconConstraints: BoxConstraints(
            minHeight: 20.w,
            minWidth: 0,
          ),
          suffixIconConstraints: BoxConstraints(
            minHeight: 24.w,
            minWidth: 24.w,
          ),
          suffixIcon: widget.obscureText
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                  child: SvgPicture.asset(
                    _isObscured
                        ? Assets.onboardingShowPwd
                        : Assets.onboardingHidePwd,
                    width: 24.w,
                    height: 24.h,
                    colorFilter: isDark
                        ? const ColorFilter.mode(
                            AppColors.darkTextSub,
                            BlendMode.srcIn,
                          )
                        : null,
                    fit: BoxFit.scaleDown,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
