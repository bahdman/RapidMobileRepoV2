import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';

class RapidAuthAnimation extends StatelessWidget {
  const RapidAuthAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circleBg = isDark ? AppColors.darkSurface : Colors.white;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple circles
          ...List.generate(3, (index) {
            return Container(
                  width: 150.w,
                  height: 150.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(2.0, 2.0),
                  duration: 2.seconds,
                  delay: (index * 600).ms,
                  curve: Curves.easeOut,
                )
                .fadeOut(duration: 2.seconds, curve: Curves.easeOut);
          }),

          // Logo in the middle
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: circleBg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child:
                Image.asset(
                      Assets.rapidLogoBig,
                      color: AppColors.primary,
                      width: 60.w,
                      height: 60.w,
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2),
                      duration: 1200.ms,
                      curve: Curves.easeInOut,
                    ),
          ),
        ],
      ),
    );
  }
}

class RapidAuthLoadingOverlay extends StatelessWidget {
  final String message;
  final bool isVisible;
  const RapidAuthLoadingOverlay({
    super.key,
    required this.message,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayBg = isDark
        ? AppColors.darkScaffoldBg.withValues(alpha: 0.97)
        : Colors.white.withValues(alpha: 0.95);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: overlayBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const RapidAuthAnimation(),
          SizedBox(height: 80.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
