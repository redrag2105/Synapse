import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/types/paginated_list_state.dart';
import 'package:synapse/domain/entities/author_detail_view_state.dart';
import 'package:synapse/domain/usecases/author/get_author_works_usecase.dart';
import 'package:synapse/presentation/widgets/pagination_footer.dart';

typedef AuthorDetailArgs = ({String authorId, String keyword});

final authorDetailControllerProvider = AsyncNotifierProvider.autoDispose
    .family<AuthorDetailController, AuthorDetailViewState, AuthorDetailArgs>(
      AuthorDetailController.new,
    );

class AuthorDetailController extends AsyncNotifier<AuthorDetailViewState> {
  AuthorDetailController(this.arg);

  final AuthorDetailArgs arg;
  static const int _pageSize = PaginatedListState.defaultPageSize;

  final InFlightPageGuard _pageGuard = InFlightPageGuard();

  @override
  FutureOr<AuthorDetailViewState> build() async {
    final profileResult = await ref.read(getAuthorProfileUseCaseProvider)(
      GetAuthorProfileParams(authorId: arg.authorId),
    );

    return await profileResult.fold(
      (failure) async => throw failure,
      (profile) async {
        final worksResult = await ref.read(getAuthorWorksUseCaseProvider)(
          GetAuthorWorksParams(
            authorId: arg.authorId,
            keyword: arg.keyword,
            page: 1,
            limit: _pageSize,
          ),
        );

        return worksResult.fold(
          (failure) => throw failure,
          (worksPage) => AuthorDetailViewState(
            profile: profile,
            works: worksPage.items,
            totalWorksCount:
                worksPage.totalCount ?? profile.worksCount,
            worksPage: 1,
            hasMoreWorks: worksPage.hasMore,
          ),
        );
      },
    );
  }

  Future<void> loadMoreWorks() async {
    final current = state.value;
    if (current == null ||
        !current.hasMoreWorks ||
        current.isLoadingMoreWorks ||
        _pageGuard.hasPageInFlight) {
      return;
    }

    final nextPage = current.worksPage + 1;
    if (!_pageGuard.tryAcquire(nextPage)) return;

    state = AsyncValue.data(current.copyWith(isLoadingMoreWorks: true));

    try {
      final result = await ref.read(getAuthorWorksUseCaseProvider)(
        GetAuthorWorksParams(
          authorId: arg.authorId,
          keyword: arg.keyword,
          page: nextPage,
          limit: _pageSize,
        ),
      );

      result.fold(
        (failure) {
          final latest = state.value;
          if (latest == null) return;

          state = AsyncValue.data(
            latest.copyWith(isLoadingMoreWorks: false),
          );
        },
        (worksPage) {
          final latest = state.value;
          if (latest == null) return;

          state = AsyncValue.data(
            latest.copyWith(
              works: [...latest.works, ...worksPage.items],
              worksPage: nextPage,
              hasMoreWorks: worksPage.hasMore,
              isLoadingMoreWorks: false,
            ),
          );
        },
      );
    } finally {
      _pageGuard.release(nextPage);
    }
  }
}
