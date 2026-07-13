import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserAvatar extends StatelessWidget {
  final String? avatar;
  final double size;

  const UserAvatar({
    super.key,
    required this.avatar,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (avatar == null || avatar!.trim().isEmpty) {
      return _buildFallback();
    }

    final avatarStr = avatar!.trim();

    // 1. Inline SVG String
    if (avatarStr.startsWith('<svg') || avatarStr.contains('xmlns="http://www.w3.org/2000/svg"')) {
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
    if (avatarStr.startsWith('http') && avatarStr.toLowerCase().endsWith('.svg')) {
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
    if (avatarStr.startsWith('assets/') && avatarStr.toLowerCase().endsWith('.svg')) {
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
          errorWidget: (context, url, error) => _buildFallback(),
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
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      ),
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      width: size,
      height: size,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFCCDCEF),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        color: const Color(0xFF004999),
        size: size * 0.55,
      ),
    );
  }
}
