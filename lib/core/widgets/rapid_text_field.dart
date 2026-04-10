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

  const RapidTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.backgroundColor = Colors.white,
    this.inactiveBorderColor = Colors.transparent,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _isFocused ? AppColors.primary : widget.inactiveBorderColor,
          width: _isFocused ? 2 : 1.5,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: _isObscured,
        keyboardType: widget.keyboardType,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: AppColors.grey400),
          filled: false,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
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
                    fit: BoxFit.scaleDown,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
