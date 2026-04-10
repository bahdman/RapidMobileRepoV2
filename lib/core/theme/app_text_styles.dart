import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rapid_app/core/theme/app_colors.dart';

class AppTextStyles {
  /// Extra Bold / Headers
  static TextStyle get h1 => TextStyle(
    fontFamily: 'Inter',
    fontSize: 32.sp,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get h2 => TextStyle(
    fontFamily: 'Inter',
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get h3 => TextStyle(
    fontFamily: 'Inter',
    fontSize: 22.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get secondaryHeading => TextStyle(
    fontFamily: 'Inter',
    fontSize: 15.sp,
    fontWeight: FontWeight.w400,
  );

  /// Body Text
  static TextStyle get body => TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get bodyBold => TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  /// Small Text
  static TextStyle get small => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get smallBold => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
  );

  /// Optional special styles (no colors)
  static TextStyle get white => TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get rapidVersion => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textMediumGrey,
  );

  static TextStyle get whiteSmall => TextStyle(
    fontFamily: 'Inter',
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get primary => TextStyle(
    fontFamily: 'Inter',
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );
}
