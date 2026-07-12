import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/services/push_notification_service.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/route_names.dart';

class NotificationBannerOverlay extends StatefulWidget {
  final Widget child;
  const NotificationBannerOverlay({super.key, required this.child});

  @override
  State<NotificationBannerOverlay> createState() =>
      _NotificationBannerOverlayState();
}

class _NotificationBannerOverlayState
    extends State<NotificationBannerOverlay> {
  StreamSubscription<RemoteMessage>? _subscription;
  RemoteMessage? _activeMessage;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _subscription = context
          .read<PushNotificationService>()
          .foregroundMessageStream
          .listen(_showBanner);
    });
  }

  void _showBanner(RemoteMessage message) {
    // Don't show if there's no useful content
    if (message.notification?.title == null && message.notification?.body == null) return;
    _dismissTimer?.cancel();
    setState(() => _activeMessage = message);
    _dismissTimer = Timer(const Duration(seconds: 5), _dismiss);
  }

  void _dismiss() {
    if (mounted) setState(() => _activeMessage = null);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_activeMessage != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 16.w,
            right: 16.w,
            child: _NotificationBannerCard(
              message: _activeMessage!,
              onTap: () {
                _dismiss();
                context.pushNamed(AppRoutes.notification);
              },
              onDismiss: _dismiss,
            )
                .animate()
                .slideY(
                  begin: -2.0,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 250.ms),
          ),
      ],
    );
  }
}

class _NotificationBannerCard extends StatelessWidget {
  final RemoteMessage message;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationBannerCard({
    required this.message,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta != null && details.primaryDelta! < -5) {
            onDismiss();
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // App icon pill
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.notifications_rounded,
                  color: AppColors.primary,
                  size: 22.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    if (body.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMediumGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(Icons.close_rounded,
                    size: 18.w, color: AppColors.grey600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
