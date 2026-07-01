import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:synapse/app/bootstrap/app_bootstrap.dart';
import 'package:synapse/app/config/test_keys.dart';
import 'package:synapse/main.dart';

/// Google account hint for the system account picker.
/// Pass via: `patrol test --dart-define=PATROL_GOOGLE_EMAIL=you@gmail.com`
const patrolGoogleEmail = String.fromEnvironment('PATROL_GOOGLE_EMAIL');

Future<void> pumpSynapseApp(PatrolIntegrationTester $) async {
  await bootstrapSynapseApp(forPatrolTest: true);
  await $.pumpWidgetAndSettle(const ProviderScope(child: SynapseApp()));
}

Future<void> waitForDiscoverHome(PatrolIntegrationTester $) async {
  await $(TestKeys.discoverScreen).waitUntilVisible(
    timeout: const Duration(seconds: 20),
  );
  expect($('Keywords'), findsOneWidget);
}

Future<void> openProfileFromDiscover(PatrolIntegrationTester $) async {
  await $(TestKeys.discoverProfileButton).tap();
  await $.pumpAndSettle();
}

Future<void> navigateBackFromProfile(PatrolIntegrationTester $) async {
  await $(TestKeys.profileBackButton).tap();
  await $.pumpAndSettle(timeout: const Duration(seconds: 10));
}

/// Signed-in avatar lives in the collapsed discover header (top-right).
Future<void> waitForDiscoverSignedInAvatar(PatrolIntegrationTester $) async {
  final scrollable = find.descendant(
    of: find.byKey(TestKeys.discoverScreen),
    matching: find.byType(Scrollable),
  );

  for (var attempt = 0; attempt < 5; attempt++) {
    try {
      await $(TestKeys.discoverSignedInProfile).waitUntilVisible(
        timeout: const Duration(seconds: 3),
      );
      return;
    } catch (_) {
      await $.tester.drag(scrollable.first, const Offset(0, -280));
      await $.pumpAndSettle();
    }
  }

  await $(TestKeys.discoverSignedInProfile).waitUntilVisible(
    timeout: const Duration(seconds: 10),
  );
}

Future<void> tapBottomNavHome(PatrolIntegrationTester $) async {
  await $(TestKeys.bottomNavHome).tap();
  await $.pumpAndSettle();
}

Future<void> tapBottomNavSearch(PatrolIntegrationTester $) async {
  await $(TestKeys.bottomNavSearch).tap();
  await $.pumpAndSettle();
}

Future<void> completeGoogleSignIn(PatrolIntegrationTester $) async {
  if (Platform.isMacOS) return;

  if (await $.platform.mobile.isPermissionDialogVisible()) {
    await $.platform.mobile.grantPermissionWhenInUse();
  }

  await $(TestKeys.googleSignInButton).tap();

  // Native Google account picker — pumpAndSettle never completes while it is open.
  await Future<void>.delayed(const Duration(seconds: 4));

  if (Platform.isAndroid) {
    await _tapGoogleAccountInNativePicker($);
    await _dismissGoogleConsentIfShown($);
  }

  await Future<void>.delayed(const Duration(seconds: 2));
}

Future<void> _tapGoogleAccountInNativePicker(PatrolIntegrationTester $) async {
  final selectors = <AndroidSelector>[
    if (patrolGoogleEmail.isNotEmpty) ...[
      AndroidSelector(text: patrolGoogleEmail),
      AndroidSelector(textContains: patrolGoogleEmail),
      AndroidSelector(
        className: 'android.widget.TextView',
        textContains: patrolGoogleEmail,
      ),
    ],
    AndroidSelector(resourceName: 'com.google.android.gms:id/account_name'),
    AndroidSelector(resourceName: 'com.google.android.gms:id/container'),
  ];

  for (final selector in selectors) {
    try {
      await $.platform.android.tap(
        selector,
        timeout: const Duration(seconds: 8),
      );
      return;
    } catch (_) {}
  }

  fail(
    'Could not tap a Google account in the native picker. '
    'Add the account on the device and pass '
    '--dart-define=PATROL_GOOGLE_EMAIL=you@gmail.com',
  );
}

Future<void> _dismissGoogleConsentIfShown(PatrolIntegrationTester $) async {
  await Future<void>.delayed(const Duration(seconds: 1));

  for (final label in ['Continue', 'CONTINUE', 'Accept', 'ACCEPT', 'OK']) {
    try {
      await $.platform.android.tap(
        AndroidSelector(text: label),
        timeout: const Duration(seconds: 2),
      );
      return;
    } catch (_) {}
  }
}

Future<void> searchPublications(
  PatrolIntegrationTester $, {
  required String keyword,
}) async {
  await tapBottomNavSearch($);
  expect($('Search Publications'), findsOneWidget);

  const maxAttempts = 3;
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    final field = find.byKey(TestKeys.publicationSearchField);
    await $.tester.tap(field);
    await $.tester.enterText(field, keyword);
    await $.pumpAndSettle(timeout: const Duration(seconds: 5));

    try {
      await $(TestKeys.publicationTopicAutocompleteFirst).waitUntilVisible(
        timeout: const Duration(seconds: 20),
      );
      await $(TestKeys.publicationTopicAutocompleteFirst).tap();

      final resultsDeadline = DateTime.now().add(const Duration(seconds: 45));
      while (DateTime.now().isBefore(resultsDeadline)) {
        if (find.byKey(TestKeys.firstPublicationCard).evaluate().isNotEmpty) {
          await $(TestKeys.firstPublicationCard).scrollTo();
          try {
            await $(TestKeys.firstPublicationCard).waitUntilVisible(
              timeout: const Duration(seconds: 2),
            );
            return;
          } on Object catch (_) {}
        }
        await $.pump(const Duration(milliseconds: 300));
      }

      await $(TestKeys.firstPublicationCard).waitUntilVisible(
        timeout: const Duration(seconds: 5),
      );
      return;
    } on Object catch (_) {
      final hasApiError =
          find.textContaining('Lỗi:').evaluate().isNotEmpty;
      if (!hasApiError || attempt == maxAttempts) rethrow;
      await Future<void>.delayed(Duration(seconds: 2 * attempt));
    }
  }
}

