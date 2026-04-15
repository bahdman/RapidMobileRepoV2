import 'dart:math' as math;
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
            height: 24.h,
            width: 24.h,
            child: _GradientSpinner(
              color: textColor ?? (isOutline ? Colors.black : Colors.white),
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
          disabledBackgroundColor: isLoading
              ? _darkenColor(backgroundColor ?? AppColors.primary, 0.15)
              : (backgroundColor ?? AppColors.primary).withValues(alpha: 0.6),
        ),
        child: buttonChild,
      )
      ..animate()
          .fadeIn(delay: 400.ms)
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Color _darkenColor(Color color, [double amount = .1]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

// ── Premium Loading Spinner ──────────────────────────────────────────────────
class _GradientSpinner extends StatefulWidget {
  final Color color;

  const _GradientSpinner({required this.color});

  @override
  State<_GradientSpinner> createState() => _GradientSpinnerState();
}

class _GradientSpinnerState extends State<_GradientSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        painter: _GradientSpinnerPainter(color: widget.color),
      ),
    );
  }
}

class _GradientSpinnerPainter extends CustomPainter {
  final Color color;

  _GradientSpinnerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0.0), color],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
