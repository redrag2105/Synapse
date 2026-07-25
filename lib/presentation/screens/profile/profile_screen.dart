import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/presentation/controllers/analytics_providers.dart';
import 'package:synapse/presentation/controllers/auth_providers.dart';
import 'package:synapse/presentation/controllers/profile_features_controller.dart';
import 'package:synapse/presentation/controllers/tab_bar_ui_controller.dart';
import 'package:synapse/presentation/screens/profile/widgets/profile_signed_in_view.dart';
import 'package:synapse/presentation/screens/profile/widgets/profile_signed_out_view.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeProfileFeatures());
  }

  void _initializeProfileFeatures() {
    final user = ref.read(authStateProvider).asData?.value;
    if (user != null) {
      ref.read(profileFeaturesControllerProvider.notifier).initialize(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    ref.listen(authStateProvider, (previous, next) {
      final user = next.asData?.value;
      final previousUser = previous?.asData?.value;
      if (user != null && previousUser?.uid != user.uid) {
        ref.read(profileFeaturesControllerProvider.notifier).initialize(user);
      }
    });

    // IndexedStack keeps Profile alive — re-log FCM whenever this tab is selected.
    ref.listen<int>(shellTabIndexProvider, (previous, next) {
      if (next != ShellTabIndex.profile || previous == next) return;
      final user = ref.read(authStateProvider).asData?.value;
      if (user != null) {
        ref.read(profileFeaturesControllerProvider.notifier).initialize(user);
      }
    });

    // Crashlytics demos remain available for guests and signed-in users.
    ref.watch(profileFeaturesControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Auth error: $error')),
        data: (user) {
          if (user == null) {
            return ProfileSignedOutView(
              topPadding: topPadding,
              isSigningIn: _isSigningIn,
              onSignIn: _signInWithGoogle,
            );
          }

          return ProfileSignedInView(
            topPadding: topPadding,
            user: user,
            onSignOut: () async {
              final analytics = ref.read(analyticsServiceProvider);
              final auth = ref.read(authServiceProvider);
              final profileService = ref.read(profileFirebaseServiceProvider);
              await analytics.logLogout();
              await profileService.deactivateCurrentDevice(user);
              await auth.signOut();
            },
          );
        },
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    if (_isSigningIn) return;

    setState(() => _isSigningIn = true);

    try {
      final credential = await ref.read(authServiceProvider).signInWithGoogle();
      final analytics = ref.read(analyticsServiceProvider);
      await analytics.setUserId(credential.user?.uid);
      await analytics.logLogin();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showError(e.message ?? 'Sign-in failed. Please try again.');
      }
    } catch (_) {
      if (mounted) {
        _showError('Sign-in was cancelled or failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
