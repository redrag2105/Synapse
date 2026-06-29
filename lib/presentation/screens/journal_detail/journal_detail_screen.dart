import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/presentation/controllers/journal_detail_controller.dart';
import 'package:synapse/presentation/screens/journal_detail/widgets/journal_detail_content.dart';
import 'package:synapse/presentation/screens/journal_detail/widgets/journal_detail_header_delegate.dart';
import 'package:synapse/presentation/screens/journal_detail/widgets/journal_detail_skeleton.dart';

class JournalDetailScreen extends ConsumerWidget {
  final String journalId;

  const JournalDetailScreen({super.key, required this.journalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(journalDetailProvider(journalId));

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      body: SafeArea(
        top: false,
        bottom: true,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [...previousChildren, ?currentChild],
            );
          },
          child: detailState.when(
            loading: () => const JournalDetailSkeleton(
              key: ValueKey('journal_detail_loading'),
            ),
            error: (error, _) => SizedBox(
              key: const ValueKey('journal_detail_error'),
              height: MediaQuery.sizeOf(context).height,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load journal details.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(journalDetailProvider(journalId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (journal) {
              final topPadding = MediaQuery.paddingOf(context).top;

              return CustomScrollView(
                key: const ValueKey('journal_detail_data'),
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: JournalDetailHeaderDelegate(
                      topPadding: topPadding,
                      displayName: journal.displayName,
                      publisher: journal.hostOrganizationName,
                      issnL: journal.issnL,
                      worksCount: journal.worksCount,
                      citedByCount: journal.citedByCount,
                      hIndex: journal.hIndex,
                      isOa: journal.isOa,
                      isInDoaj: journal.isInDoaj,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: JournalDetailContent(journal: journal),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
