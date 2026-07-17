import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/config/test_keys.dart';
import 'package:synapse/presentation/controllers/profile_features_controller.dart';
import 'package:synapse/presentation/screens/profile/widgets/profile_crashlytics_section.dart';
import 'package:synapse/presentation/screens/profile/widgets/profile_section_widgets.dart';
import 'package:synapse/presentation/widgets/google_sign_in_button.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_layout.dart';

class ProfileSignedOutView extends ConsumerWidget {
  final double topPadding;
  final bool isSigningIn;
  final VoidCallback onSignIn;

  const ProfileSignedOutView({
    super.key,
    required this.topPadding,
    required this.isSigningIn,
    required this.onSignIn,
  });

  static const _fadeHeight = 56.0;
  static const _ctaContentHeight = 168.0;

  static const _lockedSections = [
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
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final tabClearance = AppBottomNavLayout.maxOverlayInset(bottomInset);
    final overlayHeight = _fadeHeight + _ctaContentHeight + tabClearance;
    final notifier = ref.read(profileFeaturesControllerProvider.notifier);

    return ColoredBox(
      key: TestKeys.signedOutProfile,
      color: AppColors.surfaceGray,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _ProfileGateHeader(topPadding: topPadding),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const ProfileSectionHeader(
                      title: 'Crashlytics',
                      subtitle:
                          'Crash reporting works without signing in — try the demos below.',
                    ),
                    ProfileCrashlyticsSection(
                      onRecordException: notifier.recordHandledException,
                      onTestCrash: () => confirmCrashlyticsTestCrash(
                        context: context,
                        onConfirm: notifier.triggerTestCrash,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Requires sign-in',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < _lockedSections.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _LockedSectionPreview(
                        icon: _lockedSections[i].icon,
                        title: _lockedSections[i].title,
                        subtitle: _lockedSections[i].subtitle,
                      ),
                    ],
                    SizedBox(height: overlayHeight),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _SignInContinueOverlay(
              isSigningIn: isSigningIn,
              onSignIn: onSignIn,
              tabClearance: tabClearance,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInContinueOverlay extends StatelessWidget {
  final bool isSigningIn;
  final VoidCallback onSignIn;
  final double tabClearance;

  const _SignInContinueOverlay({
    required this.isSigningIn,
    required this.onSignIn,
    required this.tabClearance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IgnorePointer(
          child: Container(
            height: ProfileSignedOutView._fadeHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white.withValues(alpha: 0), Colors.white],
              ),
            ),
          ),
        ),
        ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, tabClearance),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.brandBlue900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unlock notifications, report export, and Remote Config '
                  'after authentication.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.metadata.copyWith(
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                GoogleSignInButton(isLoading: isSigningIn, onPressed: onSignIn),
              ],
            ),
          ),
        ),
      ],
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
      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 28),
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
          Text(
            'Profile',
            style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 28),
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
