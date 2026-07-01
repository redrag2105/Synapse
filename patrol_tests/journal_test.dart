import 'package:patrol/patrol.dart';

import 'helpers/patrol_helpers.dart';

/// Test Cases 4 & 5 – Journals Navigation and Journal Details (testing.md)
void main() {
  patrolTest(
    'Journals tab shows statistics and journal list',
    ($) async {
      await pumpSynapseApp($);
      await waitForDiscoverHome($);

      await tapBottomNavJournals($);
      await waitForJournalsHome($);
    },
  );

  patrolTest(
    'Journal details screen shows journal information',
    ($) async {
      await pumpSynapseApp($);
      await waitForDiscoverHome($);

      await tapBottomNavJournals($);
      await waitForJournalsHome($);
      await openFirstJournal($);
    },
  );
}
