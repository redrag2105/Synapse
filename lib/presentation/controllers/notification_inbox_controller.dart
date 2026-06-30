import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/domain/entities/profile_features_state.dart';

final notificationInboxProvider =
    NotifierProvider<NotificationInboxController, List<ProfileNotification>>(
  NotificationInboxController.new,
);

class NotificationInboxController extends Notifier<List<ProfileNotification>> {
  StreamSubscription<RemoteMessage>? _subscription;
  bool _listening = false;

  @override
  List<ProfileNotification> build() {
    _startListening();
    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
      _listening = false;
    });
    return const [];
  }

  void _startListening() {
    if (_listening) return;
    _listening = true;

    _subscription = FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final item = ProfileNotification(
        id: message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification?.title ?? 'Research update',
        body: notification?.body ?? 'New notification received.',
        receivedAt: DateTime.now(),
      );
      state = [item, ...state];
    });
  }
}
