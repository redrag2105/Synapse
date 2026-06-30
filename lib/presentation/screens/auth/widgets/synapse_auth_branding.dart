import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

/// Shared branding block used on auth surfaces — matches the Discover header.
class SynapseAuthBranding extends StatelessWidget {
  final String subtitle;
  final double titleSize;

  const SynapseAuthBranding({
    super.key,
    this.subtitle = 'Journal Trend Analyzer\n& Bibliometrics',
    this.titleSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ISSN 2961-0504',
          style: AppTextStyles.metadata.copyWith(
            color: Colors.white54,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'SYNAPSE',
          style: AppTextStyles.h1.copyWith(
            color: Colors.white,
            fontSize: titleSize,
            letterSpacing: 4,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: AppTextStyles.h2.copyWith(
            fontFamily: 'Merriweather',
            fontStyle: FontStyle.italic,
            fontSize: 18,
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        Container(width: 40, height: 3, color: AppColors.warning),
      ],
    );
  }
}
