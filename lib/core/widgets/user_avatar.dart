import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rapid_app/core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? avatar;
  final IconData? icon;
  final double size;
  final IconData? fallbackIcon;

  const UserAvatar({
    super.key,
    required this.avatar,
    required this.size,
    this.icon,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return _buildIcon(context, icon!);
    }

    if (avatar == null || avatar!.trim().isEmpty) {
      return _buildFallback(context);
    }

    final avatarStr = avatar!.trim();

    // 1. Inline SVG String
    if (avatarStr.startsWith('<svg') ||
        avatarStr.contains('xmlns="http://www.w3.org/2000/svg"')) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        clipBehavior: Clip.antiAlias,
        child: SvgPicture.string(
          avatarStr,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    // 2. Remote SVG URL
    if (avatarStr.startsWith('http') &&
        avatarStr.toLowerCase().endsWith('.svg')) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        clipBehavior: Clip.antiAlias,
        child: SvgPicture.network(
          avatarStr,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => _buildLoading(),
        ),
      );
    }

    // 3. Local SVG Asset
    if (avatarStr.startsWith('assets/') &&
        avatarStr.toLowerCase().endsWith('.svg')) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        clipBehavior: Clip.antiAlias,
        child: SvgPicture.asset(
          avatarStr,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    // 4. Remote Image URL
    if (avatarStr.startsWith('http')) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: avatarStr,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildLoading(),
          errorWidget: (context, url, error) => _buildFallback(context),
        ),
      );
    }

    // 5. Local Image Asset
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        avatarStr,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      ),
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      width: size,
      height: size,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return _buildIcon(context, fallbackIcon ?? Icons.person_rounded);
  }

  Widget _buildIcon(BuildContext context, IconData iconData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : const Color(0xFFCCDCEF),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF004999),
        size: size * 0.55,
      ),
    );
  }
}
