import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:synapse/app/config/test_keys.dart';

import 'helpers/patrol_helpers.dart';

/// Test Case 9 – PDF Export (testing.md)
void main() {
  patrolTest(
    'PDF export uploads report to Firebase Storage',
    ($) async {
      await pumpSynapseApp($);
      await waitForDiscoverHome($);

      await signInAndOpenProfile($);

      if (!Platform.isMacOS) {
        await exportPdfReport($);
        expect(find.byKey(TestKeys.exportUploadedUrl), findsOneWidget);
      }
    },
  );
}
