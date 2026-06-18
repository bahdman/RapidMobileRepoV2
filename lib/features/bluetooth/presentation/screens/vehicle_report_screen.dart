import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/config/issue_database.dart';
import 'package:rapid_app/core/models/issue.dart';
import 'package:rapid_app/core/services/obd_service.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_app_bar.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/route_names.dart';

class VehicleReportScreen extends StatefulWidget {
  /// The real OBD scan result passed from ScanningScreen.
  /// Falls back to a demo result when null (e.g. when navigated to directly).
  final ObdScanResult? scanResult;

  const VehicleReportScreen({super.key, this.scanResult});

  @override
  State<VehicleReportScreen> createState() => _VehicleReportScreenState();
}

class _VehicleReportScreenState extends State<VehicleReportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  /// Resolved result — either real or a demo fallback.
  late final ObdScanResult _result;

  /// Issues resolved from the local IssueDatabase by DTC code.
  late final List<DiagnosticIssue> _resolvedIssues;

  @override
  void initState() {
    super.initState();

    _result = widget.scanResult ?? _demoResult();
    _resolvedIssues = _result.dtcCodes
        .map((code) => IssueDatabase.getIssue(code))
        .whereType<DiagnosticIssue>()
        .toList();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: _result.healthScore.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
                    _buildHealthScoreCard(),

                    SizedBox(height: 24.h),

                    // ── Live Telemetry card ────────────────────────────
                    if (_hasTelemetry) _buildTelemetryCard(),

                    if (_hasTelemetry) SizedBox(height: 24.h),

                    // ── Detected Issues ────────────────────────────────
                    Text(
                      _resolvedIssues.isEmpty
                          ? 'No Issues Detected 🎉'
                          : 'Detected Issues (${_resolvedIssues.length})',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textVeryDarkGrey,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    if (_resolvedIssues.isEmpty) _buildNoIssuesCard(),

                    ..._resolvedIssues.map(
                      (issue) => _issueCard(
                        issue,
                        onTap: () => context.pushNamed(
                          AppRoutes.issueDetail,
                          extra: issue,
                        ),
                      ),
                    ),

                    // ── Unknown DTCs (not in local DB) ─────────────────
                    ..._unknownCodes.map((code) => _unknownCodeCard(code)),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // ── Back to Dashboard ──────────────────────────────────────
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
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
      ),
    );
  }

  // ── Section builders ──────────────────────────────────────────────────────

  Widget _buildHealthScoreCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
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
            child: AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                final score = _scoreAnimation.value;
                final label = _scoreLabel(score.toInt());
                return CustomPaint(
                  painter: _GaugePainter(
                    score: score,
                    color: _scoreColor(score.toInt()),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${score.toInt()}',
                          style: TextStyle(
                            fontSize: 56.sp,
                            fontWeight: FontWeight.w700,
                            color: _scoreColor(score.toInt()),
                            height: 1,
                          ),
                        ),
                        Text(
                          label,
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
    );
  }

  Widget _buildTelemetryCard() {
    final t = _result.telemetry;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Telemetry',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textVeryDarkGrey,
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: [
              if (t.rpm != null)
                _telemetryChip('RPM', '${t.rpm!.toInt()}', ''),
              if (t.speedKmh != null)
                _telemetryChip('Speed', '${t.speedKmh!.toInt()}', 'km/h'),
              if (t.coolantTempC != null)
                _telemetryChip(
                    'Coolant', '${t.coolantTempC!.toInt()}', '°C'),
              if (t.engineLoadPct != null)
                _telemetryChip(
                    'Engine Load', '${t.engineLoadPct!.toInt()}', '%'),
              if (t.throttlePct != null)
                _telemetryChip(
                    'Throttle', '${t.throttlePct!.toInt()}', '%'),
              if (t.fuelLevelPct != null)
                _telemetryChip(
                    'Fuel Level', '${t.fuelLevelPct!.toInt()}', '%'),
              if (t.intakeTempC != null)
                _telemetryChip(
                    'Intake Temp', '${t.intakeTempC!.toInt()}', '°C'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _telemetryChip(String label, String value, String unit) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.hintGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textVeryDarkGrey,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMediumGrey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoIssuesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: AppColors.green, size: 40.w),
          SizedBox(height: 12.h),
          Text(
            'Your vehicle is in good health!',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.green,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'No fault codes were found during this scan.',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textMediumGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _issueCard(DiagnosticIssue issue, {VoidCallback? onTap}) {
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
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: issue.severity.bgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: SvgPicture.asset(issue.severity.icon),
              ),
              SizedBox(width: 14.w),
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
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: issue.severity.color,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            issue.severity.label,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
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
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    if (issue.unsafeToDrive) ...[
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(Icons.warning_rounded,
                              color: AppColors.red, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'Unsafe to drive',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
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

  /// Card for DTC codes that exist in the adapter data but aren't in our local DB.
  Widget _unknownCodeCard(String code) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.help_outline_rounded,
                  size: 20.w, color: AppColors.grey600),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textVeryDarkGrey,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Unknown code — not in local database',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textMediumGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get _hasTelemetry {
    final t = _result.telemetry;
    return t.rpm != null ||
        t.speedKmh != null ||
        t.coolantTempC != null ||
        t.engineLoadPct != null ||
        t.throttlePct != null ||
        t.fuelLevelPct != null ||
        t.intakeTempC != null;
  }

  List<String> get _unknownCodes => _result.dtcCodes
      .where((code) => IssueDatabase.getIssue(code) == null)
      .toList();

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.green;
    if (score >= 50) return AppColors.yellow;
    return AppColors.red;
  }

  String _scoreLabel(int score) {
    if (score >= 80) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Poor';
  }

  /// Demo result used when the screen is accessed directly without a real scan.
  ObdScanResult _demoResult() => const ObdScanResult(
        dtcCodes: ['P0420', 'P0171', 'P0456'],
        healthScore: 72,
        telemetry: ObdTelemetrySnapshot(
          rpm: 850,
          speedKmh: 0,
          coolantTempC: 88,
          engineLoadPct: 22,
          throttlePct: 0,
          fuelLevelPct: 64,
          intakeTempC: 31,
        ),
      );
}

// ── Gauge painter ─────────────────────────────────────────────────────────────

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

    canvas.drawArc(
      rect,
      startRad,
      totalRad,
      false,
      Paint()
        ..color = const Color(0xFFF2F6FA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.w
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      rect,
      startRad,
      totalRad * (score / 100),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.w
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.score != score || old.color != color;
}
