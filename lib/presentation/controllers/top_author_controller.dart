import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/usecases/author/get_top_authors_usecase.dart';

final topAuthorsControllerProvider =
    AsyncNotifierProvider.autoDispose<TopAuthorsController, List<AuthorEntity>>(
      TopAuthorsController.new,
    );

class TopAuthorsController extends AsyncNotifier<List<AuthorEntity>> {
  @override
  FutureOr<List<AuthorEntity>> build() {
    return [];
  }

  Future<void> fetchTopAuthors(String keyword, {int limit = 10}) async {
    // if (keyword.trim().isEmpty) return;

    state = const AsyncValue.loading();

    final useCase = ref.read(getTopAuthorsUseCaseProvider);

    final result = await useCase(
      GetTopAuthorsParams(keyword: keyword, limit: limit),
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (authors) => state = AsyncValue.data(authors),
    );
  }
}
