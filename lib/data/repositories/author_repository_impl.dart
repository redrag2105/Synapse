import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/types/paged_result.dart';
import 'package:synapse/app/types/paginated_list_state.dart';
import 'package:synapse/app/utils/error_handler.dart';
import 'package:synapse/app/utils/request_deduplicator.dart';
import 'package:synapse/data/models/author_model.dart';
import 'package:synapse/data/models/publication_model.dart';
import 'package:synapse/data/providers/apis/api_author.dart';
import 'package:synapse/data/providers/apis/api_publication.dart';
import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/entities/author_topic_matrix_entity.dart';
import 'package:synapse/domain/entities/global_author_insights_entity.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/domain/repositories/author_repository.dart';

class AuthorRepositoryImpl
    with RequestDeduplicator
    implements AuthorRepository {
  final ApiAuthor _apiAuthor;
  final ApiPublication _apiPublication;

  AuthorRepositoryImpl(this._apiAuthor, this._apiPublication);

  static String _cleanId(String id) =>
      id.contains('/') ? id.split('/').last : id;

  @override
  Future<Either<Failure, PagedResult<AuthorEntity>>> getTopAuthorsByKeyword(
    String keyword, {
    int limit = PaginatedListState.defaultPageSize,
  }) async {
    final apiLimit = limit > 200 ? 200 : limit;

    return deduplicate(
      cacheKey: 'top_authors_${keyword}_$apiLimit',
      action: () async {
        try {
          final currentYear = DateTime.now().year;
          final filter = keyword.isEmpty
              ? 'publication_year:${currentYear - 2}-$currentYear'
              : null;

          final response = await _apiPublication.getWorks(
            search: keyword.isNotEmpty ? keyword : null,
            filter: filter,
            groupBy: 'authorships.author.id',
            perPage: apiLimit,
          );

          final groups = response['group_by'] as List? ?? [];
          final authors = <AuthorEntity>[];

          for (final group in groups) {
            if (group is! Map<String, dynamic>) continue;
            try {
              authors.add(AuthorModel.fromGroupByJson(group));
            } catch (_) {
              continue;
            }
          }

          authors.sort((a, b) => b.worksCount.compareTo(a.worksCount));

          return Right(
            PagedResult(
              items: authors,
              hasMore: false,
            ),
          );
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }

  @override
  Future<Either<Failure, AuthorEntity>> getAuthorById(
    String authorId, {
    bool includeTopics = false,
  }) async {
    final cleanId = _cleanId(authorId);

    return deduplicate(
      cacheKey: 'author_${cleanId}_topics_$includeTopics',
      action: () async {
        try {
          final select = includeTopics
              ? 'id,display_name,orcid,works_count,cited_by_count,summary_stats,last_known_institutions,topics'
              : 'id,display_name,orcid,works_count,cited_by_count,summary_stats,last_known_institutions';

          final response = await _apiAuthor.getAuthorById(
            id: cleanId,
            select: select,
          );

          return Right(AuthorModel.fromJson(response));
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<PublicationEntity>>> getAuthorWorksByTopic(
    String authorId,
    String keyword, {
    int page = 1,
    int limit = PaginatedListState.defaultPageSize,
  }) async {
    final cleanId = _cleanId(authorId);

    return deduplicate(
      cacheKey: 'author_works_${cleanId}_${keyword}_${page}_$limit',
      action: () async {
        try {
          final response = await _apiPublication.getWorks(
            filter: 'author.id:$cleanId',
            search: keyword.isNotEmpty ? keyword : null,
            page: page,
            perPage: limit,
            sort: 'cited_by_count:desc',
            select:
                'id,title,display_name,doi,publication_year,publication_date,cited_by_count,primary_location,authorships,type,open_access',
          );

          final results = response['results'] as List? ?? [];
          final publications = results
              .map((e) => PublicationModel.fromJson(e as Map<String, dynamic>))
              .toList();

          return Right(publications);
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }

  @override
  Future<Either<Failure, AuthorTopicMatrix>> getAuthorTopicMatrix(
    List<String> authorIds, {
    int maxAuthors = 5,
    int maxTopics = 5,
  }) async {
    final ids = authorIds.take(maxAuthors).map(_cleanId).toList();
    if (ids.isEmpty) {
      return const Left(NotFoundFailure('Không có tác giả để tạo ma trận.'));
    }

    return deduplicate(
      cacheKey: 'author_matrix_${ids.join('_')}_$maxTopics',
      action: () async {
        try {
          final profiles = <AuthorEntity>[];

          for (final id in ids) {
            final result = await getAuthorById(id, includeTopics: true);
            final profile = result.fold((failure) => null, (author) => author);
            if (profile != null) {
              profiles.add(profile);
            }
          }

          if (profiles.isEmpty) {
            return const Left(
              NotFoundFailure('Không thể tải dữ liệu chuyên môn tác giả.'),
            );
          }

          final topicTotals = <String, ({String name, int total})>{};

          for (final profile in profiles) {
            for (final topic in profile.researchTopics) {
              final existing = topicTotals[topic.id];
              topicTotals[topic.id] = (
                name: topic.displayName,
                total: (existing?.total ?? 0) + topic.count,
              );
            }
          }

          final sortedTopics = topicTotals.entries.toList()
            ..sort((a, b) => b.value.total.compareTo(a.value.total));

          final selectedTopics = sortedTopics.take(maxTopics).toList();
          final topicIds = selectedTopics.map((e) => e.key).toList();
          final topicNames = selectedTopics.map((e) => e.value.name).toList();

          final counts = profiles.map((profile) {
            final topicMap = {
              for (final topic in profile.researchTopics) topic.id: topic.count,
            };
            return topicIds.map((id) => topicMap[id] ?? 0).toList();
          }).toList();

          return Right(
            AuthorTopicMatrix(
              authorIds: profiles.map((p) => _cleanId(p.id)).toList(),
              authorNames: profiles.map((p) => p.displayName).toList(),
              topicIds: topicIds,
              topicNames: topicNames,
              counts: counts,
            ),
          );
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }

  double _coAuthorshipDensity(List<dynamic> works) {
    if (works.isEmpty) return 0;
    var multiAuthor = 0;
    for (final work in works) {
      final authorships = work['authorships'] as List? ?? [];
      if (authorships.length > 1) multiAuthor++;
    }
    return multiAuthor / works.length * 100;
  }

  int _internationalCollaborationCount(List<dynamic> works) {
    var count = 0;
    for (final work in works) {
      final authorships = work['authorships'] as List? ?? [];
      final countries = <String>{};
      for (final authorship in authorships) {
        final institutions = authorship['institutions'] as List? ?? [];
        for (final institution in institutions) {
          final country = institution['country_code'] as String?;
          if (country != null && country.isNotEmpty) {
            countries.add(country);
          }
        }
      }
      if (countries.length > 1) count++;
    }
    return count;
  }

  double _averageCitations(List<dynamic> works) {
    if (works.isEmpty) return 0;
    final total = works.fold<int>(
      0,
      (sum, work) => sum + (work['cited_by_count'] as int? ?? 0),
    );
    return total / works.length;
  }

  double _toImpactScore(double averageCitations) {
    return (averageCitations / 15).clamp(0, 100).toDouble();
  }

  @override
  Future<Either<Failure, GlobalAuthorInsights>> getGlobalAuthorInsights({
    String keyword = '',
  }) async {
    final trimmed = keyword.trim();

    return deduplicate(
      cacheKey: 'global_author_insights_$trimmed',
      action: () async {
        try {
          final currentYear = DateTime.now().year;
          final recentFilter =
              'publication_year:${currentYear - 2}-$currentYear';
          final previousFilter =
              'publication_year:${currentYear - 5}-${currentYear - 3}';
          final search = trimmed.isNotEmpty ? trimmed : null;

          final orcidResponse = await _apiAuthor.getAuthors(
            search: search,
            filter: 'has_orcid:true',
            perPage: 1,
          );
          final activeOrcids =
              orcidResponse['meta']?['count'] as int? ?? 0;

          final recentWorksResponse = await _apiPublication.getWorks(
            search: search,
            filter: recentFilter,
            perPage: 100,
            select: 'id,authorships,cited_by_count',
          );
          final previousWorksResponse = await _apiPublication.getWorks(
            search: search,
            filter: previousFilter,
            perPage: 100,
            select: 'id,authorships,cited_by_count',
          );

          final recentWorks = recentWorksResponse['results'] as List? ?? [];
          final previousWorks =
              previousWorksResponse['results'] as List? ?? [];

          final recentDensity = _coAuthorshipDensity(recentWorks);
          final previousDensity = _coAuthorshipDensity(previousWorks);

          final recentImpact = _toImpactScore(_averageCitations(recentWorks));
          final previousImpact =
              _toImpactScore(_averageCitations(previousWorks));

          final recentIntl = _internationalCollaborationCount(recentWorks);
          final previousIntl =
              _internationalCollaborationCount(previousWorks);

          final intlTrend = previousIntl == 0
              ? 0.0
              : ((recentIntl - previousIntl) / previousIntl) * 100;

          return Right(
            GlobalAuthorInsights(
              coAuthorshipDensity: recentDensity,
              coAuthorshipTrend: recentDensity - previousDensity,
              globalImpactScore: recentImpact,
              globalImpactTrend: recentImpact - previousImpact,
              intCollaboration: recentIntl,
              intCollaborationTrend: intlTrend,
              activeOrcids: activeOrcids,
            ),
          );
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }
}
