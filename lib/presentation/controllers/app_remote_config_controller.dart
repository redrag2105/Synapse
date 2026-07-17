import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/data/services/remote_config_service.dart';
import 'package:synapse/presentation/controllers/leading_journals_controller.dart';
import 'package:synapse/presentation/controllers/most_frequent_keywords_controller.dart';
import 'package:synapse/presentation/controllers/user_frequent_keywords_controller.dart';

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

final appRemoteConfigProvider =
    NotifierProvider<AppRemoteConfigController, RemoteConfigValues>(
  AppRemoteConfigController.new,
);

class AppRemoteConfigController extends Notifier<RemoteConfigValues> {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  @override
  RemoteConfigValues build() => RemoteConfigValues.defaults;

  Future<void> load({bool force = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      final values =
          await ref.read(remoteConfigServiceProvider).fetch(force: force);
      final changed = values.maxJournalsDisplay != state.maxJournalsDisplay ||
          values.maxKeywordsDisplay != state.maxKeywordsDisplay;
      state = values;

      if (changed) {
        ref.invalidate(mostFrequentKeywordsControllerProvider);
        ref.invalidate(userFrequentKeywordsProvider);
        ref.invalidate(leadingJournalsControllerProvider);
      }
    } finally {
      _isLoading = false;
    }
  }
}
