import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:synapse/app/utils/app_logger.dart';

class ProfileFirebaseService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void>? _permissionInFlight;
  bool _permissionResolved = false;

  Future<void> requestNotificationPermission() async {
    if (_permissionResolved) return;

    if (_permissionInFlight != null) {
      await _permissionInFlight;
      return;
    }

    _permissionInFlight = _requestPermissionSafely();
    try {
      await _permissionInFlight;
      _permissionResolved = true;
    } finally {
      _permissionInFlight = null;
    }
  }

  Future<void> logFcmToken() async {
    if (kIsWeb) return;

    try {
      final token = await _messaging.getToken();
      AppLogger.i(
        '================== FCM TOKEN =====================\n'
        '${token ?? 'No token available'}\n'
        '===================================================',
      );
    } catch (e, stackTrace) {
      AppLogger.w('Could not get FCM token', e);
      AppLogger.d(stackTrace.toString());
    }
  }

  Future<void> _requestPermissionSafely() async {
    try {
      await _messaging.requestPermission();
    } on FirebaseException {
      // Non-fatal if already in progress or dismissed.
    }
  }

  Future<String> exportDashboardReport({
    required User user,
    required int maxJournals,
    required int maxKeywords,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Report export is not supported on web.');
    }

    final pdf = pw.Document();
    final generatedAt = DateTime.now();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Synapse Analytics Report',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Generated: ${generatedAt.toIso8601String()}'),
            pw.SizedBox(height: 20),
            pw.Text('Account: ${user.displayName ?? user.email ?? user.uid}'),
            pw.SizedBox(height: 24),
            pw.Text(
              'Dashboard summary',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Bullet(text: 'Max journals displayed: $maxJournals'),
            pw.Bullet(text: 'Max keywords displayed: $maxKeywords'),
            pw.SizedBox(height: 16),
            pw.Text(
              'This report was exported from the Synapse research dashboard.',
            ),
          ],
        ),
      ),
    );

    final bytes = await pdf.save();
    final tempDir = await getTemporaryDirectory();
    final fileName = 'synapse_report_${generatedAt.millisecondsSinceEpoch}.pdf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    final ref = _storage.ref().child('reports/${user.uid}/$fileName');
    await ref.putFile(file, SettableMetadata(contentType: 'application/pdf'));
    return ref.getDownloadURL();
  }

  Future<void> recordHandledException() async {
    await FirebaseCrashlytics.instance.recordError(
      Exception('Synapse handled exception demo'),
      StackTrace.current,
      reason: 'Profile Crashlytics demo',
    );
  }

  void triggerTestCrash() {
    FirebaseCrashlytics.instance.crash();
  }
}
