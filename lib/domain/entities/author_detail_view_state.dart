import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/entities/publication_entity.dart';

class AuthorDetailViewState {
  final AuthorEntity profile;
  final List<PublicationEntity> works;
  final int totalWorksCount;
  final int worksPage;
  final bool hasMoreWorks;
  final bool isLoadingMoreWorks;

  const AuthorDetailViewState({
    required this.profile,
    this.works = const [],
    this.totalWorksCount = 0,
    this.worksPage = 1,
    this.hasMoreWorks = true,
    this.isLoadingMoreWorks = false,
  });

  AuthorDetailViewState copyWith({
    AuthorEntity? profile,
    List<PublicationEntity>? works,
    int? totalWorksCount,
    int? worksPage,
    bool? hasMoreWorks,
    bool? isLoadingMoreWorks,
  }) {
    return AuthorDetailViewState(
      profile: profile ?? this.profile,
      works: works ?? this.works,
      totalWorksCount: totalWorksCount ?? this.totalWorksCount,
      worksPage: worksPage ?? this.worksPage,
      hasMoreWorks: hasMoreWorks ?? this.hasMoreWorks,
      isLoadingMoreWorks: isLoadingMoreWorks ?? this.isLoadingMoreWorks,
    );
  }
}
