import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/domain/entities/keyword_history_entry.dart';
import 'package:synapse/presentation/controllers/analytics_providers.dart';
import 'package:synapse/presentation/controllers/auth_providers.dart';
import 'package:synapse/presentation/controllers/keyword_history_providers.dart';
import 'package:synapse/presentation/widgets/google_sign_in_button.dart';

/// Home empty state: keyword history or guest sign-in promo.
class HomeKeywordHistorySection extends ConsumerWidget {
  final ValueChanged<String> onKeywordTap;

  const HomeKeywordHistorySection({
    super.key,
    required this.onKeywordTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const _GuestHistoryScreen();
    }

    final historyAsync = ref.watch(keywordHistoryProvider);

    return historyAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (_, _) => _EmptySignedInScreen(
        onRetry: () =>
            ref.read(keywordHistoryProvider.notifier).refresh(),
      ),
      data: (snapshot) {
        if (snapshot == null || snapshot.isEmpty) {
          return const _EmptySignedInScreen();
        }
        return _SignedInHistoryScreen(
          snapshot: snapshot,
          onKeywordTap: onKeywordTap,
        );
      },
    );
  }
}

class _GuestHistoryScreen extends ConsumerStatefulWidget {
  const _GuestHistoryScreen();

  @override
  ConsumerState<_GuestHistoryScreen> createState() =>
      _GuestHistoryScreenState();
}

class _GuestHistoryScreenState extends ConsumerState<_GuestHistoryScreen> {
  bool _isSigningIn = false;

  Future<void> _signIn() async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);
    try {
      final credential =
          await ref.read(authServiceProvider).signInWithGoogle();
      final user = credential.user;
      if (user != null) {
        final analytics = ref.read(analyticsServiceProvider);
        await analytics.setUserId(user.uid);
        await analytics.logLogin();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Sign-in failed. Please try again.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign-in was cancelled or failed. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your research trail',
            style: AppTextStyles.h1.copyWith(
              fontSize: 24,
              height: 1.2,
              color: AppColors.brandBlue900,
              fontFamily: 'Merriweather',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to keep recent and frequent keywords synced across sessions.',
            style: AppTextStyles.metadata.copyWith(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.brandBlue900,
                  AppColors.brandBlue700.withValues(alpha: 0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.clock_fill,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Never lose a search',
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Your recent topics and most-searched keywords will live here.',
                  style: AppTextStyles.metadata.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                GoogleSignInButton(
                  isLoading: _isSigningIn,
                  onPressed: _signIn,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Or search any topic above to start exploring.',
            textAlign: TextAlign.center,
            style: AppTextStyles.metadata.copyWith(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySignedInScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const _EmptySignedInScreen({this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your research trail',
            style: AppTextStyles.h1.copyWith(
              fontSize: 24,
              height: 1.2,
              color: AppColors.brandBlue900,
              fontFamily: 'Merriweather',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Searches you run will show up here as recent and frequent keywords.',
            style: AppTextStyles.metadata.copyWith(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.surfaceGray,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.borderGray.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.search,
                  size: 32,
                  color: AppColors.brandBlue900.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  'No keywords yet',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 16,
                    color: AppColors.brandBlue900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Search a research topic above to start your trail.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.metadata.copyWith(fontSize: 13),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Retry loading'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedInHistoryScreen extends StatelessWidget {
  final KeywordHistorySnapshot snapshot;
  final ValueChanged<String> onKeywordTap;

  const _SignedInHistoryScreen({
    required this.snapshot,
    required this.onKeywordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your research trail',
            style: AppTextStyles.h1.copyWith(
              fontSize: 24,
              height: 1.2,
              color: AppColors.brandBlue900,
              fontFamily: 'Merriweather',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jump back into a topic you recently explored or search often.',
            style: AppTextStyles.metadata.copyWith(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          if (snapshot.frequent.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionHeader(
              icon: CupertinoIcons.flame_fill,
              title: 'Frequently searched',
              accent: AppColors.brandGold,
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < snapshot.frequent.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _KeywordHistoryTile(
                entry: snapshot.frequent[i],
                variant: _KeywordTileVariant.frequent,
                rank: i + 1,
                onTap: () => onKeywordTap(snapshot.frequent[i].keyword),
              ),
            ],
          ],
          if (snapshot.recent.isNotEmpty) ...[
            const SizedBox(height: 22),
            const _SectionHeader(
              icon: CupertinoIcons.time,
              title: 'Recent',
              accent: AppColors.brandBlue700,
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < snapshot.recent.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _KeywordHistoryTile(
                entry: snapshot.recent[i],
                variant: _KeywordTileVariant.recent,
                onTap: () => onKeywordTap(snapshot.recent[i].keyword),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accent;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            fontSize: 15,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

enum _KeywordTileVariant { recent, frequent }

class _KeywordHistoryTile extends StatelessWidget {
  final KeywordHistoryEntry entry;
  final _KeywordTileVariant variant;
  final int? rank;
  final VoidCallback onTap;

  const _KeywordHistoryTile({
    required this.entry,
    required this.variant,
    required this.onTap,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final isFrequent = variant == _KeywordTileVariant.frequent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isFrequent
                ? LinearGradient(
                    colors: [
                      Colors.white,
                      AppColors.brandGold.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.white,
                      AppColors.brandBlue700.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isFrequent
                  ? AppColors.brandGold.withValues(alpha: 0.28)
                  : AppColors.borderGray.withValues(alpha: 0.8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isFrequent
                        ? AppColors.brandGold.withValues(alpha: 0.15)
                        : AppColors.brandBlue900.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isFrequent && rank != null
                      ? Text(
                          '$rank',
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandGold,
                          ),
                        )
                      : Icon(
                          CupertinoIcons.search,
                          size: 16,
                          color: AppColors.brandBlue900.withValues(alpha: 0.75),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.keyword,
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandBlue900,
                          height: 1.3,
                        ),
                      ),
                      if (isFrequent && entry.searchCount > 1) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Searched ${entry.searchCount} times',
                          style: AppTextStyles.metadata.copyWith(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                      ] else if (!isFrequent) ...[
                        const SizedBox(height: 2),
                        Text(
                          _relativeTime(entry.lastSearchedAt),
                          style: AppTextStyles.metadata.copyWith(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  CupertinoIcons.arrow_up_right,
                  size: 15,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
