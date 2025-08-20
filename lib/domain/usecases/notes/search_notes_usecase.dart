import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/note_entity.dart';
import '../../repositories/notes_repository.dart';

class SearchNotesUseCase {
  final NotesRepository repository;

  SearchNotesUseCase(this.repository);

  Future<Either<Failure, List<NoteEntity>>> call(SearchNotesParams params) async {
    if (params.query.trim().isEmpty) {
      return const Right([]);
    }

    if (params.query.trim().length < 2) {
      return Left(ValidationFailure('Search query must be at least 2 characters'));
    }

    return await repository.searchNotes(
      params.query.trim(),
      userId: params.userId,
    );
  }
}

class SearchNotesParams {
  final String query;
  final String? userId;

  SearchNotesParams({
    required this.query,
    this.userId,
  });
}