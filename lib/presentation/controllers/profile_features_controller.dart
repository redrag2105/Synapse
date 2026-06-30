import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/data/services/profile_firebase_service.dart';
import 'package:synapse/domain/entities/profile_features_state.dart';
import 'package:synapse/presentation/controllers/app_remote_config_controller.dart';

final profileFirebaseServiceProvider = Provider<ProfileFirebaseService>((ref) {
  return ProfileFirebaseService();
});

final profileFeaturesControllerProvider =
    NotifierProvider.autoDispose<ProfileFeaturesController, ProfileFeaturesState>(
  ProfileFeaturesController.new,
);

class ProfileFeaturesController extends Notifier<ProfileFeaturesState> {
  User? _activeUser;
  Future<void>? _initializeFuture;

  @override
  ProfileFeaturesState build() => const ProfileFeaturesState();

  Future<void> initialize(User user) async {
    if (_activeUser?.uid == user.uid) return;

    if (_initializeFuture != null) {
      await _initializeFuture;
      return;
    }

    _initializeFuture = _initializeForUser(user);
    try {
      await _initializeFuture;
    } finally {
      _initializeFuture = null;
    }
  }

  Future<void> _initializeForUser(User user) async {
    _activeUser = user;
    await ref.read(profileFirebaseServiceProvider).logFcmToken();
    await ref.read(profileFirebaseServiceProvider).requestNotificationPermission();
  }

  Future<void> refreshRemoteConfig() async {
    state = state.copyWith(isLoadingRemoteConfig: true, clearStatusMessage: true);
    try {
      await ref.read(appRemoteConfigProvider.notifier).load(force: true);
      state = state.copyWith(isLoadingRemoteConfig: false);
    } catch (_) {
      state = state.copyWith(
        isLoadingRemoteConfig: false,
        statusMessage: 'Could not load Remote Config values.',
      );
    }
  }

  Future<void> exportReport() async {
    final user = _activeUser;
    if (user == null || state.isExportingReport) return;

    final config = ref.read(appRemoteConfigProvider);

    state = state.copyWith(
      isExportingReport: true,
      clearStatusMessage: true,
      clearUploadedReportUrl: true,
    );

    try {
      final url = await ref.read(profileFirebaseServiceProvider).exportDashboardReport(
            user: user,
            maxJournals: config.maxJournalsDisplay,
            maxKeywords: config.maxKeywordsDisplay,
          );
      state = state.copyWith(
        isExportingReport: false,
        uploadedReportUrl: url,
        statusMessage: 'Report uploaded successfully.',
      );
    } catch (e) {
      state = state.copyWith(
        isExportingReport: false,
        statusMessage: 'Report export failed: $e',
      );
    }
  }

  Future<void> recordHandledException() async {
    await ref.read(profileFirebaseServiceProvider).recordHandledException();
    state = state.copyWith(
      statusMessage: 'Handled exception recorded in Crashlytics.',
    );
  }

  void triggerTestCrash() {
    ref.read(profileFirebaseServiceProvider).triggerTestCrash();
  }
}
