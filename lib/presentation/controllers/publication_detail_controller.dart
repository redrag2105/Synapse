import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/domain/entities/publication_entity.dart';

final publicationDetailProvider =
    FutureProvider.family<PublicationEntity, String>((ref, id) async {
      final useCase = ref.read(getPublicationByIdUseCaseProvider);

      final result = await useCase(id);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (publication) => publication,
      );
    });
