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

    return Scaffold(
      backgroundColor: widget.child.currentIndex == 2
          ? AppColors.scaffoldBg
          : Colors.white,
      body: widget.child,
      bottomNavigationBar: Container(
        height: 110.h,
        padding: EdgeInsets.only(top: 12.h, bottom: 28.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              width: 0.5,
              color: AppColors.borderColor.withValues(alpha: 0.5),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
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
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.selectedNavBar
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
      ),
    );
  }
}
