import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/theme/app_text_styles.dart';
import 'package:rapid_app/core/models/issue.dart';

class ScanReportScreen extends StatelessWidget {
  final DiagnosticIssue issue;
  final DateTime date;

  const ScanReportScreen({super.key, required this.issue, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          _buildHeader(context),

          // ── Scrollable Content ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 10.h, bottom: 40.h),
              child: Column(
                children: [
                  // ── Status Banner ──────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 20.h,
                        horizontal: 16.w,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEFEB),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(Assets.shieldRed),
                          SizedBox(width: 12.w),
                          Flexible(
                            child: Text(
                              issue.title,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // ── Diagnostic Sections ───────────────────────────
                  _buildSection(
                    context: context,
                    title: "What's Happened",
                    content: issue.description,
                    child: _buildRecommendedAction(context),
                  ),
                  SizedBox(height: 12.h),
                  _buildRepairCostSection(context),
                  SizedBox(height: 12.h),
                  _buildPossibleCauseSection(context),

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

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? AppColors.darkSurface : AppColors.scaffoldBg;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.black400;
    final subtitleColor = isDark ? AppColors.darkTextSub : AppColors.black200;
    return Container(
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 14.h),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _appbarButton(
                  isRoundedRectButton: false,
                  context: context,
                  svg: Assets.arrowBack,
                  onTap: () => context.pop(),
                ),
                Flexible(
                  child: Text(
                    'Scan Report',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ),
                _appbarButton(
                  isRoundedRectButton: true,
                  context: context,
                  svg: Assets.shareOutline,
                  onTap: () {},
                ),
              ],
            ),
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
    Widget? child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final titleColor = isDark ? AppColors.darkTextPrimary : Colors.black;
    final textColor = isDark ? AppColors.darkTextSub : AppColors.black400;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(34.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: textColor,
              height: 1.5,
            ),
          ),
          if (child != null) ...[SizedBox(height: 24.h), child],
        ],
      ),
    );
  }

  Widget _buildRecommendedAction(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionBg = isDark ? AppColors.darkSurface2 : const Color(0xFFF1F6FE);
    final titleColor = isDark ? AppColors.darkTextPrimary : Colors.black;
    final textColor = isDark ? AppColors.darkTextSub : AppColors.black400;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: actionBg,
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
                    color: titleColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  issue.recommendedAction,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairCostSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : Colors.black;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: cardBg,
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
                  color: textColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                issue.estimatedCost,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPossibleCauseSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final titleColor = isDark ? AppColors.darkTextPrimary : Colors.black;
    final causeTextColor = isDark ? AppColors.darkTextPrimary : Colors.black;
    final detailTextColor = isDark
        ? AppColors.darkTextSub
        : const Color(0xFF4B5563);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardBg,
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
                  color: titleColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ...issue.possibleCauses.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final cause = entry.value;
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
                      color: causeTextColor,
                    ),
                  ),
                  if (detail.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Text(
                        detail,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: detailTextColor,
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

  Widget _appbarButton({
    required BuildContext context,
    required String svg,
    required VoidCallback onTap,
    required bool isRoundedRectButton,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isRoundedRectButton ? 16.r : 100.r),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.w,
            color: isDark ? AppColors.grey800 : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(
            isRoundedRectButton ? 16.r : 100.r,
          ),
        ),
        padding: EdgeInsets.all(10.0),
        child: SvgPicture.asset(
          svg,
          colorFilter: isDark
              ? ColorFilter.mode(AppColors.darkTextPrimary, BlendMode.srcIn)
              : null,
        ),
      ),
    );
  }
}
