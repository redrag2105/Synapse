import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/domain/entities/journal_detail_entity.dart';

final journalDetailProvider = FutureProvider.autoDispose
    .family<JournalDetailEntity, String>((ref, journalId) async {
      final result = await ref.read(getJournalByIdUseCaseProvider)(journalId);

      return result.fold(
        (failure) => throw failure,
        (journal) => journal,
      );
    });
