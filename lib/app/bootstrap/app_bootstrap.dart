import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'
    show FlutterError, PlatformDispatcher, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:synapse/app/config/google_oauth_config.dart';
import 'package:synapse/firebase_options.dart';

/// Shared startup used by [main] and Patrol integration tests.
///
/// When [forPatrolTest] is true, skips bindings and error hooks that conflict
/// with [PatrolBinding] (see Patrol setup docs).
Future<void> bootstrapSynapseApp({bool forPatrolTest = false}) async {
  if (!forPatrolTest) {
    WidgetsFlutterBinding.ensureInitialized();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    // Crashlytics collects for all users — not gated on sign-in.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    await GoogleSignIn.instance.initialize(
      // Web client ID — required on Android for Firebase ID tokens.
      serverClientId: GoogleOAuthConfig.webClientId,
    );
  }

  if (!forPatrolTest) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  if (!forPatrolTest) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(systemNavigationBarContrastEnforced: false),
    );
  }
}
