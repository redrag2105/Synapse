import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Keys and finders used by Patrol E2E tests (see testing.md).
class TestKeys {
  TestKeys._();

  static const discoverScreen = Key('discover_screen');
  static const homeScreen = Key('home_screen');
  static const keywordsScreen = Key('keywords_screen');
  static const discoverProfileButton = Key('discover_profile_button');
  static const discoverSignedInProfile = Key('discover_signed_in_profile');

  static const googleSignInButton = Key('google_sign_in_button');
  static const signOutButton = Key('sign_out_button');
  static const signedInProfile = Key('signed_in_profile');
  static const signedOutProfile = Key('signed_out_profile');

  static const bottomNavHome = Key('bottom_nav_home');
  static const bottomNavKeywords = Key('bottom_nav_keywords');
  static const bottomNavProfile = Key('bottom_nav_profile');
  /// Legacy alias — Home replaced Search as the center FAB.
  static const bottomNavSearch = bottomNavHome;

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

  static const keywordsStatistics = Key('keywords_statistics');
  static const firstKeywordTile = Key('first_keyword_tile');
  static const keywordDetailScreen = Key('keyword_detail_screen');

  static const remoteConfigSection = Key('remote_config_section');
  static const remoteConfigRefreshButton = Key('remote_config_refresh_button');
  static const remoteConfigMaxJournals = Key('remote_config_max_journals');
  static const remoteConfigMaxKeywords = Key('remote_config_max_keywords');

  static const exportPdfButton = Key('export_pdf_button');
  static const exportStatusMessage = Key('export_status_message');
  static const exportUploadedUrl = Key('export_uploaded_url');
}
