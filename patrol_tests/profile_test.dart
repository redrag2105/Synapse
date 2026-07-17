import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:synapse/app/config/test_keys.dart';

import 'helpers/patrol_helpers.dart';

/// Test Case 8 – Profile Navigation (testing.md)
void main() {
  patrolTest(
    'Profile tab shows signed-in user profile information',
    ($) async {
      await pumpSynapseApp($);
      await waitForDiscoverHome($);

      await tapBottomNavProfile($);

      if (!Platform.isMacOS) {
        if (find.byKey(TestKeys.signedOutProfile).evaluate().isNotEmpty) {
          await completeGoogleSignIn($);
        }
        await waitForSignedInProfile($);
        expect($(TestKeys.signOutButton), findsOneWidget);
      } else {
        expect(
          find.byKey(TestKeys.signedOutProfile).evaluate().isNotEmpty ||
              find.byKey(TestKeys.signedInProfile).evaluate().isNotEmpty,
          isTrue,
        );
      }
    },
  );
}
