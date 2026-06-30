import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? displayName;
  final String? email;
  final double radius;
  final Color backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  const UserAvatar({
    super.key,
    this.photoUrl,
    this.displayName,
    this.email,
    this.radius = 20,
    this.backgroundColor = AppColors.brandBlue700,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _initials(displayName ?? email ?? '');

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
        child: photoUrl == null
            ? Text(
                initials,
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontSize: radius * 0.72,
                ),
              )
            : null,
      ),
    );
  }

  static String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
