import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';

class RapidAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onLeadingPressed;
  final bool showBackButton;
  final Color? backgroundColor;

  const RapidAppBar({
    super.key,
    this.title,
    this.actions,
    this.onLeadingPressed,
    this.showBackButton = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barBg =
        backgroundColor ??
        (isDark ? AppColors.darkScaffoldBg : AppColors.scaffoldBg);
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textVeryDarkGrey;
    return AppBar(
      toolbarHeight: 75.h,
      backgroundColor: barBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leadingWidth: 70.w,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _appbarBackButton(
                  context: context,
                  svg: Assets.arrowBack,
                  onTap: onLeadingPressed ?? () => context.pop(),
                  isRoundedRectButton: false,
                ),
              ),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                color: titleColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
      actions: actions,
    );
  }

  Widget _appbarBackButton({
    required BuildContext context,
    required String svg,
    required VoidCallback onTap,
    required bool isRoundedRectButton,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isRoundedRectButton ? 16.r : 100.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 44.w,
        height: 44.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.w,
            color: isDark ? AppColors.grey800 : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(
            isRoundedRectButton ? 16.r : 100.r,
          ),
        ),
        child: SvgPicture.asset(
          svg,
          width: 24.w,
          height: 24.w,
          colorFilter: ColorFilter.mode(
            isDark ? AppColors.darkTextPrimary : AppColors.textVeryDarkGrey,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(75.h);
}
