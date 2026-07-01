import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    await GoogleSignIn.instance.initialize();
  }

  if (!forPatrolTest) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
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
