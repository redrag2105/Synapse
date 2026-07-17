import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/config/test_keys.dart';
import 'package:synapse/presentation/widgets/user_avatar.dart';

class DiscoverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final VoidCallback? onProfileTap;
  final bool isSignedIn;
  final String? profilePhotoUrl;
  final String? profileDisplayName;
  final String? profileEmail;

  /// 0 = expanded, 1 = forced compact (e.g. search field focused).
  final double focusProgress;

  DiscoverHeaderDelegate({
    required this.topPadding,
    this.onProfileTap,
    this.isSignedIn = false,
    this.profilePhotoUrl,
    this.profileDisplayName,
    this.profileEmail,
    this.focusProgress = 0.0,
  });

  double get _expandedExtent => topPadding + 220.0;
  double get _collapsedExtent => topPadding + 60.0;

  @override
  double get maxExtent =>
      _expandedExtent -
      ((_expandedExtent - _collapsedExtent) * focusProgress.clamp(0.0, 1.0));

  @override
  double get minExtent => _collapsedExtent;

  @override
  bool shouldRebuild(covariant DiscoverHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.onProfileTap != onProfileTap ||
        oldDelegate.isSignedIn != isSignedIn ||
        oldDelegate.profilePhotoUrl != profilePhotoUrl ||
        oldDelegate.profileDisplayName != profileDisplayName ||
        oldDelegate.profileEmail != profileEmail ||
        oldDelegate.focusProgress != focusProgress;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double extentDiff = maxExtent - minExtent;
    final double scrollProgress =
        extentDiff > 0 ? (shrinkOffset / extentDiff).clamp(0.0, 1.0) : 1.0;
    final double progress =
        (scrollProgress + focusProgress).clamp(0.0, 1.0);

    final double fadeOpacity = (1.0 - (progress * 2.5)).clamp(0.0, 1.0);
    final double collapsedOpacity = (1.0 - fadeOpacity).clamp(0.0, 1.0);

    final double maxTitleSize = 40.0;
    final double minTitleSize = 20.0;
    final double currentTitleSize =
        maxTitleSize - ((maxTitleSize - minTitleSize) * progress);

    final double expandedTitleY = topPadding + 70.0;
    final double collapsedTitleY = topPadding + 16.0;
    final double currentTitleY =
        expandedTitleY - ((expandedTitleY - collapsedTitleY) * progress);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandBlue900, AppColors.brandBlue700],
        ),
      ),
      child: RepaintBoundary(
        child: Stack(
          children: [
            Positioned(
              top: topPadding + 16,
              left: 24,
              right: 24,
              child: Opacity(
                opacity: fadeOpacity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ISSN 2961-0504',
                      style: AppTextStyles.metadata.copyWith(
                        color: Colors.white54,
                        fontFamily: 'Courier',
                      ),
                    ),
                    if (onProfileTap != null)
                      IgnorePointer(
                        ignoring: fadeOpacity < 0.5,
                        child: GestureDetector(
                          key: TestKeys.discoverProfileButton,
                          onTap: onProfileTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white54),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'My Profile',
                              style: AppTextStyles.metadata.copyWith(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: currentTitleY,
              left: 24,
              child: Text(
                'SYNAPSE',
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: currentTitleSize,
                  letterSpacing: 4.0 - (progress * 2),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Positioned(
              top: expandedTitleY + maxTitleSize + 8,
              left: 24,
              child: Opacity(
                opacity: fadeOpacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Journal Trend Analyzer\n& Bibliometrics',
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
                ),
              ),
            ),
            if (onProfileTap != null)
              Positioned(
                top: topPadding + 8,
                right: 8,
                child: Opacity(
                  opacity: collapsedOpacity,
                  child: IgnorePointer(
                    ignoring: collapsedOpacity < 0.5,
                    child: isSignedIn
                        ? IconButton(
                            key: TestKeys.discoverSignedInProfile,
                            tooltip: 'My Profile',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            icon: UserAvatar(
                              photoUrl: profilePhotoUrl,
                              displayName: profileDisplayName,
                              email: profileEmail,
                              radius: 18,
                              backgroundColor: AppColors.brandBlue600,
                              borderColor: Colors.white.withValues(alpha: 0.55),
                            ),
                            onPressed: onProfileTap,
                          )
                        : IconButton(
                            tooltip: 'My Profile',
                            icon: const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white70,
                              size: 24,
                            ),
                            onPressed: onProfileTap,
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
