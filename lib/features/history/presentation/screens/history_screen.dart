import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/config/issue_database.dart';
import 'package:rapid_app/core/models/issue.dart';
import 'package:rapid_app/core/models/scan_history.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/route_names.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Critical', 'Warning', 'Low'];

  final List<ScanHistory> mockHistory = [
    ScanHistory(
      id: '1',
      date: DateTime(2026, 3, 6, 14, 34),
      issueCode: 'P0420',
      severity: DiagnosticSeverity.critical,
    ),
    ScanHistory(
      id: '2',
      date: DateTime(2026, 3, 6, 14, 12),
      issueCode: 'P0171',
      severity: DiagnosticSeverity.warning,
    ),
    ScanHistory(
      id: '3',
      date: DateTime(2026, 3, 1, 14, 34),
      issueCode: 'P0171',
      severity: DiagnosticSeverity.warning,
    ),
    ScanHistory(
      id: '4',
      date: DateTime(2026, 2, 21, 23, 15),
      issueCode: 'P0456',
      severity: DiagnosticSeverity.info,
    ),
  ];

  List<ScanHistory> get filteredHistory {
    if (selectedFilter == 'All') return mockHistory;
    return mockHistory.where((item) {
      final severityStr = item.severity == DiagnosticSeverity.info
          ? 'Low'
          : item.severity.name.substring(0, 1).toUpperCase() +
                item.severity.name.substring(1);
      return severityStr.toLowerCase() == selectedFilter.toLowerCase();
    }).toList();
  }

  Map<String, List<ScanHistory>> get groupedHistory {
    final Map<String, List<ScanHistory>> grouped = {};
    for (final item in filteredHistory) {
      final dateKey = DateFormat('MMM d, yyyy').format(item.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupedHistory;
    final dateKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildHeader(),
              ),
            ),
            _buildFilterBar(),
            Expanded(
              child: filteredHistory.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                      ).copyWith(bottom: 120.h, top: 10.h),
                      itemCount: dateKeys.length,
                      itemBuilder: (context, index) {
                        final dateKey = dateKeys[index];
                        final items = grouped[dateKey]!;
                        return _buildDateGroup(dateKey, items);
                      },
                    ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Text(
        'Scan History',
        style: TextStyle(
          fontSize: 21.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.black400,
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 48.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedFilter = filter),
              backgroundColor: AppColors.btnGrey,
              selectedColor: AppColors.primary,
              showCheckmark: false,
              labelPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 2.h,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.black400,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14.sp,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
                side: BorderSide(color: AppColors.borderColor),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateGroup(String date, List<ScanHistory> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xffFAFAFA),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.grey200, width: 0.6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black400,
                  ),
                ),
              ),
              Divider(color: AppColors.grey200, thickness: 1, height: 0.6),
              ...items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _buildHistoryItem(item),
                    if (idx != items.length - 1)
                      Divider(
                        color: AppColors.grey200,
                        thickness: 1,
                        height: 0.6,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(ScanHistory history) {
    final issue = IssueDatabase.getIssue(history.issueCode);
    if (issue == null) return const SizedBox.shrink();

    String iconPath;

    switch (history.severity) {
      case DiagnosticSeverity.critical:
        iconPath = Assets.danger;
        break;
      case DiagnosticSeverity.warning:
        iconPath = Assets.warningTriangle;
        break;
      case DiagnosticSeverity.info:
        iconPath = Assets.infoCircleBlue;
        break;
    }

    return InkWell(
      onTap: () => context.pushNamed(
        AppRoutes.scanReport,
        extra: {'issue': issue, 'date': history.date},
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            SvgPicture.asset(iconPath),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Scan Report',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black400,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        DateFormat('h:mm a').format(history.date),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    issue.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            SvgPicture.asset(Assets.arrowRight),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64.w, color: AppColors.hintGrey),
          SizedBox(height: 16.h),
          Text(
            'No scan results found',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.hintGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
