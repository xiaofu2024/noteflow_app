import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/note_entity.dart';
import '../../repositories/notes_repository.dart';

class GetNotesUseCase {
  final NotesRepository repository;

  GetNotesUseCase(this.repository);

  Future<Either<Failure, List<NoteEntity>>> call(GetNotesParams params) async {
    return await repository.getNotes(
      userId: params.userId,
      isPinned: params.isPinned,
      tags: params.tags,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetNotesParams {
  final String? userId;
  final bool? isPinned;
  final List<String>? tags;
  final int? limit;
  final int? offset;

  GetNotesParams({
    this.userId,
    this.isPinned,
    this.tags,
    this.limit,
    this.offset,
  });
}