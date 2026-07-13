import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_app_bar.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/core/models/issue.dart';
import 'package:rapid_app/features/bluetooth/presentation/screens/bloc/obd_scan_bloc.dart';
import 'package:rapid_app/route_names.dart';

class VehicleReportScreen extends StatefulWidget {
  const VehicleReportScreen({super.key});

  @override
  State<VehicleReportScreen> createState() => _VehicleReportScreenState();
}

class _VehicleReportScreenState extends State<VehicleReportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  int _score = 100;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );

    // Initial setup based on current bloc state
    final scanState = context.read<ObdScanBloc>().state;
    if (scanState is ObdScanLoaded) {
      _score = scanState.healthScore;
      _scoreAnimation = Tween<double>(begin: 0, end: _score.toDouble()).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
      );
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 70) return 'Fair';
    return 'Poor';
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppColors.green;
    if (score >= 70) return AppColors.yellow;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffoldBg : AppColors.scaffoldBg,
      appBar: const RapidAppBar(title: 'Vehicle Report', showBackButton: false),
      body: SafeArea(
        child: BlocListener<ObdScanBloc, ObdScanState>(
          listener: (context, state) {
            if (state is ObdScanLoaded) {
              setState(() {
                _score = state.healthScore;
                _scoreAnimation = Tween<double>(
                  begin: 0,
                  end: _score.toDouble(),
                ).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
                );
              });
              _controller.forward(from: 0);
            }
          },
          child: BlocBuilder<ObdScanBloc, ObdScanState>(
            builder: (context, state) {
              if (state is ObdScanning || state is ObdScanInitial) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 24.h),
                      Text(
                        'Generating Report...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textVeryDarkGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is ObdScanError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48.w, color: AppColors.red),
                        SizedBox(height: 16.h),
                        Text(
                          'Failed to generate scan report',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textVeryDarkGrey,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textMediumGrey,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        RapidButton(
                          text: 'Back to Dashboard',
                          onPressed: () {
                            int count = 0;
                            Navigator.of(context).popUntil((_) => count++ >= 2);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              final List<DiagnosticIssue> issues =
                  state is ObdScanLoaded ? state.issues : [];

              return Column(
                children: [
                  SizedBox(height: 20.h),
                  // ── Scan Complete badge ────────────────────────────────────
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(Assets.checkCircleGreen),
                        SizedBox(width: 8.w),
                        Text(
                          'Scan Complete',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Health Score card ──────────────────────────────
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: 32.h,
                              horizontal: 20.w,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.borderColor,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'HEALTH SCORE',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.hintGrey,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                SizedBox(
                                  width: 200.w,
                                  height: 180.w,
                                  child: AnimatedBuilder(
                                    animation: _scoreAnimation,
                                    builder: (context, child) {
                                      final scoreVal = _scoreAnimation.value.toInt();
                                      final scoreColor = _getScoreColor(scoreVal);
                                      return CustomPaint(
                                        painter: _GaugePainter(
                                          score: _scoreAnimation.value,
                                          color: scoreColor,
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '$scoreVal',
                                                style: TextStyle(
                                                  fontSize: 56.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: scoreColor,
                                                  height: 1,
                                                ),
                                              ),
                                              Text(
                                                _getScoreLabel(scoreVal),
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: const Color(0xFF9EA6B0),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 32.h),

                          // ── Detected Issues header ─────────────────────────
                          Text(
                            'Detected Issues (${issues.length})',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textVeryDarkGrey,
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // ── Issue cards ────────────────────────────────────
                          if (issues.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.h),
                              child: Center(
                                child: Text(
                                  'No issues detected!',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textMediumGrey,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...issues.map((issue) {
                              return _issueCard(
                                issue,
                                onTap: () {
                                  context.pushNamed(
                                    AppRoutes.issueDetail,
                                    extra: issue,
                                  );
                                },
                              );
                            }),

                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),

                  // ── Back to Dashboard button ───────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                    child: RapidButton(
                      text: 'Back to Dashboard',
                      onPressed: () {
                        int count = 0;
                        Navigator.of(context).popUntil((_) => count++ >= 2);
                      },
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
            },
          ),
        ),
      ),
    );
  }

  Widget _issueCard(DiagnosticIssue issue, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: isDark ? Border.all(color: AppColors.darkBorder) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.03),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: issue.severity.bgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: SvgPicture.asset(issue.severity.icon),
              ),
              SizedBox(width: 14.w),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          issue.code,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          issue.severity.label == 'HIGH' ? 'CRITICAL' : issue.severity.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: issue.severity.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      issue.title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),

              SvgPicture.asset(Assets.arrowRight),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Health gauge painter ─────────────────────────────────────────────────────

class _GaugePainter extends CustomPainter {
  final double score;
  final Color color;

  const _GaugePainter({required this.score, required this.color});

  static const double _startDeg = -90;
  static const double _sweepDeg = 360;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startRad = _startDeg * math.pi / 180;
    final totalRad = _sweepDeg * math.pi / 180;

    // Track
    final trackPaint = Paint()
      ..color = const Color(0xFFF2F6FA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.w
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startRad, totalRad, false, trackPaint);

    // Fill
    final fillRad = totalRad * (score / 100);
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.w
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startRad, fillRad, false, fillPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.score != score || old.color != color;
}
