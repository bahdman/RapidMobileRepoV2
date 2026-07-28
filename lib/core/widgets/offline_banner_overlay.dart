import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rapid_app/core/theme/app_colors.dart';

class OfflineBannerOverlay extends StatefulWidget {
  final Widget child;
  const OfflineBannerOverlay({super.key, required this.child});

  @override
  State<OfflineBannerOverlay> createState() => _OfflineBannerOverlayState();
}

class _OfflineBannerOverlayState extends State<OfflineBannerOverlay> {
  Timer? _timer;
  Timer? _restoredTimer;
  bool _isOffline = false;
  bool _showRestored = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkConnectivity(),
    );
  }

  Future<void> _checkConnectivity() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(milliseconds: 1500));
      final hasNet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (mounted) {
        if (_isOffline && hasNet) {
          // Transitioned from offline → online
          setState(() {
            _isOffline = false;
            _showRestored = true;
          });
          _restoredTimer?.cancel();
          _restoredTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() => _showRestored = false);
            }
          });
        } else if (_isOffline != !hasNet) {
          setState(() {
            _isOffline = !hasNet;
            if (_isOffline) _showRestored = false;
          });
        }
      }
    } catch (_) {
      if (mounted && !_isOffline) {
        setState(() {
          _isOffline = true;
          _showRestored = false;
        });
      }
    } finally {
      _isChecking = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restoredTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        widget.child,
        if (_isOffline)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 16.w,
            right: 16.w,
            child: Material(
              color: Colors.transparent,
              child:
                  Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C1E1E)
                              : const Color(0xFFFFF2F2),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: AppColors.tertiaryRed.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 16,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 20.w,
                              color: AppColors.tertiaryRed,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Offline Mode',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textVeryDarkGrey,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: _checkConnectivity,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.tertiaryRed,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'Retry',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .slideY(
                        begin: -1.5,
                        end: 0,
                        duration: 350.ms,
                        curve: Curves.easeOut,
                      )
                      .fadeIn(duration: 250.ms),
            ),
          )
        else if (_showRestored)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 16.w,
            right: 16.w,
            child: Material(
              color: Colors.transparent,
              child:
                  Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2C22)
                              : const Color(0xFFF2FFF6),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 16,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.wifi_rounded,
                              size: 20.w,
                              color: AppColors.green,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Connection Restored',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textVeryDarkGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .slideY(
                        begin: -1.5,
                        end: 0,
                        duration: 350.ms,
                        curve: Curves.easeOut,
                      )
                      .fadeIn(duration: 250.ms),
            ),
          ),
      ],
    );
  }
}
