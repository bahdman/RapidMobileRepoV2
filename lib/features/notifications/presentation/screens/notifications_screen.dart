import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_app_bar.dart';
import 'bloc/notification_bloc.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Add LoadNotifications event when screen is opened
    context.read<NotificationBloc>().add(LoadNotifications());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: RapidAppBar(
        title: 'Notifications',
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Mark all read',
              style: TextStyle(color: const Color(0xFF007AFF), fontSize: 14.sp),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationLoaded) {
            final notifications = state.notifications;
            if (notifications.isEmpty) {
              return const Center(child: Text('No notifications'));
            }
            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _notificationCard(context, item);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _notificationCard(BuildContext context, NotificationItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // ── Card body ──────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: SvgPicture.asset(_getIcon(item.type)),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Right padding reserves space for the dot / bin
                      Padding(
                        padding: EdgeInsets.only(right: 20.w),
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDarkGrey,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black300,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        item.time,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.greyPrimary,
                        ),
                      ),
                      // Leaves breathing room for the positioned bin
                      SizedBox(height: 28.h),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Grey overlay for READ items (excludes bin) ─────────────
          if (item.isRead)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),

          // ── Unread dot – top-right ──────────────────────────────────
          if (!item.isRead)
            Positioned(
              top: 16.h,
              right: 16.w,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // ── Bin – always above overlay, always tappable ─────────────
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: GestureDetector(
              onTap: () => context.read<NotificationBloc>().add(
                DeleteNotification(item.id),
              ),
              child: SvgPicture.asset(Assets.bin),
            ),
          ),
        ],
      ),
    );
  }

  String _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.critical:
        return Assets.danger;
      case NotificationType.settings:
        return Assets.settingsBlue;
      case NotificationType.info:
        return Assets.infoCircle;
      case NotificationType.success:
        return Assets.checkCircle;
    }
  }
}
