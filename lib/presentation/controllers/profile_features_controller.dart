import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/data/services/profile_firebase_service.dart';
import 'package:synapse/domain/entities/profile_features_state.dart';
import 'package:synapse/presentation/controllers/analytics_providers.dart';
import 'package:synapse/presentation/controllers/app_remote_config_controller.dart';
import 'package:synapse/presentation/controllers/notification_inbox_controller.dart';

final profileFirebaseServiceProvider = Provider<ProfileFirebaseService>((ref) {
  return ProfileFirebaseService();
});

final profileFeaturesControllerProvider =
    NotifierProvider.autoDispose<
      ProfileFeaturesController,
      ProfileFeaturesState
    >(ProfileFeaturesController.new);

class ProfileFeaturesController extends Notifier<ProfileFeaturesState> {
  User? _activeUser;
  Future<void>? _initializeFuture;

  @override
  ProfileFeaturesState build() {
    ref.onDispose(() {
      _activeUser = null;
      _initializeFuture = null;
    });
    return const ProfileFeaturesState();
  }

  Future<void> initialize(User user) async {
    if (_activeUser?.uid == user.uid) return;

    if (_initializeFuture != null) {
      await _initializeFuture;
      if (!ref.mounted) return;
      if (_activeUser?.uid == user.uid) return;
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
    final firebaseService = ref.read(profileFirebaseServiceProvider);

    await firebaseService.logFcmToken();
    if (!ref.mounted) return;

    await firebaseService.requestNotificationPermission();
  }

  Future<void> refreshRemoteConfig() async {
    state = state.copyWith(
      isLoadingRemoteConfig: true,
      clearStatusMessage: true,
    );

    final remoteConfig = ref.read(appRemoteConfigProvider.notifier);

    try {
      await remoteConfig.load(force: true);
      if (!ref.mounted) return;
      state = state.copyWith(isLoadingRemoteConfig: false);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoadingRemoteConfig: false,
        statusMessage: 'Could not load Remote Config values.',
      );
    }
  }

  Future<void> exportReport() async {
    final user = _activeUser ?? FirebaseAuth.instance.currentUser;
    if (user == null || state.isExportingReport) {
      if (user == null) {
        state = state.copyWith(
          statusMessage: 'Sign in required to export a report.',
        );
      }
      return;
    }

    _activeUser ??= user;

    final config = ref.read(appRemoteConfigProvider);
    final inbox = ref.read(notificationInboxProvider);
    final profileService = ref.read(profileFirebaseServiceProvider);
    final analytics = ref.read(analyticsServiceProvider);

    state = state.copyWith(
      isExportingReport: true,
      clearStatusMessage: true,
      clearUploadedReportUrl: true,
    );

    try {
      final notificationMaps = inbox
          .take(8)
          .map((n) => {'title': n.title, 'body': n.body})
          .toList();

      final url = await profileService.exportDashboardReport(
        user: user,
        maxJournals: config.maxJournalsDisplay,
        maxKeywords: config.maxKeywordsDisplay,
        notifications: notificationMaps,
      );

      if (!ref.mounted) return;

      await analytics.logExportPdf(topic: 'Synapse Dashboard Report');

      if (!ref.mounted) return;

      state = state.copyWith(
        isExportingReport: false,
        uploadedReportUrl: url,
        statusMessage: 'Report uploaded successfully.',
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isExportingReport: false,
        statusMessage: 'Report export failed: $e',
      );
    }
  }

  Future<void> recordHandledException() async {
    final profileService = ref.read(profileFirebaseServiceProvider);
    await profileService.recordHandledException();
  }

  void triggerTestCrash() {
    ref.read(profileFirebaseServiceProvider).triggerTestCrash();
  }
}
