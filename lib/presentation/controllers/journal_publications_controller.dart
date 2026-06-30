import 'dart:async';



import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:synapse/app/di/providers.dart';

import 'package:synapse/app/types/paginated_list_state.dart';

import 'package:synapse/domain/entities/publication_entity.dart';

import 'package:synapse/domain/usecases/journal/get_journal_publications_usecase.dart';

import 'package:synapse/presentation/widgets/pagination_footer.dart';



final journalPublicationsControllerProvider = AsyncNotifierProvider.autoDispose

    .family<JournalPublicationsController, List<PublicationEntity>, String>(

      JournalPublicationsController.new,

    );



class JournalPublicationsController

    extends AsyncNotifier<List<PublicationEntity>> {

  JournalPublicationsController(this.journalId);



  final String journalId;



  static const int _pageSize = PaginatedListState.defaultPageSize;



  int _currentPage = 1;

  bool _hasReachedMax = false;

  bool _isFetchingNext = false;

  final InFlightPageGuard _pageGuard = InFlightPageGuard();

  int _requestId = 0;



  bool get hasReachedMax => _hasReachedMax;

  bool get isFetchingNext => _isFetchingNext || _pageGuard.hasPageInFlight;



  @override

  FutureOr<List<PublicationEntity>> build() async {

    _currentPage = 1;

    _hasReachedMax = false;

    _isFetchingNext = false;

    _pageGuard.reset();



    final requestId = ++_requestId;

    final result = await ref.read(getJournalPublicationsUseCaseProvider)(

      GetJournalPublicationsParams(journalId: journalId, page: 1),

    );



    return result.fold(

      (failure) => throw failure,

      (publications) {

        if (requestId != _requestId) return publications;

        _hasReachedMax = publications.length < _pageSize;

        return publications;

      },

    );

  }



  Future<void> loadMore() async {

    if (_pageGuard.hasPageInFlight ||

        _isFetchingNext ||

        _hasReachedMax ||

        state.value == null) {

      return;

    }

    if (state.value!.isEmpty) return;



    final nextPage = _currentPage + 1;

    if (!_pageGuard.tryAcquire(nextPage)) return;



    _isFetchingNext = true;

    final requestId = _requestId;



    try {

      final result = await ref.read(getJournalPublicationsUseCaseProvider)(

        GetJournalPublicationsParams(

          journalId: journalId,

          page: nextPage,

        ),

      );



      if (requestId != _requestId) return;



      result.fold(

        (_) {},

        (newPublications) {

          _hasReachedMax = newPublications.length < _pageSize;

          _currentPage = nextPage;

          state = AsyncValue.data([...state.value!, ...newPublications]);

        },

      );

    } finally {

      if (requestId == _requestId) {

        _pageGuard.release(nextPage);

        _isFetchingNext = false;

      }

    }

  }

}

