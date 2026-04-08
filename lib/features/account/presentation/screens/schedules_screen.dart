import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rapid_app/core/widgets/rapid_app_bar.dart';
import 'package:rapid_app/features/account/presentation/widgets/delete_schedule_bottom_sheet.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const RapidAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan schedules',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 24.h),

            // Toggle Switch
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Row(
                children: [
                   _buildToggleItem(0, 'Scan Sessions'),
                   _buildToggleItem(1, 'Repair Sessions'),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Create New Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFF007AFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 24.w),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create a scan schedule',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E40AF),
                          ),
                        ),
                        Text(
                          'Automate your vehicle diagnostics',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Schedules List
            _buildScheduleItem(
              title: 'Full Diagnostic Scan',
              time: '10:00 AM',
              date: 'Every Monday',
              frequency: 'Weekly',
            ),
            SizedBox(height: 16.h),
            _buildScheduleItem(
              title: 'Quick Engine Check',
              time: '2:30 PM',
              date: '15th Oct, 2024',
              frequency: 'One-time',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(int index, String title) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(100.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.black : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleItem({
    required String title,
    required String time,
    required String date,
    required String frequency,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14.w, color: const Color(0xFF9CA3AF)),
                    SizedBox(width: 4.w),
                    Text(
                      time,
                      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                    ),
                    SizedBox(width: 12.w),
                    Icon(Icons.calendar_today, size: 14.w, color: const Color(0xFF9CA3AF)),
                    SizedBox(width: 4.w),
                    Text(
                      date,
                      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  frequency,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showDeleteScheduleBottomSheet(context),
            icon: Icon(Icons.more_vert, color: const Color(0xFF9CA3AF), size: 24.w),
          ),
        ],
      ),
    );
  }
}
