import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  // -----------------------------
  // LIGHT THEME
  // -----------------------------
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: "Inter",

    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1,
      displayMedium: AppTextStyles.h2,
      displaySmall: AppTextStyles.h3,
      headlineMedium: AppTextStyles.secondaryHeading.copyWith(
        color: AppColors.secondaryHeading,
      ),
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.bodyBold,
      bodySmall: AppTextStyles.small,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: AppTextStyles.h2.copyWith(color: Colors.black),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.offWhite,
      contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      hintStyle: AppTextStyles.small.copyWith(color: Colors.black45),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 55.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        textStyle: AppTextStyles.bodyBold.copyWith(color: Colors.white),
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),

    dialogTheme: DialogThemeData(backgroundColor: Colors.white),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primary.withAlpha(100),
      selectionHandleColor: AppColors.primary,
    ),
    switchTheme: SwitchThemeData(
      thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
        if (states.contains(WidgetState.selected)) {
          return const Icon(Icons.check, color: Colors.white, size: 16);
        }
        return const Icon(Icons.close, color: Colors.white, size: 16);
      }),
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white; // When switch is ON
        }
        return Colors.white; // When switch is OFF
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textGrey;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textGrey;
      }),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      surface: Colors.white,
      outline: AppColors.textGrey,
    ),
  );

  // -----------------------------
  // DARK THEME
  // -----------------------------
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.black,
    fontFamily: "Inter",

    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(color: Colors.white),
      displayMedium: AppTextStyles.h2.copyWith(color: Colors.white),
      displaySmall: AppTextStyles.h3.copyWith(color: Colors.white),
      headlineMedium: AppTextStyles.secondaryHeading.copyWith(
        color: AppColors.offWhite,
      ),
      bodyLarge: AppTextStyles.body.copyWith(color: Colors.white),
      bodyMedium: AppTextStyles.bodyBold.copyWith(color: Colors.white),
      bodySmall: AppTextStyles.small.copyWith(color: Colors.white70),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: AppTextStyles.h2.copyWith(color: Colors.white),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black,
      contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      hintStyle: AppTextStyles.small.copyWith(color: Colors.white54),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 55.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        textStyle: AppTextStyles.bodyBold.copyWith(color: Colors.white),
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.black),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primary.withAlpha(120),
      selectionHandleColor: AppColors.primary,
    ),
    switchTheme: SwitchThemeData(
      thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
        if (states.contains(WidgetState.selected)) {
          return const Icon(Icons.check, color: Colors.white, size: 16);
        }
        return const Icon(Icons.close, color: Colors.white, size: 16);
      }),
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white; // When switch is ON
        }
        return Colors.white; // When switch is OFF
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textGrey;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textGrey;
      }),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      surface: Colors.black,
      outline: AppColors.textGrey,
    ),
  );
}
