import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.brandBlue900, AppColors.brandBlue700],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          CupertinoIcons.back,
                          color: Colors.white,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Account',
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your Synapse profile & preferences',
                    style: AppTextStyles.metadata.copyWith(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfilePlaceholderCard(
                  icon: CupertinoIcons.person_crop_circle,
                  title: 'Sign In',
                  subtitle:
                      'Sync saved searches, alerts, and reading history.',
                  // TODO(firebase): Wire up Firebase Authentication sign-in flow.
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _ProfilePlaceholderCard(
                  icon: CupertinoIcons.bell,
                  title: 'Research Alerts',
                  subtitle: 'Get notified when topics trend upward.',
                  // TODO(firebase): Connect to Firebase Cloud Messaging for push alerts.
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _ProfilePlaceholderCard(
                  icon: CupertinoIcons.bookmark,
                  title: 'Saved Publications',
                  subtitle: 'Your bookmarked papers and reading list.',
                  // TODO(firebase): Persist saved items with Firestore per authenticated user.
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _ProfilePlaceholderCard(
                  icon: CupertinoIcons.gear,
                  title: 'Settings',
                  subtitle: 'Notifications, data sources, and display options.',
                  onTap: () {},
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePlaceholderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfilePlaceholderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue900.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.brandBlue900, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.metadata.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
