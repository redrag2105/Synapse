import 'dart:io';

import 'package:patrol/patrol.dart';

import 'helpers/patrol_helpers.dart';

/// Test Case 11 – Logout (testing.md)
void main() {
  patrolTest(
    'Logout returns to sign-in screen',
    ($) async {
      await pumpSynapseApp($);
      await waitForDiscoverHome($);

      if (!Platform.isMacOS) {
        await signInAndOpenProfile($);
        await signOutFromProfile($);
        await waitForSignedOutProfile($);
      }
    },
  );
}
