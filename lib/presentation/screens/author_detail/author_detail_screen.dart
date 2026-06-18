import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/presentation/controllers/author_detail_controller.dart';
import 'package:synapse/presentation/screens/author_detail/widgets/author_detail_content.dart';
import 'package:synapse/presentation/screens/author_detail/widgets/author_detail_skeleton.dart';

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
  late final AuthorDetailArgs _args;
  bool _isPaging = false;

  @override
  void initState() {
    super.initState();
    _args = (authorId: widget.authorId, keyword: widget.topic);
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isPaging) return;

    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;
    if (position.maxScrollExtent <= 0) return;
    if (position.pixels < position.maxScrollExtent - 200) return;

    _isPaging = true;
    ref
        .read(authorDetailControllerProvider(_args).notifier)
        .loadMoreWorks()
        .whenComplete(() {
      _isPaging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(authorDetailControllerProvider(_args));

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    Text('Lỗi: ${error.toString()}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(authorDetailControllerProvider(_args)),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
            data: (detail) => CustomScrollView(
              key: const ValueKey('author_detail_data'),
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.brandBlue900,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leading: IconButton(
                    icon: const Icon(CupertinoIcons.back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: AuthorProfileHeader(
                    profile: detail.profile,
                    topicLabel: widget.topic,
                  ),
                ),
                SliverToBoxAdapter(
                  child: AuthorWorksSection(
                    works: detail.works,
                    isLoadingMore: detail.isLoadingMoreWorks,
                    hasMore: detail.hasMoreWorks,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
