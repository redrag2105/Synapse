import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

class SquareFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final bool isInverted;

  const SquareFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    this.isInverted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isInverted ? AppColors.brandBlue900 : Colors.white;
    final titleColor = isInverted ? Colors.white : AppColors.brandBlue900;
    final subtitleColor = isInverted ? Colors.white70 : AppColors.textSecondary;
    final iconColor = isInverted ? Colors.white : AppColors.brandBlue900;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isInverted ? Colors.transparent : AppColors.borderGray,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                bottom: -15,
                child: Icon(
                  icon,
                  size: 90,
                  color: isInverted
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.brandBlue900.withValues(alpha: 0.03),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isInverted
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppColors.brandBlue900.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.h3.copyWith(
                            color: titleColor,
                            fontSize: 18,
                            fontFamily: 'Merriweather',
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: AppTextStyles.metadata.copyWith(
                            color: subtitleColor,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
