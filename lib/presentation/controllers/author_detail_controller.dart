import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/types/paginated_list_state.dart';
import 'package:synapse/domain/entities/author_detail_view_state.dart';
import 'package:synapse/domain/usecases/author/get_author_works_usecase.dart';

typedef AuthorDetailArgs = ({String authorId, String keyword});

final authorDetailControllerProvider = AsyncNotifierProvider.autoDispose
    .family<AuthorDetailController, AuthorDetailViewState, AuthorDetailArgs>(
      AuthorDetailController.new,
    );

class AuthorDetailController extends AsyncNotifier<AuthorDetailViewState> {
  AuthorDetailController(this.arg);

  final AuthorDetailArgs arg;
  static const int _pageSize = PaginatedListState.defaultPageSize;

  int _worksRequestId = 0;

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
          (works) => AuthorDetailViewState(
            profile: profile,
            works: works,
            worksPage: 1,
            hasMoreWorks: works.length >= _pageSize,
          ),
        );
      },
    );
  }

  Future<void> loadMoreWorks() async {
    final current = state.value;
    if (current == null ||
        !current.hasMoreWorks ||
        current.isLoadingMoreWorks) {
      return;
    }

    final requestId = ++_worksRequestId;
    final nextPage = current.worksPage + 1;

    state = AsyncValue.data(current.copyWith(isLoadingMoreWorks: true));

    final result = await ref.read(getAuthorWorksUseCaseProvider)(
      GetAuthorWorksParams(
        authorId: arg.authorId,
        keyword: arg.keyword,
        page: nextPage,
        limit: _pageSize,
      ),
    );

    if (requestId != _worksRequestId) return;

    result.fold(
      (failure) {
        state = AsyncValue.data(current.copyWith(isLoadingMoreWorks: false));
      },
      (works) {
        state = AsyncValue.data(
          current.copyWith(
            works: [...current.works, ...works],
            worksPage: nextPage,
            hasMoreWorks: works.length >= _pageSize,
            isLoadingMoreWorks: false,
          ),
        );
      },
    );
  }
}
