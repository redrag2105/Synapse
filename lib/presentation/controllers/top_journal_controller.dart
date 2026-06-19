import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/domain/entities/journal_entity.dart';
import 'package:synapse/domain/usecases/journal/get_top_journals_usecase.dart';

final topJournalsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      TopJournalsController,
      List<JournalEntity>
    >(TopJournalsController.new);

class TopJournalsController extends AsyncNotifier<List<JournalEntity>> {
  @override
  FutureOr<List<JournalEntity>> build() {
    return [];
  }

  Future<void> fetchTopJournals(String keyword, {int limit = 10}) async {
    // if (keyword.trim().isEmpty) return;

    state = const AsyncValue.loading();

    final useCase = ref.read(getTopJournalsUseCaseProvider);
    final result = await useCase(
      GetTopJournalsParams(keyword: keyword, limit: limit),
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (journals) => state = AsyncValue.data(journals),
    );
  }
}
