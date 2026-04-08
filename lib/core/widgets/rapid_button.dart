import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rapid_app/core/theme/app_colors.dart';

class RapidButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final double? width;
  final double height;
  final double? borderRadius;
  final Widget? icon;
  final Widget? suffixIcon;
  final BorderSide? borderSide;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? elevation;
  final EdgeInsets? padding;

  const RapidButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 56,
    this.borderRadius,
    this.icon,
    this.suffixIcon,
    this.borderSide,
    this.fontSize,
    this.fontWeight,
    this.elevation = 0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (isLoading || onPressed == null) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? Colors.white,
        elevation: elevation,
        minimumSize: Size(width ?? 0, height.h),
        maximumSize: Size(width ?? double.infinity, height.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 28.r),
          side: borderSide ?? BorderSide.none,
        ),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
        disabledBackgroundColor:
            (backgroundColor ?? AppColors.primary).withValues(alpha: 0.6),
      ),
      child: isLoading
          ? SizedBox(
              height: 20.h,
              width: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  textColor ?? Colors.white,
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  SizedBox(width: 8.w),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize ?? 16.sp,
                    fontWeight: fontWeight ?? FontWeight.w700,
                    color: textColor ?? Colors.white,
                  ),
                ),
                if (suffixIcon != null) ...[
                  SizedBox(width: 8.w),
                  suffixIcon!,
                ],
              ],
            ),
    );
  }
}
