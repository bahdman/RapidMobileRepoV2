import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rapid_app/core/theme/app_colors.dart';

class DeleteScheduleBottomSheet extends StatelessWidget {
  const DeleteScheduleBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 40.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),

          // Close Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface2 : AppColors.btnGrey.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 24.w,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textVeryDarkGrey,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          Text(
            'Delete this schedule?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textVeryDarkGrey,
            ),
          ),

          SizedBox(height: 16.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'This action cannot be undone and all related reminders will be removed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark ? AppColors.darkTextSub : AppColors.black300,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          SizedBox(height: 40.h),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              minimumSize: Size(double.infinity, 64.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Yes, Delete',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: 12.h),

          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              minimumSize: Size(double.infinity, 64.h),
              backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.btnGrey.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textVeryDarkGrey,
              ),
            ),
          ),
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
