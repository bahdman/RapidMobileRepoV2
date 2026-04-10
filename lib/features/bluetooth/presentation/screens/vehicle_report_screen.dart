import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_app_bar.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/core/config/issue_database.dart';
import 'package:rapid_app/route_names.dart';

class VehicleReportScreen extends StatelessWidget {
  const VehicleReportScreen({super.key});

  static const int _score = 72;

  static const _issues = [
    _Issue(
      'P0420',
      'Critical',
      'Software Incapability with TCM',
      _Severity.critical,
    ),
    _Issue(
      'P0171',
      'WARNING',
      'Software Incapability with TCM',
      _Severity.warning,
    ),
    _Issue('P0456', 'INFO', 'Software Incapability with TCM', _Severity.info),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const RapidAppBar(title: 'Vehicle Report', showBackButton: false),

      body: SafeArea(
        child: Column(
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: AppColors.borderColor),
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
                            child: CustomPaint(
                              painter: _GaugePainter(score: _score),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$_score',
                                      style: TextStyle(
                                        fontSize: 56.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.yellow,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      'Fair',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF9EA6B0),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // ── Detected Issues header ─────────────────────────
                    Text(
                      'Detected Issues (${_issues.length})',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textVeryDarkGrey,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // ── Issue cards ────────────────────────────────────
                    ..._issues.map((issue) {
                      return _issueCard(
                        issue,
                        onTap: () {
                          final diagnosticIssue = IssueDatabase.getIssue(
                            issue.code,
                          );
                          if (diagnosticIssue != null) {
                            context.pushNamed(
                              AppRoutes.issueDetail,
                              extra: diagnosticIssue,
                            );
                          }
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
                onPressed: () => context.go('/${AppRoutes.home}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _issueCard(_Issue issue, {VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
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
                          issue.label,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: issue.severity.labelColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      issue.description,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
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

// ── Data models ──────────────────────────────────────────────────────────────

enum _Severity { critical, warning, info }

extension _SeverityX on _Severity {
  Color get bgColor => switch (this) {
    _Severity.critical => const Color(0xFFFFD3CC),
    _Severity.warning => const Color(0xFFFFF8CD),
    _Severity.info => const Color(0xFFCCDCEF),
  };

  Color get labelColor => switch (this) {
    _Severity.critical => AppColors.red,
    _Severity.warning => AppColors.yellow,
    _Severity.info => AppColors.blue,
  };

  String get icon => switch (this) {
    _Severity.critical => Assets.danger,
    _Severity.warning => Assets.warningTriangle,
    _Severity.info => Assets.infoCircleBlue,
  };
}

class _Issue {
  final String code;
  final String label;
  final String description;
  final _Severity severity;

  const _Issue(this.code, this.label, this.description, this.severity);
}

// ── Health gauge painter ─────────────────────────────────────────────────────

class _GaugePainter extends CustomPainter {
  final int score;

  const _GaugePainter({required this.score});

  // Full 360° circle starting from the top (-90°)
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

    // Fill (Bright Yellow/Gold as per design)
    final fillRad = totalRad * (score / 100);
    final fillPaint = Paint()
      ..color = AppColors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.w
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startRad, fillRad, false, fillPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.score != score;
}
