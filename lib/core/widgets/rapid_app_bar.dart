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
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.scaffoldBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leadingWidth: 70.w,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: GestureDetector(
                onTap: onLeadingPressed ?? () => context.pop(),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: SvgPicture.asset(Assets.appbarBackBtn),
                ),
              ),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                color: AppColors.textVeryDarkGrey,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);
}
