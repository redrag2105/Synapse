import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:synapse/app/config/test_keys.dart';

import 'helpers/patrol_helpers.dart';

/// Test Case 1 – Google Sign-In (testing.md)
void main() {
  patrolTest(
    'Google Sign-In navigates to Home with signed-in profile',
    ($) async {
      await pumpSynapseApp($);
      await waitForDiscoverHome($);

      await openProfileFromDiscover($);
      expect($('Sign in to continue'), findsOneWidget);

      if (!Platform.isMacOS) {
        await completeGoogleSignIn($);
        await $(TestKeys.signedInProfile).waitUntilVisible(
          timeout: const Duration(seconds: 30),
        );
        expect($('Notification Center'), findsOneWidget);
      }

      await navigateBackFromProfile($);

      await waitForDiscoverHome($);

      if (!Platform.isMacOS) {
        await waitForDiscoverSignedInAvatar($);
      }
    },
  );
}
