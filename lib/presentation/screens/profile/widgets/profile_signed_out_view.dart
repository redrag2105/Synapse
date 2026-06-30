import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/presentation/screens/profile/widgets/profile_section_widgets.dart';
import 'package:synapse/presentation/widgets/google_sign_in_button.dart';

class ProfileSignedOutView extends StatelessWidget {
  final double topPadding;
  final bool isSigningIn;
  final VoidCallback onSignIn;

  const ProfileSignedOutView({
    super.key,
    required this.topPadding,
    required this.isSigningIn,
    required this.onSignIn,
  });

  static const _previewSections = [
    (
      icon: CupertinoIcons.bell_fill,
      title: 'Notification Center',
      subtitle: 'FCM research alerts and trend updates',
    ),
    (
      icon: CupertinoIcons.doc_text_fill,
      title: 'Report Export',
      subtitle: 'PDF analytics reports via Firebase Storage',
    ),
    (
      icon: CupertinoIcons.slider_horizontal_3,
      title: 'Remote Config',
      subtitle: 'Live display limits from Firebase',
    ),
    (
      icon: CupertinoIcons.exclamationmark_triangle_fill,
      title: 'Crashlytics',
      subtitle: 'Handled exceptions and crash reporting',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: AppColors.surfaceGray,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileGateHeader(topPadding: topPadding),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverList.separated(
              itemCount: _previewSections.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final section = _previewSections[index];
                return _LockedSectionPreview(
                  icon: section.icon,
                  title: section.title,
                  subtitle: section.subtitle,
                );
              },
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 20 + bottomInset),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Sign in to continue',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.brandBlue900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Account management and Firebase service tools are '
                    'available after authentication.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.metadata.copyWith(
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GoogleSignInButton(
                    isLoading: isSigningIn,
                    onPressed: onSignIn,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileGateHeader extends StatelessWidget {
  final double topPadding;

  const _ProfileGateHeader({required this.topPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8, topPadding + 4, 20, 28),
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
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(CupertinoIcons.back, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Account & Firebase services',
                  style: AppTextStyles.metadata.copyWith(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                Container(width: 40, height: 3, color: AppColors.warning),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedSectionPreview extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _LockedSectionPreview({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.42,
      child: ProfileSurfaceCard(
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.brandBlue900.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.brandBlue700, size: 20),
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
                    style: AppTextStyles.metadata.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.lock_fill,
              size: 14,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
