import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:synapse/app/config/test_keys.dart';

import 'helpers/patrol_helpers.dart';

/// Test Cases 6 & 7 – Keywords Navigation and Keyword Details (testing.md)
void main() {
  patrolTest(
    'Keywords tab shows statistics and keyword list',
    ($) async {
      await pumpSynapseApp($);
      await waitForDiscoverHome($);

      await tapBottomNavKeywords($);
      await waitForKeywordsHome($);

      expect($(TestKeys.keywordsStatistics), findsOneWidget);
      expect($(TestKeys.firstKeywordTile), findsOneWidget);
    },
  );

  patrolTest(
    'Keyword details screen shows keyword analysis',
    ($) async {
      await pumpSynapseApp($);
      await waitForDiscoverHome($);

      await tapBottomNavKeywords($);
      await waitForKeywordsHome($);
      await openFirstKeyword($);

      expect($(TestKeys.keywordDetailScreen), findsOneWidget);
      expect($('Publication trends'), findsOneWidget);

      await $('Top contributing authors').scrollTo();
      expect($('Top contributing authors'), findsOneWidget);

      await $('Related journals').scrollTo();
      expect($('Related journals'), findsOneWidget);

      await $('Related publications').scrollTo();
      expect($('Related publications'), findsOneWidget);
    },
  );
}
