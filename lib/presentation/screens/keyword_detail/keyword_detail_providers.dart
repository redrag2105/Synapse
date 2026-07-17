import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/entities/journal_entity.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/domain/usecases/author/get_top_authors_usecase.dart';
import 'package:synapse/domain/usecases/journal/get_top_journals_usecase.dart';
import 'package:synapse/domain/usecases/publication/get_publication_trend_usecase.dart';
import 'package:synapse/domain/usecases/publication/search_publications_usecase.dart';

/// Publication counts by year for the selected keyword.
final keywordDetailTrendProvider = FutureProvider.autoDispose
    .family<Map<int, int>, String>((ref, keyword) async {
      final useCase = ref.read(getPublicationTrendUseCaseProvider);
      final result = await useCase(
        GetPublicationTrendParams(keyword: keyword),
      );
      return result.fold((failure) => throw failure, (data) => data);
    });

/// Authors ranked by publication count for the keyword (descending).
final keywordDetailAuthorsProvider = FutureProvider.autoDispose
    .family<List<AuthorEntity>, String>((ref, keyword) async {
      final useCase = ref.read(getTopAuthorsUseCaseProvider);
      final result = await useCase(
        GetTopAuthorsParams(keyword: keyword, limit: 15),
      );
      return result.fold(
        (failure) => throw failure,
        (page) => List<AuthorEntity>.from(page.items)
          ..sort((a, b) => b.worksCount.compareTo(a.worksCount)),
      );
    });

/// Journals most associated with the keyword.
final keywordDetailJournalsProvider = FutureProvider.autoDispose
    .family<List<JournalEntity>, String>((ref, keyword) async {
      final useCase = ref.read(getTopJournalsUseCaseProvider);
      final result = await useCase(
        GetTopJournalsParams(keyword: keyword, limit: 10),
      );
      return result.fold(
        (failure) => throw failure,
        (page) => List<JournalEntity>.from(page.journals)
          ..sort((a, b) => b.worksCount.compareTo(a.worksCount)),
      );
    });

/// Related publications for the keyword.
final keywordDetailPublicationsProvider = FutureProvider.autoDispose
    .family<List<PublicationEntity>, String>((ref, keyword) async {
      final useCase = ref.read(searchPublicationsUseCaseProvider);
      final result = await useCase(
        SearchPublicationsParams(keyword: keyword, limit: 15),
      );
      return result.fold((failure) => throw failure, (pubs) => pubs);
    });
