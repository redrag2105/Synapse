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
  await $(TestKeys.homeScreen).waitUntilVisible(
    timeout: const Duration(seconds: 20),
  );
  expect($('SYNAPSE'), findsWidgets);
}

Future<void> openProfileFromDiscover(PatrolIntegrationTester $) async {
  await $(TestKeys.discoverProfileButton).tap();
  await $.pumpAndSettle();
}

Future<void> navigateBackFromProfile(PatrolIntegrationTester $) async {
  await tapBottomNavHome($);
}

/// Signed-in avatar lives in the collapsed home header (top-right).
Future<void> waitForDiscoverSignedInAvatar(PatrolIntegrationTester $) async {
  final scrollable = find.descendant(
    of: find.byKey(TestKeys.homeScreen),
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
  await Future<void>.delayed(const Duration(seconds: 3));

  if (Platform.isAndroid) {
    await _tapGoogleAccountInNativePicker($);

    if (await _waitForSignedInProfile(
      $,
      timeout: const Duration(seconds: 12),
    )) {
      return;
    }

    await _dismissGoogleConsentIfShown($);

    await _waitForSignedInProfile(
      $,
      timeout: const Duration(seconds: 15),
    );
  }
}

Future<bool> _waitForSignedInProfile(
  PatrolIntegrationTester $, {
  required Duration timeout,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await $.pump(const Duration(milliseconds: 500));
    if (find.byKey(TestKeys.signedInProfile).evaluate().isNotEmpty) {
      return true;
    }
  }
  return false;
}

Future<void> _tapGoogleAccountInNativePicker(PatrolIntegrationTester $) async {
  final selectors = patrolGoogleEmail.isNotEmpty
      ? <AndroidSelector>[
          AndroidSelector(text: patrolGoogleEmail),
          AndroidSelector(textContains: patrolGoogleEmail),
          AndroidSelector(
            className: 'android.widget.TextView',
            textContains: patrolGoogleEmail,
          ),
        ]
      : <AndroidSelector>[
          AndroidSelector(resourceName: 'com.google.android.gms:id/account_name'),
        ];

  for (final selector in selectors) {
    try {
      await $.platform.android.tap(
        selector,
        timeout: const Duration(seconds: 5),
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
  // Only shown on some devices/accounts — skip if sign-in already completed.
  if (find.byKey(TestKeys.signedInProfile).evaluate().isNotEmpty) return;

  for (final label in ['Continue', 'Accept', 'OK']) {
    try {
      await $.platform.android.tap(
        AndroidSelector(text: label),
        timeout: const Duration(milliseconds: 800),
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
    await grantNotificationPermissionIfNeeded($);
    await $.pump(const Duration(milliseconds: 400));
  }
}

Future<void> signOutFromProfile(PatrolIntegrationTester $) async {
  await $(TestKeys.signOutButton).tap();
  await $.pumpAndSettle(timeout: const Duration(seconds: 15));
}

Future<void> waitForSignedOutProfile(PatrolIntegrationTester $) async {
  await $(TestKeys.signedOutProfile).waitUntilVisible(
    timeout: const Duration(seconds: 20),
  );
  await $(TestKeys.googleSignInButton).waitUntilVisible(
    timeout: const Duration(seconds: 10),
  );
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

Future<void> tapBottomNavKeywords(PatrolIntegrationTester $) async {
  await $(TestKeys.bottomNavKeywords).tap();
  await $.pumpAndSettle(timeout: const Duration(seconds: 5));
}

Future<void> waitForKeywordsHome(PatrolIntegrationTester $) async {
  await $(TestKeys.keywordsScreen).waitUntilVisible(
    timeout: const Duration(seconds: 20),
  );

  final deadline = DateTime.now().add(const Duration(seconds: 60));
  var loaded = false;
  while (DateTime.now().isBefore(deadline)) {
    await $.pump(const Duration(milliseconds: 500));

    if (find.byKey(const ValueKey('frequent_error')).evaluate().isNotEmpty) {
      fail(
        'Keywords API error. Run with --dart-define-from-file=.env for API_KEY.',
      );
    }

    final hasStats =
        find.byKey(TestKeys.keywordsStatistics).evaluate().isNotEmpty;
    final hasList =
        find.byKey(TestKeys.firstKeywordTile).evaluate().isNotEmpty;
    final hasEmpty =
        find.byKey(TestKeys.keywordsFrequentEmpty).evaluate().isNotEmpty;
    final hasTrending =
        find.byKey(const ValueKey('trending_data')).evaluate().isNotEmpty;

    // Personalized list may be empty (guest / no history); trending still loads.
    if (hasStats && (hasList || hasEmpty) && hasTrending) {
      loaded = true;
      break;
    }
  }

  if (!loaded) {
    fail(
      'Keywords screen did not load in time. '
      'Check network and pass --dart-define-from-file=.env.',
    );
  }

  await $(TestKeys.keywordsStatistics).waitUntilVisible(
    timeout: const Duration(seconds: 15),
  );
  await $('Top keyword').waitUntilVisible(timeout: const Duration(seconds: 10));
  await $('Trending now').waitUntilVisible(timeout: const Duration(seconds: 10));
  await $('Most Frequent Keywords').scrollTo();
  await $('Most Frequent Keywords').waitUntilVisible(
    timeout: const Duration(seconds: 10),
  );

  if (find.byKey(TestKeys.firstKeywordTile).evaluate().isNotEmpty) {
    await $(TestKeys.firstKeywordTile).scrollTo();
    await $(TestKeys.firstKeywordTile).waitUntilVisible(
      timeout: const Duration(seconds: 10),
    );
  } else {
    await $(TestKeys.keywordsFrequentEmpty).scrollTo();
    await $(TestKeys.keywordsFrequentEmpty).waitUntilVisible(
      timeout: const Duration(seconds: 10),
    );
  }
}

Future<void> openFirstKeyword(PatrolIntegrationTester $) async {
  // Prefer a personal frequent keyword; otherwise open a trending chip.
  if (find.byKey(TestKeys.firstKeywordTile).evaluate().isNotEmpty) {
    await $(TestKeys.firstKeywordTile).tap();
  } else {
    await $('Trending Keywords').scrollTo();
    final trendingChip = find.descendant(
      of: find.byKey(const ValueKey('trending_data')),
      matching: find.byType(InkWell),
    );
    if (trendingChip.evaluate().isEmpty) {
      fail('No keyword available to open (no history and no trending chips).');
    }
    await $.tester.tap(trendingChip.first);
  }

  await $.pumpAndSettle(timeout: const Duration(seconds: 10));

  await $(TestKeys.keywordDetailScreen).waitUntilVisible(
    timeout: const Duration(seconds: 20),
  );
  await $('Keyword Detail').waitUntilVisible(
    timeout: const Duration(seconds: 10),
  );
  await $('Publication trends').waitUntilVisible(
    timeout: const Duration(seconds: 10),
  );
}

Future<void> tapBottomNavProfile(PatrolIntegrationTester $) async {
  await $(TestKeys.bottomNavProfile).tap();
  await $.pumpAndSettle(timeout: const Duration(seconds: 5));
}

Future<void> waitForSignedInProfile(PatrolIntegrationTester $) async {
  await $(TestKeys.signedInProfile).waitUntilVisible(
    timeout: const Duration(seconds: 30),
  );
  await grantNotificationPermissionIfNeeded($);
  expect($('Profile'), findsWidgets);
  expect($('Active'), findsOneWidget);
  expect($('Notification Center'), findsOneWidget);
}

/// Dismisses the Android notification permission dialog shown after profile init.
/// Safe to call multiple times — returns immediately after the first successful
/// grant (or once we've confirmed no dialog is showing).
bool _notificationPermissionHandled = false;

Future<void> grantNotificationPermissionIfNeeded(
  PatrolIntegrationTester $,
) async {
  if (Platform.isMacOS || _notificationPermissionHandled) return;

  // Short window for profile initialize() to present the system dialog.
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (DateTime.now().isBefore(deadline)) {
    try {
      if (await $.platform.mobile.isPermissionDialogVisible()) {
        await $.platform.mobile.grantPermissionWhenInUse();
        _notificationPermissionHandled = true;
        await $.pump(const Duration(milliseconds: 300));
        return;
      }
    } catch (_) {}
    await $.pump(const Duration(milliseconds: 200));
  }

  // No dialog appeared (already granted / not requested) — don't retry later.
  _notificationPermissionHandled = true;
}

bool _remoteConfigValuesReady() {
  final journalsTile = find.byKey(TestKeys.remoteConfigMaxJournals);
  final keywordsTile = find.byKey(TestKeys.remoteConfigMaxKeywords);
  if (journalsTile.evaluate().isEmpty || keywordsTile.evaluate().isEmpty) {
    return false;
  }

  final journalValues = find
      .descendant(of: journalsTile, matching: find.byType(Text))
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .whereType<String>();
  final keywordValues = find
      .descendant(of: keywordsTile, matching: find.byType(Text))
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .whereType<String>();

  final journalsReady =
      journalValues.any((v) => v != '—' && v != 'Max journals');
  final keywordsReady =
      keywordValues.any((v) => v != '—' && v != 'Max keywords');
  return journalsReady && keywordsReady;
}

Future<void> waitForRemoteConfigValues(PatrolIntegrationTester $) async {
  // Scroll to the refresh button (hit-testable). The section card key alone is
  // not hit-testable for Patrol, which caused an immediate timeout after Allow.
  await $('Refresh values').scrollTo();
  await $(TestKeys.remoteConfigRefreshButton).waitUntilVisible(
    timeout: const Duration(seconds: 15),
  );
  await $('Max journals').waitUntilVisible(timeout: const Duration(seconds: 10));
  await $('Max keywords').waitUntilVisible(timeout: const Duration(seconds: 5));

  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (DateTime.now().isBefore(deadline)) {
    await $.pump(const Duration(milliseconds: 250));

    if (find.text('Could not load Remote Config values.').evaluate().isNotEmpty) {
      fail('Remote Config failed to load.');
    }

    if (_remoteConfigValuesReady()) {
      expect($(TestKeys.remoteConfigRefreshButton), findsOneWidget);
      return;
    }
  }

  fail('Remote Config values did not load in time.');
}

Future<void> refreshRemoteConfigValues(PatrolIntegrationTester $) async {
  await $(TestKeys.remoteConfigRefreshButton).tap();

  // Refresh briefly shows "—" then restores numbers — don't re-run full scroll/grant.
  final deadline = DateTime.now().add(const Duration(seconds: 15));
  while (DateTime.now().isBefore(deadline)) {
    await $.pump(const Duration(milliseconds: 250));

    if (find.text('Could not load Remote Config values.').evaluate().isNotEmpty) {
      fail('Remote Config refresh failed.');
    }

    if (_remoteConfigValuesReady()) return;
  }

  fail('Remote Config values did not reload after refresh.');
}
