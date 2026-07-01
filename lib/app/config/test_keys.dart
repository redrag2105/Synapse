import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Keys and finders used by Patrol E2E tests (see testing.md).
class TestKeys {
  TestKeys._();

  static const discoverScreen = Key('discover_screen');
  static const discoverProfileButton = Key('discover_profile_button');
  static const discoverSignedInProfile = Key('discover_signed_in_profile');

  static const googleSignInButton = Key('google_sign_in_button');
  static const profileBackButton = Key('profile_back_button');
  static const signedInProfile = Key('signed_in_profile');

  static const bottomNavHome = Key('bottom_nav_home');
  static const bottomNavSearch = Key('bottom_nav_search');

  static const publicationSearchField = Key('publication_search_field');
  static const publicationTopicAutocompleteFirst =
      Key('publication_topic_autocomplete_first');
  static const publicationResultsList = Key('publication_results_list');
  static const firstPublicationCard = Key('first_publication_card');

  static const publicationDetailScreen = Key('publication_detail_screen');

  static const bottomNavJournals = Key('bottom_nav_journals');
  static const journalsScreen = Key('journals_screen');
  static const journalsOverview = Key('journals_overview');
  static const journalsStatistics = Key('journals_statistics');
  static const firstJournalTile = Key('first_journal_tile');
  static const journalDetailScreen = Key('journal_detail_screen');

  static const exportPdfButton = Key('export_pdf_button');
  static const exportStatusMessage = Key('export_status_message');
  static const exportUploadedUrl = Key('export_uploaded_url');
}
