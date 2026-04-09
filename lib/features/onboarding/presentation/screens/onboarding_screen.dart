import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/route_names.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Ticker _ticker;
  double _time = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      headingPrimary: 'Understand',
      headingSecondary: 'Your Car',
      subheading:
          'Scan your vehicle and turn complex fault codes into clear, simple insights.',
      isPrimaryHighlighted: false,
    ),
    OnboardingData(
      headingPrimary: 'Stay Ahead',
      headingSecondary: 'of Issues',
      subheading:
          "Track your car's health, get timely maintenance reminders, and avoid costly repairs.",
      isPrimaryHighlighted: true,
    ),
    OnboardingData(
      headingPrimary: 'Make Smarter',
      headingSecondary: 'Decisions',
      subheading: "Know what's wrong, what it means, and what to do next.",
      isPrimaryHighlighted: false,
    ),
  ];

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
  }

  @override
  void dispose() {
    _pageController.dispose();
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
    return Scaffold(
      body: Stack(
        children: [
          // Animated Mesh Gradient Background (Randomized & Continuous)
          Stack(
            children: [
              Container(color: Colors.white), // Base layer
              // Blob 1 - Complex non-repeating path
              _buildBlob(
                color: const Color(0xFF90CFFF).withValues(alpha: 0.6),
                size: 500.w,
                offset: Offset(
                  math.sin(_time * 0.7) * 150.w + math.cos(_time * 0.3) * 50.w,
                  math.cos(_time * 0.5) * 120.h + math.sin(_time * 0.2) * 40.h,
                ),
                alignment: Alignment.topLeft,
              ),

              // Blob 2
              _buildBlob(
                color: AppColors.primary.withValues(alpha: 0.4),
                size: 600.w,
                offset: Offset(
                  math.cos(_time * 0.6) * 180.w + math.sin(_time * 0.4) * 60.w,
                  math.sin(_time * 0.8) * 150.h + math.cos(_time * 0.1) * 30.h,
                ),
                alignment: Alignment.bottomRight,
              ),

              // Blob 3
              _buildBlob(
                color: const Color(0xFFD6EFFF).withValues(alpha: 0.8),
                size: 550.w,
                offset: Offset(
                  math.sin(_time * 0.4) * 200.w,
                  math.cos(_time * 0.9) * 180.h,
                ),
                alignment: Alignment.center,
              ),

              // Blob 4 - Extra depth
              _buildBlob(
                color: const Color(0xFF4FA5E2).withValues(alpha: 0.2),
                size: 400.w,
                offset: Offset(
                  math.cos(_time * 1.1) * 100.w,
                  math.sin(_time * 0.3) * 200.h,
                ),
                alignment: Alignment.topRight,
              ),

              // Final Blur
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                // Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.rapidTxt,
                      width: 66.w,
                      color: Colors.black,
                    ),
                  ],
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${page.headingPrimary}\n',
                                    style: TextStyle(
                                      fontSize: 40.sp,
                                      fontWeight: FontWeight.w800,
                                      color: page.isPrimaryHighlighted
                                          ? AppColors.primary
                                          : Colors.black,
                                      height: 1.1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: page.headingSecondary,
                                    style: TextStyle(
                                      fontSize: 40.sp,
                                      fontWeight: FontWeight.w800,
                                      color: page.isPrimaryHighlighted
                                          ? Colors.black
                                          : AppColors.primary,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              page.subheading,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black.withValues(alpha: 0.8),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 100.h),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 16.h),

                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      height: 6.h,
                      width: _currentPage == index ? 24.w : 6.w,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : Colors.grey.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),

                // next Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: RapidButton(
                    text: 'Next',
                    height: 64,
                    borderRadius: 100,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        context.pushReplacementNamed(AppRoutes.auth);
                      }
                    },
                  ),
                ),

                SizedBox(height: 16.h),

                // Secondary Action (Skip or Login)
                if (_currentPage < _pages.length - 1)
                  TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        _pages.length - 1,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutBack,
                      );
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      context.pushReplacementNamed(AppRoutes.auth);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: 32.h),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String headingPrimary;
  final String headingSecondary;
  final String subheading;
  final bool isPrimaryHighlighted;

  OnboardingData({
    required this.headingPrimary,
    required this.headingSecondary,
    required this.subheading,
    required this.isPrimaryHighlighted,
  });
}
