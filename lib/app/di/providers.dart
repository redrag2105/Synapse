import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/data/providers/api_client.dart';
import 'package:synapse/data/providers/apis/api_author.dart';
import 'package:synapse/data/providers/apis/api_journal.dart';
import 'package:synapse/data/providers/apis/api_publication.dart';
import 'package:synapse/data/providers/apis/api_topic.dart';

// --- REPOSITORIES (DOMAIN) IMPORTS ---
import 'package:synapse/domain/repositories/topic_repository.dart';
import 'package:synapse/domain/repositories/publication_repository.dart';
import 'package:synapse/domain/repositories/author_repository.dart';
import 'package:synapse/domain/repositories/journal_repository.dart';

// --- REPOSITORIES (DATA IMPL) IMPORTS ---
import 'package:synapse/data/repositories/topic_repository_impl.dart';
import 'package:synapse/data/repositories/publication_repository_impl.dart';
import 'package:synapse/data/repositories/author_repository_impl.dart';
import 'package:synapse/data/repositories/journal_repository_impl.dart';
import 'package:synapse/domain/usecases/author/get_top_authors_usecase.dart';
import 'package:synapse/domain/usecases/publication/get_publication_by_id_usecase.dart';
import 'package:synapse/domain/usecases/publication/get_publication_trend_usecase.dart';
import 'package:synapse/domain/usecases/journal/get_top_journals_usecase.dart';
import 'package:synapse/domain/usecases/publication/search_publications_usecase.dart';
import 'package:synapse/domain/usecases/topic/get_topic_hints_usecase.dart';

// =========================================================================
// 1. DATA SOURCES PROVIDERS
// =========================================================================

final apiTopicProvider = Provider<ApiTopic>((ref) {
  return ApiTopicImpl(ref.watch(dioProvider));
});

final apiPublicationProvider = Provider<ApiPublication>((ref) {
  return ApiPublicationImpl(ref.watch(dioProvider));
});

final apiAuthorProvider = Provider<ApiAuthor>((ref) {
  return ApiAuthorImpl(ref.watch(dioProvider));
});

final apiJournalProvider = Provider<ApiJournal>((ref) {
  return ApiJournalImpl(ref.watch(dioProvider));
});

// =========================================================================
// 2. REPOSITORIES PROVIDERS
// =========================================================================

final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  return TopicRepositoryImpl(ref.watch(apiTopicProvider));
});

final publicationRepositoryProvider = Provider<PublicationRepository>((ref) {
  return PublicationRepositoryImpl(ref.watch(apiPublicationProvider));
});

final authorRepositoryProvider = Provider<AuthorRepository>((ref) {
  return AuthorRepositoryImpl(ref.watch(apiAuthorProvider));
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl(ref.watch(apiJournalProvider));
});

// =========================================================================
// 3. USE CASES PROVIDERS
// =========================================================================

final searchPublicationsUseCaseProvider = Provider<SearchPublicationsUseCase>((
  ref,
) {
  return SearchPublicationsUseCase(
    ref.watch(topicRepositoryProvider),
    ref.watch(publicationRepositoryProvider),
  );
});

final getPublicationTrendUseCaseProvider = Provider<GetPublicationTrendUseCase>(
  (ref) {
    return GetPublicationTrendUseCase(
      ref.watch(topicRepositoryProvider),
      ref.watch(publicationRepositoryProvider),
    );
  },
);

final getTopAuthorsUseCaseProvider = Provider<GetTopAuthorsUseCase>((ref) {
  return GetTopAuthorsUseCase(
    ref.watch(topicRepositoryProvider),
    ref.watch(authorRepositoryProvider),
  );
});

final getTopJournalsUseCaseProvider = Provider<GetTopJournalsUseCase>((ref) {
  return GetTopJournalsUseCase(
    ref.watch(topicRepositoryProvider),
    ref.watch(journalRepositoryProvider),
  );
});

final getTopicHintsUseCaseProvider = Provider<GetTopicHintsUseCase>((ref) {
  return GetTopicHintsUseCase(ref.watch(topicRepositoryProvider));
});

final getPublicationByIdUseCaseProvider = Provider<GetPublicationByIdUseCase>((
  ref,
) {
  return GetPublicationByIdUseCase(ref.watch(publicationRepositoryProvider));
});
