import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/presentation/controllers/auth_providers.dart';
import 'package:synapse/presentation/screens/auth/widgets/google_sign_in_button.dart';
import 'package:synapse/presentation/widgets/user_avatar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Auth error: $error')),
        data: (user) {
          if (user == null) {
            return _ProfileSignInGate(
              topPadding: topPadding,
              isSigningIn: _isSigningIn,
              onSignIn: _signInWithGoogle,
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _SignedInHero(
                  topPadding: topPadding,
                  user: user,
                  onSignOut: () => ref.read(authServiceProvider).signOut(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _ProfileMenuCard(
                      icon: CupertinoIcons.bell,
                      title: 'Research Alerts',
                      subtitle: 'Get notified when topics trend upward.',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _ProfileMenuCard(
                      icon: CupertinoIcons.bookmark,
                      title: 'Saved Publications',
                      subtitle: 'Your bookmarked papers and reading list.',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _ProfileMenuCard(
                      icon: CupertinoIcons.gear,
                      title: 'Settings',
                      subtitle:
                          'Notifications, data sources, and display options.',
                      onTap: () {},
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    if (_isSigningIn) return;

    setState(() => _isSigningIn = true);

    try {
      await ref.read(authServiceProvider).signInWithGoogle();
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

class _ProfileSignInGate extends StatelessWidget {
  final double topPadding;
  final bool isSigningIn;
  final VoidCallback onSignIn;

  const _ProfileSignInGate({
    required this.topPadding,
    required this.isSigningIn,
    required this.onSignIn,
  });

  static const _lockedItems = [
    (icon: CupertinoIcons.bell, title: 'Research Alerts'),
    (icon: CupertinoIcons.bookmark, title: 'Saved Publications'),
    (icon: CupertinoIcons.gear, title: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              SizedBox(height: topPadding + 120),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      for (final item in _lockedItems) ...[
                        _LockedPreviewRow(
                          icon: item.icon,
                          title: item.title,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surfaceGray.withValues(alpha: 0.05),
                  AppColors.surfaceGray.withValues(alpha: 0.88),
                  AppColors.surfaceGray,
                ],
                stops: const [0.18, 0.48, 0.72],
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(8, topPadding + 4, 16, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.brandBlue900, AppColors.brandBlue700],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account',
                          style: AppTextStyles.h1.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(width: 40, height: 3, color: AppColors.warning),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.brandBlue900.withValues(alpha: 0.06),
                        border: Border.all(
                          color: AppColors.brandBlue900.withValues(alpha: 0.12),
                        ),
                      ),
                      child: const Icon(
                        CupertinoIcons.person_crop_circle,
                        size: 36,
                        color: AppColors.brandBlue600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.brandBlue900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Access your profile, saved publications, and alerts.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.metadata.copyWith(
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.background,
              padding: EdgeInsets.fromLTRB(24, 24, 24, 20 + bottomInset),
              child: GoogleSignInButton(
                isLoading: isSigningIn,
                onPressed: onSignIn,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LockedPreviewRow extends StatelessWidget {
  final IconData icon;
  final String title;

  const _LockedPreviewRow({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.28,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.brandBlue900.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.brandBlue900, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: AppTextStyles.h3)),
            const Icon(
              CupertinoIcons.lock_fill,
              size: 14,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedInHero extends StatelessWidget {
  final double topPadding;
  final User user;
  final VoidCallback onSignOut;

  const _SignedInHero({
    required this.topPadding,
    required this.user,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName?.trim();
    final email = user.email?.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandBlue900, AppColors.brandBlue700],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              const Spacer(),
              TextButton(
                onPressed: onSignOut,
                child: Text(
                  'Sign out',
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              UserAvatar(
                photoUrl: user.photoURL,
                displayName: displayName,
                email: email,
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                borderColor: Colors.white.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName?.isNotEmpty == true
                          ? displayName!
                          : 'Account',
                      style: AppTextStyles.h1.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    if (email?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        email!,
                        style: AppTextStyles.metadata.copyWith(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue900.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.brandBlue900, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.metadata.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
