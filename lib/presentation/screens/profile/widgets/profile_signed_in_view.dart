import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/url_helper.dart';
import 'package:synapse/domain/entities/profile_features_state.dart';
import 'package:synapse/presentation/controllers/app_remote_config_controller.dart';
import 'package:synapse/presentation/controllers/notification_inbox_controller.dart';
import 'package:synapse/presentation/controllers/profile_features_controller.dart';
import 'package:synapse/app/config/test_keys.dart';
import 'package:synapse/presentation/screens/profile/widgets/profile_section_widgets.dart';
import 'package:synapse/presentation/widgets/user_avatar.dart';

bool _isReportExportStatus(String message) {
  return message.startsWith('Report ');
}

class ProfileSignedInView extends ConsumerWidget {
  final double topPadding;
  final User user;
  final VoidCallback onSignOut;

  const ProfileSignedInView({
    super.key,
    required this.topPadding,
    required this.user,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(profileFeaturesControllerProvider);
    final config = ref.watch(appRemoteConfigProvider);
    final notifications = ref.watch(notificationInboxProvider);
    final notifier = ref.read(profileFeaturesControllerProvider.notifier);

    return ColoredBox(
      key: TestKeys.signedInProfile,
      color: AppColors.surfaceGray,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileUserHeader(
              topPadding: topPadding,
              user: user,
              onSignOut: onSignOut,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 52)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (features.statusMessage != null &&
                    !_isReportExportStatus(features.statusMessage!)) ...[
                  _StatusBanner(message: features.statusMessage!),
                  const SizedBox(height: 16),
                ],
                const ProfileSectionHeader(
                  title: 'Notification Center',
                  subtitle: 'Alerts received from Firebase Cloud Messaging',
                ),
                _NotificationCenter(notifications: notifications),
                const SizedBox(height: 24),
                const ProfileSectionHeader(
                  title: 'Report Export',
                  subtitle: 'Export dashboard analytics and upload to Storage',
                ),
                _ReportExportSection(
                  isExporting: features.isExportingReport,
                  uploadedUrl: features.uploadedReportUrl,
                  statusMessage: features.statusMessage,
                  onExport: notifier.exportReport,
                ),
                const SizedBox(height: 24),
                const ProfileSectionHeader(
                  title: 'Remote Config',
                  subtitle: 'Configuration values from Firebase Remote Config',
                ),
                _RemoteConfigSection(
                  isLoading: features.isLoadingRemoteConfig,
                  maxJournals: config.maxJournalsDisplay,
                  maxKeywords: config.maxKeywordsDisplay,
                  onRefresh: notifier.refreshRemoteConfig,
                ),
                const SizedBox(height: 24),
                const ProfileSectionHeader(
                  title: 'Crashlytics',
                  subtitle: 'Firebase Crashlytics demonstration tools',
                ),
                _CrashlyticsSection(
                  onRecordException: notifier.recordHandledException,
                  onTestCrash: () => _confirmTestCrash(context, notifier),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmTestCrash(
    BuildContext context,
    ProfileFeaturesController notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trigger test crash?'),
        content: const Text(
          'This will force-close the app to verify Crashlytics reporting.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Crash app'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      notifier.triggerTestCrash();
    }
  }
}

class _ProfileUserHeader extends StatelessWidget {
  static const double _cardOverlap = 52;

  final double topPadding;
  final User user;
  final VoidCallback onSignOut;

  const _ProfileUserHeader({
    required this.topPadding,
    required this.user,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName?.trim();
    final email = user.email?.trim();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.brandBlue900, AppColors.brandBlue700],
                  ),
                ),
              ),
            ),
            const Positioned(
              top: -20,
              right: -50,
              child: _ProfileHeaderOrb(size: 140, opacity: 0.04),
            ),
            Positioned(
              left: -30,
              bottom: _cardOverlap + 20,
              child: const _ProfileHeaderOrb(size: 100, opacity: 0.03),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, topPadding + 4, 0, _cardOverlap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        key: TestKeys.profileBackButton,
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          CupertinoIcons.back,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile',
                                style: AppTextStyles.h1.copyWith(
                                  color: Colors.white,
                                  fontSize: 22,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 28,
                                height: 2.5,
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        key: TestKeys.signOutButton,
                        onPressed: onSignOut,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign out',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      'Alerts, exports & Firebase tools',
                      style: AppTextStyles.metadata.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: -_cardOverlap,
          child: ProfileSurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                UserAvatar(
                  photoUrl: user.photoURL,
                  displayName: displayName,
                  email: email,
                  radius: 28,
                  backgroundColor: AppColors.surfaceGray,
                  initialsColor: AppColors.brandBlue900,
                  borderColor: AppColors.borderGray,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName?.isNotEmpty == true
                            ? displayName!
                            : 'Account',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.brandBlue900,
                          fontSize: 17,
                        ),
                      ),
                      if (email?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          email!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.metadata.copyWith(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue900.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Active',
                    style: AppTextStyles.metadata.copyWith(
                      color: AppColors.brandBlue900,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeaderOrb extends StatelessWidget {
  final double size;
  final double opacity;

  const _ProfileHeaderOrb({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;

  const _StatusBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.brandBlue900.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.brandBlue500.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        message,
        style: AppTextStyles.metadata.copyWith(
          color: AppColors.brandBlue900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _NotificationCenter extends StatelessWidget {
  final List<ProfileNotification> notifications;

  const _NotificationCenter({required this.notifications});

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return ProfileSurfaceCard(
        child: Column(
          children: [
            Icon(
              CupertinoIcons.bell,
              size: 28,
              color: AppColors.brandBlue600.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),
            Text(
              'No notifications yet',
              style: AppTextStyles.h3.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              'Trending topics, citation alerts, and research updates '
              'will appear here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.metadata.copyWith(
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final item in notifications.take(8)) ...[
          ProfileSurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue900.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    CupertinoIcons.bell_fill,
                    size: 18,
                    color: AppColors.brandBlue600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.h3.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: AppTextStyles.metadata.copyWith(
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTimestamp(item.receivedAt),
                        style: AppTextStyles.metadata.copyWith(
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

String _formatTimestamp(DateTime date) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${months[date.month - 1]} ${date.day}, ${date.year} · $hour:$minute';
}

class _ReportExportSection extends StatelessWidget {
  final bool isExporting;
  final String? uploadedUrl;
  final String? statusMessage;
  final VoidCallback onExport;

  const _ReportExportSection({
    required this.isExporting,
    required this.uploadedUrl,
    required this.statusMessage,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Generate a PDF analytics report and upload it to Firebase Storage.',
            style: AppTextStyles.metadata.copyWith(fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              key: TestKeys.exportPdfButton,
              onPressed: isExporting ? null : onExport,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandBlue900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(CupertinoIcons.arrow_up_doc, size: 18),
              label: Text(isExporting ? 'Exporting…' : 'Export PDF report'),
            ),
          ),
          if (statusMessage != null &&
              statusMessage!.toLowerCase().contains('report')) ...[
            const SizedBox(height: 14),
            Text(
              statusMessage!,
              key: TestKeys.exportStatusMessage,
              style: AppTextStyles.metadata.copyWith(
                fontSize: 12,
                color: statusMessage!.startsWith('Report export failed')
                    ? AppColors.error
                    : AppColors.brandBlue900,
              ),
            ),
          ],
          if (uploadedUrl != null) ...[
            const SizedBox(height: 14),
            Text(
              'Uploaded file URL',
              style: AppTextStyles.metadata.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              key: TestKeys.exportUploadedUrl,
              onTap: () => UrlHelper.launch(uploadedUrl),
              child: Text(
                uploadedUrl!,
                style: AppTextStyles.metadata.copyWith(
                  fontSize: 11,
                  color: AppColors.brandBlue600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RemoteConfigSection extends StatelessWidget {
  final bool isLoading;
  final int maxJournals;
  final int maxKeywords;
  final VoidCallback onRefresh;

  const _RemoteConfigSection({
    required this.isLoading,
    required this.maxJournals,
    required this.maxKeywords,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProfileMetricTile(
                label: 'Max journals',
                value: isLoading ? '—' : '$maxJournals',
                icon: CupertinoIcons.book_fill,
              ),
              const SizedBox(width: 10),
              ProfileMetricTile(
                label: 'Max keywords',
                value: isLoading ? '—' : '$maxKeywords',
                icon: CupertinoIcons.tag_fill,
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: isLoading ? null : onRefresh,
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(CupertinoIcons.arrow_clockwise, size: 16),
            label: const Text('Refresh values'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandBlue900,
              side: const BorderSide(color: AppColors.borderGray),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrashlyticsSection extends StatelessWidget {
  final VoidCallback onRecordException;
  final VoidCallback onTestCrash;

  const _CrashlyticsSection({
    required this.onRecordException,
    required this.onTestCrash,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: onRecordException,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandBlue900,
                side: const BorderSide(color: AppColors.borderGray),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Record handled exception'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: onTestCrash,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Trigger test crash'),
            ),
          ),
        ],
      ),
    );
  }
}
