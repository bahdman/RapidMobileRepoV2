import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PageHolder extends StatefulWidget {
  final StatefulNavigationShell child;
  const PageHolder({super.key, required this.child});

  static int lastActiveIndex = 0;

  @override
  State<PageHolder> createState() => _PageHolderState();
}

class _PageHolderState extends State<PageHolder> {
  @override
  void didUpdateWidget(PageHolder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child.currentIndex != widget.child.currentIndex) {
      if (widget.child.currentIndex == 2) {
        PageHolder.lastActiveIndex = oldWidget.child.currentIndex;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {'asset': Assets.home, 'label': 'Home', 'index': 0},
      {'asset': Assets.history, 'label': 'History', 'index': 1},
      {'asset': Assets.account, 'label': 'Account', 'index': 2},
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBarBg = isDark ? AppColors.darkSurface : Colors.white;
    final navBorder = isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.borderColor.withValues(alpha: 0.5);
    final selectedBadgeBg = isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.selectedNavBar;

    final navBar = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 110.h,
      padding: EdgeInsets.only(top: 12.h, bottom: 20.h),
      decoration: BoxDecoration(
        color: navBarBg,
        border: Border(
          top: BorderSide(
            width: 0.5,
            color: navBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final targetIndex = item['index'] as int;
          final isSelected = widget.child.currentIndex == targetIndex;
          final primaryColor = const Color(0xFF007AFF);

          return GestureDetector(
            onTap: () => widget.child.goBranch(targetIndex),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedBadgeBg
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    item['asset'] as String,
                    colorFilter: ColorFilter.mode(
                      isSelected ? primaryColor : AppColors.textMediumGrey,
                      BlendMode.srcIn,
                    ),
                    width: 24.w,
                    height: 24.h,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? primaryColor
                          : AppColors.textMediumGrey,
                      fontSize: 13.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: widget.child,
      bottomNavigationBar:
          Platform.isAndroid && MediaQuery.of(context).padding.bottom > 0
          ? SafeArea(top: false, child: navBar)
          : navBar,
    );
  }
}
