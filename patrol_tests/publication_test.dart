import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:synapse/app/config/test_keys.dart';

import 'helpers/patrol_helpers.dart';

/// Test Cases 2 & 3 – Topic Search and Publication Details (testing.md)
void main() {
  patrolTest(
    'Topic search shows publication results',
    ($) async {
      await pumpSynapseApp($);
      await waitForDiscoverHome($);

      await searchPublications($, keyword: 'machine learning');

      expect($(TestKeys.firstPublicationCard), findsOneWidget);
    },
  );

  patrolTest(
    'Publication details screen shows publication information',
    ($) async {
      await pumpSynapseApp($);
      await waitForDiscoverHome($);

      await searchPublications($, keyword: 'machine learning');
      await openFirstPublication($);

      expect($(TestKeys.publicationDetailScreen), findsOneWidget);
      expect($(Scrollable).which<Scrollable>((s) => s.axis == Axis.vertical),
          findsWidgets);
    },
  );
}
