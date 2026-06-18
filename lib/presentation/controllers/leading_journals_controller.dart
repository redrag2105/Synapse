import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/domain/entities/leading_journal_entity.dart';

final leadingJournalsControllerProvider = AsyncNotifierProvider<
    LeadingJournalsController, LeadingJournalsOverview>(
  LeadingJournalsController.new,
);

class LeadingJournalsController extends AsyncNotifier<LeadingJournalsOverview> {
  @override
  FutureOr<LeadingJournalsOverview> build() async {
    final result = await ref.read(getLeadingJournalsUseCaseProvider)();

    return result.fold(
      (failure) => throw failure,
      (overview) => overview,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getLeadingJournalsUseCaseProvider)();
      return result.fold(
        (failure) => throw failure,
        (overview) => overview,
      );
    });
  }
}
