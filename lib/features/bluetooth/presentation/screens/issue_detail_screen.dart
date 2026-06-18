import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/theme/app_text_styles.dart';
import 'package:rapid_app/core/models/issue.dart';
import 'package:rapid_app/core/services/obd_service.dart';

class IssueDetailScreen extends StatelessWidget {
  final String issueCode;
  final DiagnosticIssue? initialIssue;

  const IssueDetailScreen({super.key, required this.issueCode, this.initialIssue});

  @override
  Widget build(BuildContext context) {
    if (initialIssue != null) {
      return _buildContent(context, initialIssue!);
    }

    return FutureBuilder<DiagnosticIssue>(
      future: context.read<ObdService>().getCodeDetail(issueCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmer(context);
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Failed to load issue details: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          return _buildContent(context, snapshot.data!);
        }
        return _buildShimmer(context);
      },
    );
  }

  Widget _buildContent(BuildContext context, DiagnosticIssue issue) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          // ── Fixed Header ───────────────────────────────────────────
          _buildHeader(context, issue),

          // ── Scrollable Content ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 10.h, bottom: 40.h),
              child: Column(
                children: [
                  _buildWhatsHappeningSection(issue),
                  SizedBox(height: 10.h),
                  _buildRepairCostSection(issue),
                  SizedBox(height: 10.h),
                  _buildPossibleCauseSection(issue),
                  SizedBox(height: 32.h),
                  Text('Rapid V1.2', style: AppTextStyles.rapidVersion),
                ],
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          Container(
            height: 280.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(34.r)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 24.h),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 44.w, height: 44.w, decoration: const BoxDecoration(color: Color(0xFFF0F0F0), shape: BoxShape.circle)),
                      Container(width: 44.w, height: 44.w, decoration: const BoxDecoration(color: Color(0xFFF0F0F0), shape: BoxShape.circle)),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Container(width: 150.w, height: 30.h, color: const Color(0xFFF0F0F0)),
                  SizedBox(height: 12.h),
                  Container(width: 250.w, height: 20.h, color: const Color(0xFFF0F0F0)),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    height: 180.h,
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(34.r)),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 80.h,
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(34.r)),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 220.h,
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(34.r)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms, color: Colors.white54),
    );
  }

  Widget _buildHeader(BuildContext context, DiagnosticIssue issue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _appbarButton(
                  svg: Assets.appbarBackBtn,
                  onTap: () => context.pop(),
                ),
                _appbarButton(
                  svg: Assets.share,
                  onTap: () {}, // Not implemented
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Text(
                  issue.code,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black400,
                  ),
                ),
                SizedBox(width: 16.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: issue.severity.color,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    issue.severity.label == 'HIGH'
                        ? 'HIGH THREATS'
                        : issue.severity.label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              issue.title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black400,
              ),
            ),
            if (issue.unsafeToDrive) ...[
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFEB),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(Assets.shieldRed, width: 24.w),
                    SizedBox(width: 12.w),
                    Text(
                      'Unsafe to Drive',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsHappeningSection(DiagnosticIssue issue) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s Happening',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            issue.description,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.black400,
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F6FE), // Light blue bg
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(Assets.bulbBlue),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        issue.recommendedAction,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black400,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairCostSection(DiagnosticIssue issue) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34.r),
      ),
      child: Row(
        children: [
          SvgPicture.asset(Assets.moneyBlue),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated Repair Cost',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                issue.estimatedCost,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPossibleCauseSection(DiagnosticIssue issue) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(Assets.bulbOrange),
              SizedBox(width: 12.w),
              Text(
                'Possible Cause',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ...issue.possibleCauses.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final cause = entry.value;
            // Split cause into title and description if it's in "Title: Description" format
            // or just use it as a title if not.
            final parts = cause.contains(': ')
                ? cause.split(': ')
                : [cause, ''];
            final title = parts[0];
            final detail = parts.length > 1 ? parts[1] : '';

            return Padding(
              padding: EdgeInsets.only(bottom: 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$index. $title',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  if (detail.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Text(
                        detail,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15.sp,
                          color: Colors.black,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _appbarButton({required String svg, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(width: 44.w, height: 44.w, child: SvgPicture.asset(svg)),
    );
  }
}
