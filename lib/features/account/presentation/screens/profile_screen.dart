import 'package:cached_network_image/cached_network_image.dart';
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
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        _fetchProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
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
      backgroundColor: AppColors.scaffoldBg,
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
                              Container(
                                width: 90.w,
                                height: 90.w,
                                decoration: const BoxDecoration(
                                  color: AppColors.grey200,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      'https://i.pravatar.cc/150?img=3',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF9CA3AF),
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
            color: Colors.black,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 22.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: AppColors.grey200),
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
}
