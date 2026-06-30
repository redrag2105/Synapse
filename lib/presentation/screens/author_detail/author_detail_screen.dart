import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/presentation/controllers/author_detail_controller.dart';
import 'package:synapse/presentation/screens/author_detail/widgets/author_detail_content.dart';
import 'package:synapse/presentation/screens/author_detail/widgets/author_detail_header_delegate.dart';
import 'package:synapse/presentation/screens/author_detail/widgets/author_detail_skeleton.dart';
import 'package:synapse/presentation/widgets/pagination_footer.dart';

class AuthorDetailScreen extends ConsumerStatefulWidget {
  final String authorId;
  final String topic;

  const AuthorDetailScreen({
    super.key,
    required this.authorId,
    required this.topic,
  });

  @override
  ConsumerState<AuthorDetailScreen> createState() => _AuthorDetailScreenState();
}

class _AuthorDetailScreenState extends ConsumerState<AuthorDetailScreen> {
  late final ScrollController _scrollController;
  final ScrollPaginationLock _paginationLock = ScrollPaginationLock();
  late final AuthorDetailArgs _args;

  @override
  void initState() {
    super.initState();
    _args = (authorId: widget.authorId, keyword: widget.topic);
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final metrics = _scrollController.position;
    _paginationLock.onScroll(metrics);

    final detailState = ref.read(authorDetailControllerProvider(_args)).value;

    _paginationLock.tryLoad(
      metrics: metrics,
      canLoadMore: detailState?.hasMoreWorks ?? false,
      isLoadingMore: detailState?.isLoadingMoreWorks ?? false,
      onLoadMore: () => ref
          .read(authorDetailControllerProvider(_args).notifier)
          .loadMoreWorks(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(authorDetailControllerProvider(_args));

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      body: SafeArea(
        top: false,
        bottom: true,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder:
              (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ...previousChildren,
                ?currentChild,
              ],
            );
          },
          child: detailState.when(
            loading: () => const AuthorDetailSkeleton(
              key: ValueKey('author_detail_loading'),
            ),
            error: (error, _) => SizedBox(
              key: const ValueKey('author_detail_error'),
              height: MediaQuery.sizeOf(context).height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${error.toString()}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(authorDetailControllerProvider(_args)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (detail) {
              final topPadding = MediaQuery.paddingOf(context).top;

              return ColoredBox(
                key: const ValueKey('author_detail_data'),
                color: AppColors.background,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: AuthorDetailHeaderDelegate(
                        topPadding: topPadding,
                        displayName: detail.profile.displayName,
                        institution: detail.profile.lastKnownInstitutionName,
                        orcid: detail.profile.orcid,
                        topicLabel: widget.topic,
                        worksCount: detail.profile.worksCount,
                        citedByCount: detail.profile.citedByCount,
                        hIndex: detail.profile.hIndex,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: AuthorWorksSection(
                        works: detail.works,
                        totalWorksCount: detail.totalWorksCount,
                        topicLabel: widget.topic,
                        isLoadingMore: detail.isLoadingMoreWorks,
                        hasMore: detail.hasMoreWorks,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
