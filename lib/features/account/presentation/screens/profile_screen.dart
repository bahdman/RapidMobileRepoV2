import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/theme/app_text_styles.dart';
import 'package:rapid_app/core/widgets/rapid_app_bar.dart';
import 'package:rapid_app/core/widgets/rapid_button.dart';
import 'package:rapid_app/core/services/user_service.dart';
import 'package:dio/dio.dart';
import 'package:rapid_app/core/utils/snackbar_utils.dart';
import 'package:rapid_app/core/widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userService = context.read<UserService>();
      final profile = await userService.getUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _nameCtrl.text = '${profile.firstName} ${profile.lastName}'.trim();
          _emailCtrl.text = profile.email;
          _phoneCtrl.text = profile.phoneNumber;
          _avatarUrl = profile.avatar;
        });
      }
    } catch (e) {
      if (mounted) {
        showGlobalSnackBar('Failed to load profile: ${_getErrorMessage(e)}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });
    try {
      final userService = context.read<UserService>();
      final fullName = _nameCtrl.text.trim();
      final spaceIdx = fullName.indexOf(' ');
      final firstName = spaceIdx != -1 ? fullName.substring(0, spaceIdx) : fullName;
      final lastName = spaceIdx != -1 ? fullName.substring(spaceIdx + 1) : '';

      final updated = await userService.updateUserProfile(
        email: _emailCtrl.text.trim(),
        firstName: firstName,
        lastName: lastName,
        phoneNumber: _phoneCtrl.text.trim(),
      );

      if (updated != null && mounted) {
        showGlobalSnackBar('Profile updated successfully!');
        _fetchProfile();
      }
    } catch (e) {
      if (mounted) {
        showGlobalSnackBar('Failed to update profile: ${_getErrorMessage(e)}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const RapidAppBar(title: 'Profile'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 32.h),
                        // Avatar Header
                        Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              UserAvatar(
                                avatar: _avatarUrl ?? 'https://i.pravatar.cc/150?img=3',
                                size: 90.w,
                              ),
                              Positioned(
                                bottom: 0,
                                right: -16,
                                child: SvgPicture.asset(Assets.camera),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 48.h),
                        // Profile Fields
                        _buildProfileItem(
                          label: 'Full Name',
                          controller: _nameCtrl,
                        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                        SizedBox(height: 20.h),
                        _buildProfileItem(
                          label: 'Email',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                        SizedBox(height: 20.h),
                        _buildProfileItem(
                          label: 'Phone',
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                        SizedBox(height: 50.h),
                        RapidButton(
                          text: _isSaving ? 'Saving...' : 'Save Changes',
                          backgroundColor: AppColors.primary,
                          onPressed: _isSaving ? null : _saveProfile,
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(height: 24.h),
                        Text('Rapid V1.2', style: AppTextStyles.rapidVersion),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileItem({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppColors.darkTextSub : const Color(0xFF9CA3AF);
    final fieldBg = Theme.of(context).colorScheme.surface;
    final fieldBorder = Theme.of(context).colorScheme.outline;
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: labelColor,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: fieldBg,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 22.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: fieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFF007AFF)),
            ),
          ),
        ),
      ],
    );
  }

  String _getErrorMessage(dynamic e) {
    if (e is DioException) {
      final response = e.response;
      if (response != null && response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map.containsKey('message') && map['message'] != null) {
          return map['message'].toString();
        }
      }
      return e.message ?? 'A network error occurred';
    }
    return e.toString();
  }
}
