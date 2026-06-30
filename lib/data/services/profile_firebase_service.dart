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
    required List<Map<String, String>>
    notifications, // Truyền danh sách thông báo vào đây
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Report export is not supported on web.');
    }

    final pdf = pw.Document();
    final generatedAt = DateTime.now();

    // Định dạng màu sắc chuẩn UI/UX
    final primaryColor = PdfColor.fromHex('#1E3A8A'); // Xanh dương đậm
    final secondaryColor = PdfColor.fromHex('#F3F4F6'); // Xám nhạt nền
    final accentColor = PdfColor.fromHex('#3B82F6'); // Xanh dương sáng
    final textColor = PdfColor.fromHex('#1F2937'); // Xám đen

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // --- HEADER ---
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Synapse Analytics',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Research Trend Dashboard Report',
                      style: pw.TextStyle(
                        color: PdfColors.grey300,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  '${generatedAt.day}/${generatedAt.month}/${generatedAt.year}',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // --- ACCOUNT INFO ---
          pw.Text(
            'Account Information',
            style: pw.TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(color: accentColor, thickness: 1),
          pw.SizedBox(height: 8),
          pw.Text(
            'User: ${user.displayName ?? "No Name"}',
            style: pw.TextStyle(color: textColor, fontSize: 14),
          ),
          pw.Text(
            'Email: ${user.email ?? user.uid}',
            style: pw.TextStyle(color: textColor, fontSize: 14),
          ),
          pw.SizedBox(height: 24),

          // --- DASHBOARD SUMMARY ---
          pw.Text(
            'Dashboard Settings',
            style: pw.TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(color: accentColor, thickness: 1),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: secondaryColor,
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Text(
                      'Max Journals',
                      style: pw.TextStyle(
                        color: PdfColors.grey600,
                        fontSize: 12,
                      ),
                    ),
                    pw.Text(
                      '$maxJournals',
                      style: pw.TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Container(width: 1, height: 30, color: PdfColors.grey400),
                pw.Column(
                  children: [
                    pw.Text(
                      'Max Keywords',
                      style: pw.TextStyle(
                        color: PdfColors.grey600,
                        fontSize: 12,
                      ),
                    ),
                    pw.Text(
                      '$maxKeywords',
                      style: pw.TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // --- NOTIFICATION CENTER ---
          pw.Text(
            'Recent Notifications',
            style: pw.TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(color: accentColor, thickness: 1),
          pw.SizedBox(height: 8),

          if (notifications.isEmpty)
            pw.Text(
              'No notifications recorded.',
              style: pw.TextStyle(
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            )
          else
            pw.ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: accentColor, width: 4),
                    ),
                    color: secondaryColor,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        notif['title'] ?? 'No Title',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        notif['body'] ?? 'No Body',
                        style: pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],

        // --- FOOTER ---
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Generated by Synapse - Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(color: PdfColors.grey500, fontSize: 10),
          ),
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
