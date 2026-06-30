import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/routes/app_routes.dart';
import 'package:synapse/presentation/controllers/app_remote_config_controller.dart';
import 'package:synapse/presentation/controllers/notification_inbox_controller.dart';
import 'package:synapse/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    await GoogleSignIn.instance.initialize();
  }

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarContrastEnforced: false),
  );
  runApp(const ProviderScope(child: SynapseApp()));
}

class SynapseApp extends ConsumerStatefulWidget {
  const SynapseApp({super.key});

  @override
  ConsumerState<SynapseApp> createState() => _SynapseAppState();
}

class _SynapseAppState extends ConsumerState<SynapseApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appRemoteConfigProvider.notifier).load();
      ref.read(notificationInboxProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Synapse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E65F3),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.surfaceGray,
        useMaterial3: true,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
