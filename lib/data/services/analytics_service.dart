import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:synapse/app/utils/app_logger.dart';

/// Firebase Analytics events required by firebase.md.
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static String _clip(String value, [int max = 100]) {
    if (value.length <= max) return value;
    return value.substring(0, max);
  }

  Future<void> _log(String event, [Map<String, Object>? parameters]) async {
    if (kIsWeb) return;

    try {
      await _analytics.logEvent(name: event, parameters: parameters);
      AppLogger.i('Analytics: $event ${parameters ?? ''}');
    } catch (e, stackTrace) {
      AppLogger.w('Analytics failed: $event', e);
      AppLogger.d(stackTrace.toString());
    }
  }

  Future<void> setUserId(String? userId) async {
    if (kIsWeb) return;
    await _analytics.setUserId(id: userId);
  }

  Future<void> logLogin({String method = 'google'}) async {
    if (kIsWeb) return;

    try {
      await _analytics.logLogin(loginMethod: method);
      AppLogger.i('Analytics: login (method=$method)');
    } catch (e, stackTrace) {
      AppLogger.w('Analytics failed: login', e);
      AppLogger.d(stackTrace.toString());
    }
  }

  Future<void> logLogout() async {
    await _log('logout');
    await setUserId(null);
  }

  Future<void> logSearchTopic(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;

    await _log('search_topic', {'keyword': _clip(trimmed)});
  }

  Future<void> logViewPublication({
    required String publicationTitle,
    required int publicationYear,
  }) async {
    await _log('view_publication', {
      'publication_title': _clip(publicationTitle),
      'publication_year': publicationYear,
    });
  }

  Future<void> logViewJournal({required String journalName}) async {
    await _log('view_journal', {'journal_name': _clip(journalName)});
  }

  Future<void> logViewKeyword({required String keyword}) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;

    await _log('view_keyword', {'keyword': _clip(trimmed)});
  }

  Future<void> logExportPdf({required String topic}) async {
    await _log('export_pdf', {'topic': _clip(topic)});
  }
}
