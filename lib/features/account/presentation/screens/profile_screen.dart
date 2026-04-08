import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rapid_app/core/config/app_assets.dart';
import 'package:rapid_app/core/theme/app_colors.dart';
import 'package:rapid_app/core/widgets/rapid_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const RapidAppBar(title: 'Profile'),
      body: CustomScrollView(
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
                  _buildProfileItem(label: 'Full Name', value: 'John Doe'),
                  SizedBox(height: 20.h),
                  _buildProfileItem(
                    label: 'Email',
                    value: 'johndoe@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20.h),
                  _buildProfileItem(
                    label: 'Phone',
                    value: '+234 810 123 4567',
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 50.h),
                  SizedBox(
                    width: double.infinity,
                    height: 64.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                  Text(
                    'Rapid V1.2',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
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
    required String value,
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
          initialValue: value,
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
