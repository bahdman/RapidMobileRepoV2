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
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();

    // Continuous ring animation — independent of scan progress.
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // Start the real OBD scan.
    context.read<ObdScanBloc>().add(StartObdScan());
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ObdScanBloc, ObdScanState>(
      listener: (context, state) {
        if (state is ObdScanComplete) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.pushReplacementNamed(
                AppRoutes.vehicleReport,
                extra: state.result,
              );
            }
          });
        } else if (state is ObdScanFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) context.pop();
          });
        }
      },
      child: BlocBuilder<ObdScanBloc, ObdScanState>(
        builder: (context, state) {
          final double progress = state is ObdScanInProgress
              ? state.progress
              : state is ObdScanComplete
              ? 1.0
              : 0.0;
          final int pct = (progress * 100).round().clamp(1, 100);

          return Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            body: SafeArea(
              child: Column(
                children: [
                  const Spacer(),

                  // ── Pulsating Rings + Progress Arc ───────────────────
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _pulsatingRing(
                          size: 300.w,
                          delay: 400.ms,
                          opacity: 0.3,
                        ),
                        _pulsatingRing(
                          size: 240.w,
                          delay: 0.ms,
                          opacity: 0.4,
                        ),
                        SizedBox(
                          width: 156.w,
                          height: 156.w,
                          child: CustomPaint(
                            painter: _ScanPainter(progress: progress),
                            child: Center(child: _innerCircle(pct, state)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Status text ──────────────────────────────────────
                  _buildStatusText(state),
                  SizedBox(height: 60.h),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusText(ObdScanState state) {
    String title = 'Reading Vehicle Data';
    String subtitle = 'This usually takes about 30 seconds';

    if (state is ObdScanInProgress) {
      final pct = (state.progress * 100).round();
      if (pct < 30) {
        title = 'Detecting Supported Sensors';
        subtitle = 'Checking what your vehicle supports...';
      } else if (pct < 75) {
        title = 'Reading Live Telemetry';
        subtitle = 'Collecting RPM, speed, temperature...';
      } else {
        title = 'Reading Fault Codes';
        subtitle = 'Checking for diagnostic trouble codes...';
      }
    } else if (state is ObdScanComplete) {
      title = 'Scan Complete';
      subtitle = '${state.result.dtcCodes.length} issue(s) found';
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textVeryDarkGrey,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textMediumGrey,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _pulsatingRing({
    required double size,
    required Duration delay,
    required double opacity,
  }) {
    return AnimatedBuilder(
      animation: _ringController,
      builder: (context, child) {
        final scale = 0.8 + _ringController.value * 0.3;
        final fadeVal = opacity * (0.4 + _ringController.value * 0.6);
        return Opacity(
          opacity: fadeVal.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(opacity),
                  width: 2.w,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _innerCircle(int pct, ObdScanState state) {
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
            state is ObdScanComplete ? 'Done!' : 'Scanning..',
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

// ── Progress arc painter ──────────────────────────────────────────────────────

class _ScanPainter extends CustomPainter {
  final double progress;

  const _ScanPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFE8F1F9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.w,
    );

    // Progress arc
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = AppColors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.w
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ScanPainter old) => old.progress != progress;
}