Future<void> openFirstPublication(PatrolIntegrationTester $) async {
  await $(TestKeys.firstPublicationCard).scrollTo().tap();
  await $.pumpAndSettle(timeout: const Duration(seconds: 20));

  await $(TestKeys.publicationDetailScreen).waitUntilVisible(
    timeout: const Duration(seconds: 20),
  );
}

Future<void> tapBottomNavJournals(PatrolIntegrationTester $) async {
  await $(TestKeys.bottomNavJournals).tap();
  await $.pumpAndSettle(timeout: const Duration(seconds: 5));
}

Future<void> waitForJournalsHome(PatrolIntegrationTester $) async {
  await $(TestKeys.journalsScreen).waitUntilVisible(
    timeout: const Duration(seconds: 20),
  );

  final deadline = DateTime.now().add(const Duration(seconds: 60));
  var loaded = false;
  while (DateTime.now().isBefore(deadline)) {
    await $.pump(const Duration(milliseconds: 500));

    if (find.byKey(const ValueKey('leading_journals_error')).evaluate().isNotEmpty) {
      final retry = find.widgetWithText(ElevatedButton, 'Retry');
      if (retry.evaluate().isNotEmpty) {
        await $.tester.tap(retry);
        await $.pump(const Duration(milliseconds: 500));
        continue;
      }
      fail(
        'Journals API error. Run with --dart-define-from-file=.env for API_KEY.',
      );
    }

    if (find.byKey(const ValueKey('leading_journals_empty')).evaluate().isNotEmpty) {
      fail('Journals loaded but no results for this query.');
    }

    if (find.byKey(TestKeys.firstJournalTile).evaluate().isNotEmpty ||
        find.byKey(TestKeys.journalsOverview).evaluate().isNotEmpty) {
      loaded = true;
      break;
    }
  }

  if (!loaded) {
    fail(
      'Journals list did not load in time. '
      'Check network and pass --dart-define-from-file=.env.',
    );
  }

  if (find.byKey(TestKeys.journalsStatistics).evaluate().isNotEmpty) {
    await $(TestKeys.journalsStatistics).scrollTo();
    await $(TestKeys.journalsStatistics).waitUntilVisible(
      timeout: const Duration(seconds: 10),
    );
  }

  await $('Detailed Leaderboard').scrollTo();
  await $('Detailed Leaderboard').waitUntilVisible(
    timeout: const Duration(seconds: 10),
  );

  await $(TestKeys.firstJournalTile).scrollTo();
  await $(TestKeys.firstJournalTile).waitUntilVisible(
    timeout: const Duration(seconds: 10),
  );
}

Future<void> openFirstJournal(PatrolIntegrationTester $) async {
  await $(TestKeys.firstJournalTile).scrollTo().tap();
  await $.pumpAndSettle(timeout: const Duration(seconds: 10));

  await $(TestKeys.journalDetailScreen).scrollTo();
  await $(TestKeys.journalDetailScreen).waitUntilVisible(
    timeout: const Duration(seconds: 20),
  );
}

Future<void> signInAndOpenProfile(PatrolIntegrationTester $) async {
  await openProfileFromDiscover($);

  if (!Platform.isMacOS) {
    await completeGoogleSignIn($);
    await $(TestKeys.signedInProfile).waitUntilVisible(
      timeout: const Duration(seconds: 30),
    );
    await $.pumpAndSettle(timeout: const Duration(seconds: 5));
  }
}

Future<void> exportPdfReport(PatrolIntegrationTester $) async {
  await $(TestKeys.exportPdfButton).scrollTo().tap();

  final deadline = DateTime.now().add(const Duration(seconds: 120));
  while (DateTime.now().isBefore(deadline)) {
    await $.pump(const Duration(milliseconds: 500));

    if (find.textContaining('Report export failed:').evaluate().isNotEmpty) {
      final statusFinder = find.byKey(TestKeys.exportStatusMessage);
      if (statusFinder.evaluate().isNotEmpty) {
        final text = (statusFinder.evaluate().first.widget as Text).data;
        fail('PDF export failed: $text');
      }
      fail('PDF export failed.');
    }

    if (find.byKey(TestKeys.exportUploadedUrl).evaluate().isNotEmpty) {
      await $(TestKeys.exportUploadedUrl).scrollTo();
      await $(TestKeys.exportUploadedUrl).waitUntilVisible(
        timeout: const Duration(seconds: 10),
      );
      return;
    }
  }

  fail(
    'PDF export timed out. Ensure Firebase Storage rules allow authenticated '
    'uploads to reports/{uid}/ (see storage.rules).',
  );
}
