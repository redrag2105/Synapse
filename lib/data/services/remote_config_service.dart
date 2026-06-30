import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigValues {
  final int maxJournalsDisplay;
  final int maxKeywordsDisplay;

  const RemoteConfigValues({
    required this.maxJournalsDisplay,
    required this.maxKeywordsDisplay,
  });

  static const defaults = RemoteConfigValues(
    maxJournalsDisplay: 25,
    maxKeywordsDisplay: 10,
  );
}

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _ready = false;

  static const maxJournalsKey = 'max_journals_display';
  static const maxKeywordsKey = 'max_keywords_display';

  Future<void> _ensureReady() async {
    if (_ready) return;

    await _remoteConfig.setDefaults({
      maxJournalsKey: RemoteConfigValues.defaults.maxJournalsDisplay,
      maxKeywordsKey: RemoteConfigValues.defaults.maxKeywordsDisplay,
    });
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(minutes: 5),
      ),
    );
    _ready = true;
  }

  Future<RemoteConfigValues> fetch({bool force = false}) async {
    await _ensureReady();

    if (force) {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: Duration.zero,
        ),
      );
    }

    await _remoteConfig.fetchAndActivate();

    return RemoteConfigValues(
      maxJournalsDisplay: _readInt(
        maxJournalsKey,
        fallback: RemoteConfigValues.defaults.maxJournalsDisplay,
      ),
      maxKeywordsDisplay: _readInt(
        maxKeywordsKey,
        fallback: RemoteConfigValues.defaults.maxKeywordsDisplay,
      ),
    );
  }

  int _readInt(String key, {required int fallback}) {
    try {
      return _remoteConfig.getValue(key).asInt();
    } catch (_) {
      return fallback;
    }
  }
}
