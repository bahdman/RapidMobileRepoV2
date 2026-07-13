import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/services/push_notification_service.dart';
import 'package:rapid_app/core/utils/shared_prefs_helper.dart';
import 'package:rapid_app/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (mounted) {
        setState(() {
          _time = elapsed.inMicroseconds / 1000000.0;
        });
      }
    });
    _ticker.start();

    // Navigate after 3 seconds (reduced from 5 for better UX)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final prefs = context.read<SharedPrefsHelper>();
        final hasCompletedOnboarding = prefs.hasCompletedOnboarding();
        final token = prefs.getToken();

        if (token != null && token.isNotEmpty) {
          // Re-register push token for returning authenticated users
          context
              .read<PushNotificationService>()
              .registerDevice();
          context.goNamed(AppRoutes.home);
        } else if (hasCompletedOnboarding) {
          context.goNamed(AppRoutes.auth);
        } else {
          context.goNamed(AppRoutes.onboarding);
        }
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Widget _buildBlob({
    required Color color,
    required double size,
    required Offset offset,
    required Alignment alignment,
  }) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Mesh colors
    final baseBgColor = isDark ? const Color(0xFF0F1015) : const Color(0xFF007AFF);
    final blob1Color = isDark 
        ? const Color(0xFF1E293B).withValues(alpha: 0.8) 
        : const Color(0xFF6ABFFF).withValues(alpha: 0.9);
    final blob2Color = isDark 
        ? const Color(0xFF0F172A).withValues(alpha: 0.8) 
        : const Color(0xFF004DA0).withValues(alpha: 0.7);
    final blob3Color = isDark 
        ? const Color(0xFF1E3A8A).withValues(alpha: 0.6) 
        : const Color(0xFF4FA5E2).withValues(alpha: 0.8);

    return Scaffold(
      body: Stack(
        children: [
          // Animated Mesh Gradient Background
          Stack(
            children: [
              Container(
                color: baseBgColor,
              ),
              // Blob 1
              _buildBlob(
                color: blob1Color,
                size: 700.w,
                offset: Offset(
                  math.sin(_time * 1.2) * 150.w + math.cos(_time * 0.5) * 80.w,
                  math.cos(_time * 0.9) * 120.h + math.sin(_time * 0.4) * 60.h,
                ),
                alignment: Alignment.topLeft,
              ),

              // Blob 2
              _buildBlob(
                color: blob2Color,
                size: 800.w,
                offset: Offset(
                  math.cos(_time * 0.7) * 200.w + math.sin(_time * 0.3) * 100.w,
                  math.sin(_time * 1.0) * 160.h + math.cos(_time * 0.5) * 60.h,
                ).translate(50.w, 50.h),
                alignment: Alignment.bottomRight,
              ),

              // Blob 3
              _buildBlob(
                color: blob3Color,
                size: 650.w,
                offset: Offset(
                  math.sin(_time * 1.5) * 180.w,
                  math.cos(_time * 1.3) * 150.h,
                ),
                alignment: Alignment.center,
              ),

              // Final Blur for Mesh Effect
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 75, sigmaY: 75),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),

          // Central Logo
          Center(
            child: Image.asset(
              isDark ? Assets.logoWhite : Assets.rapidLogoBig, 
              width: 114.w,
            ),
          ),
        ],
      ),
    );
  }
}
