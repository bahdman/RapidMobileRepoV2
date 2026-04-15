import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/theme/app_text_styles.dart';
import 'package:rapid_app/core/widgets/rapid_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = false;
  bool _scanReminder = true;
  bool _shareUsageData = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const RapidAppBar(title: 'Settings'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          children: [
            // Notifications Section
            _buildSectionHeader(
              icon: Assets.settingsNotification,
              title: 'NOTIFICATIONS',
            ),
            _buildSettingsGroup([
              _buildSwitchRow(
                title: 'Push Notifications',
                subtitle: 'Scan alerts & reminders',
                value: _pushNotifications,
                onChanged: (val) => setState(() => _pushNotifications = val),
              ),
              _buildSwitchRow(
                title: 'Email Alerts',
                subtitle: 'Weekly vehicle reports',
                value: _emailAlerts,
                onChanged: (val) => setState(() => _emailAlerts = val),
              ),
              _buildSwitchRow(
                title: 'Scan Reminder',
                subtitle: 'Scheduled scan notifications',
                value: _scanReminder,
                onChanged: (val) => setState(() => _scanReminder = val),
                showDivider: false,
              ),
            ]),

            SizedBox(height: 32.h),

            // Privacy Section
            _buildSectionHeader(icon: Assets.settingsPrivacy, title: 'PRIVACY'),
            _buildSettingsGroup([
              _buildSwitchRow(
                title: 'Share Usage Data',
                subtitle: 'Help improve Rapid',
                value: _shareUsageData,
                onChanged: (val) => setState(() => _shareUsageData = val),
                showDivider: false,
              ),
            ]),

            SizedBox(height: 32.h),

            // Appearance Section
            _buildSectionHeader(
              icon: Assets.settingsAppearance,
              title: 'APPEARANCE',
            ),
            _buildSettingsGroup([
              _buildSwitchRow(
                title: 'Dark Mode',
                subtitle: 'Switch to dark theme',
                value: _darkMode,
                onChanged: (val) => setState(() => _darkMode = val),
                showDivider: false,
              ),
            ]),

            SizedBox(height: 32.h),

            // Footer Links
            _buildSettingsGroup([
              _buildLinkRow(title: 'Terms of Service', onTap: () {}),
              _buildLinkRow(title: 'Privacy Policy', onTap: () {}),
              _buildLinkRow(
                title: 'App Version 1.0.0',
                onTap: () {},
                showDivider: false,
              ),
            ]),

            SizedBox(height: 48.h),

            Text('Rapid V1.2', style: AppTextStyles.rapidVersion),
            SizedBox(height: 24.h),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
      ),
    );
  }

  Widget _buildSectionHeader({required String icon, required String title}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          SvgPicture.asset(icon),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey200.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textMediumGrey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: CupertinoSwitch(
                  value: value,
                  onChanged: onChanged,
                  activeTrackColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(color: AppColors.grey200.withValues(alpha: 0.5), height: 1),
      ],
    );
  }

  Widget _buildLinkRow({
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMediumGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(color: AppColors.grey200.withValues(alpha: 0.5), height: 1),
        ],
      ),
    );
  }
}
