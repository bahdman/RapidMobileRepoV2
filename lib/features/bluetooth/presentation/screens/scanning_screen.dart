import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/features/bluetooth/presentation/screens/bloc/obd_scan_bloc.dart';
import 'package:rapid_app/route_names.dart';

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({super.key});

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.linear);

    _controller.forward();
    context.read<ObdScanBloc>().add(StartObdScan());
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) context.pushReplacementNamed(AppRoutes.vehicleReport);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            final pct = (_progress.value * 100).round().clamp(1, 100);
            return Column(
              children: [
                const Spacer(),

                // ── Pulsating Rings & Progress ────────────────────────
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Ring 2
                      _pulsatingRing(size: 300.w, delay: 400.ms, opacity: 0.3),
                      // Outer Ring 1
                      _pulsatingRing(size: 240.w, delay: 0.ms, opacity: 0.4),

                      // Progress Arc & Inner Circle
                      SizedBox(
                        width: 156.w,
                        height: 156.w,
                        child: CustomPaint(
                          painter: _ScanPainter(progress: _progress.value),
                          child: Center(child: _innerCircle(pct)),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Status text ───────────────────────────────────────
                Text(
                  'Reading Vehicle data',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textVeryDarkGrey,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'This usually takes about 30 seconds',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textMediumGrey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 60.h),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
          },
        ),
      ),
    );
  }

  Widget _pulsatingRing({
    required double size,
    required Duration delay,
    required double opacity,
  }) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(
                alpha: opacity,
              ), // Use brand primary for consistency
              width: 2.w,
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.1, 1.1),
          duration: 1200.ms,
          delay: delay,
          curve: Curves.easeInOut,
        )
        .fade(
          begin: opacity * 0.4,
          end: opacity,
          duration: 1200.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _innerCircle(int pct) {
    return Container(
      width: 126.w,
      height: 126.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FA),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$pct%',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textVeryDarkGrey,
              height: 1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Scanning..',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textMediumGrey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }
}

class _ScanPainter extends CustomPainter {
  final double progress;

  _ScanPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track (faint background circle)
    final trackPaint = Paint()
      ..color = const Color(0xFFE8F1F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.w;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = AppColors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.w
      ..strokeCap = StrokeCap.round;

    // Start from the top (-math.pi / 2 or 270 degrees)
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ScanPainter old) => old.progress != progress;
}
