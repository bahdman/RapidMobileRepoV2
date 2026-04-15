import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  final bool isOutline;
  final bool isFullWidthLeading;

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
    this.isOutline = false,
    this.isFullWidthLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget buttonChild = isLoading
        ? SizedBox(
            height: 20.h,
            width: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? (isOutline ? Colors.black : Colors.white),
              ),
            ),
          )
        : isFullWidthLeading
        ? Stack(
            alignment: Alignment.center,
            children: [
              if (icon != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: icon!,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize ?? 16.sp,
                      fontWeight: fontWeight ?? FontWeight.w700,
                      color:
                          textColor ??
                          (isOutline ? Colors.black : Colors.white),
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    SizedBox(width: 8.w),
                    suffixIcon!,
                  ],
                ],
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, SizedBox(width: 8.w)],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize ?? 16.sp,
                  fontWeight: fontWeight ?? FontWeight.w700,
                  color: textColor ?? (isOutline ? Colors.black : Colors.white),
                ),
              ),
              if (suffixIcon != null) ...[SizedBox(width: 8.w), suffixIcon!],
            ],
          );

    if (isOutline) {
      return OutlinedButton(
            onPressed: (isLoading || onPressed == null) ? null : onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: backgroundColor ?? Colors.transparent,
              foregroundColor: textColor ?? Colors.black,
              minimumSize: Size(width ?? 0, height.h),
              maximumSize: Size(width ?? double.infinity, height.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 28.r),
              ),
              side:
                  borderSide ??
                  BorderSide(color: AppColors.grey200, width: 1.5),
              padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
            ),
            child: buttonChild,
          )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            curve: Curves.easeOutQuart,
          );
    }

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
          disabledBackgroundColor: (backgroundColor ?? AppColors.primary)
              .withValues(alpha: 0.6),
        ),
        child: buttonChild,
      )
      ..animate()
          .fadeIn(delay: 400.ms)
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}
