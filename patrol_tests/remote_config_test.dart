import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:synapse/app/config/test_keys.dart';

import 'helpers/patrol_helpers.dart';

/// Test Case 10 – Remote Config (testing.md)
void main() {
  patrolTest(
    'Remote Config values are retrieved and displayed',
    ($) async {
      await pumpSynapseApp($);
      await waitForDiscoverHome($);

      await signInAndOpenProfile($);

      if (!Platform.isMacOS) {
        await waitForRemoteConfigValues($);
        await refreshRemoteConfigValues($);

        expect($(TestKeys.remoteConfigMaxJournals), findsOneWidget);
        expect($(TestKeys.remoteConfigMaxKeywords), findsOneWidget);
        expect($('Max journals'), findsOneWidget);
        expect($('Max keywords'), findsOneWidget);
      }
    },
  );
}
