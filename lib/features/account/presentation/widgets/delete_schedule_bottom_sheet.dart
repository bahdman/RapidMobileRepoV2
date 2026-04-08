import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rapid_app/core/theme/app_colors.dart';

class DeleteScheduleBottomSheet extends StatelessWidget {
  const DeleteScheduleBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.btnGrey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 20.w, color: AppColors.textVeryDarkGrey),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Delete this schedule?',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textVeryDarkGrey,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'This action cannot be undone and all related reminders will be removed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textMediumGrey,
              height: 1.5,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Yes, Delete',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              minimumSize: Size(double.infinity, 56.h),
              backgroundColor: AppColors.btnGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textVeryDarkGrey,
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

Future<bool?> showDeleteScheduleBottomSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const DeleteScheduleBottomSheet(),
  );
}
