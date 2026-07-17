import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/presentation/screens/profile/widgets/profile_section_widgets.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_layout.dart';

/// Crashlytics demo controls — available signed-in or signed-out.
class ProfileCrashlyticsSection extends StatelessWidget {
  final Future<void> Function() onRecordException;
  final VoidCallback onTestCrash;

  const ProfileCrashlyticsSection({
    super.key,
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
              onPressed: () => _recordHandledException(context),
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

  Future<void> _recordHandledException(BuildContext context) async {
    await onRecordException();
    if (!context.mounted) return;
    showCrashlyticsHandledExceptionSnackBar(context);
  }
}

void showCrashlyticsHandledExceptionSnackBar(BuildContext context) {
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  final tabClearance = AppBottomNavLayout.maxOverlayInset(bottomInset);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text('Handled exception recorded in Crashlytics.'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, tabClearance),
      ),
    );
}

Future<void> confirmCrashlyticsTestCrash({
  required BuildContext context,
  required VoidCallback onConfirm,
}) async {
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
    onConfirm();
  }
}
