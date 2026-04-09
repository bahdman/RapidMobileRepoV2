import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_app_bar.dart';
import 'package:rapid_app/features/account/presentation/widgets/delete_schedule_bottom_sheet.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _scanSessions = [
    _ScheduleItem(
      title: 'Morning Check',
      subtitle: 'Monday & Thursday',
      time: '7:00pm',
    ),
    _ScheduleItem(title: 'Weekend Scan', subtitle: 'Saturday', time: '10:00am'),
  ];

  final _repairSessions = [
    _ScheduleItem(
      title: 'Oil Change',
      subtitle: 'March 15, 2026',
      time: '7:00pm',
      description: 'Due every 5,000 miles',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const RapidAppBar(title: 'Schedules'),
      body: Column(
        children: [
          // ── Fixed top: TabBar + banner ──
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
            child: Column(
              children: [
                // TabBar
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.black,
                    splashBorderRadius: BorderRadius.circular(100.r),
                    unselectedLabelColor: AppColors.grey600,
                    labelStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    padding: EdgeInsets.zero,
                    tabs: const [
                      Tab(text: 'Scan Sessions'),
                      Tab(text: 'Repair Sessions'),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Banner — fades when tab changes
                _buildCreateNewBanner(),
                SizedBox(height: 24.h),
              ],
            ),
          ),

          // ── Scrollable tab content ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSessionList(_scanSessions),
                _buildSessionList(_repairSessions),
              ],
            ),
          ),

          // ── Footer ──
          Padding(
            padding: EdgeInsets.only(bottom: 32.h, top: 16.h),
            child: Text(
              'Rapid V1.2',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.grey500,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNewBanner() {
    final isScan = _tabController.index == 0;
    final description = isScan
        ? "Set up auto scan sessions. We'll remind you to start scanning at your scheduled time."
        : "Schedule repair & maintenance reminders so you never miss a service appointment.";

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                // Fade description text when tab switches
                Text(
                      description,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    )
                    .animate(key: ValueKey(isScan))
                    .fadeIn(duration: 300.ms, curve: Curves.easeIn),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5.w,
              ),
            ),
            child: Icon(Icons.add, color: Colors.white, size: 24.w),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(List<_ScheduleItem> items) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final item = items[index];
        // Each card fades in with a staggered delay
        return _buildScheduleCard(item).animate().fadeIn(
          duration: 300.ms,
          delay: (60 * index).ms,
          curve: Curves.easeIn,
        );
      },
    );
  }

  Widget _buildScheduleCard(_ScheduleItem item) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(Assets.scheduleGrey),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.black300,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SvgPicture.asset(Assets.clock),
                          SizedBox(width: 4.w),
                          Text(
                            item.time,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.black300,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (item.description != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.black300,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showDeleteScheduleBottomSheet(context),
            icon: SvgPicture.asset(Assets.binRed),
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem {
  final String title;
  final String subtitle;
  final String time;
  final String? description;

  const _ScheduleItem({
    required this.title,
    required this.subtitle,
    required this.time,
    this.description,
  });
}
