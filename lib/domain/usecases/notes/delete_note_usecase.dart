import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/notes_repository.dart';

class DeleteNoteUseCase {
  final NotesRepository repository;

  DeleteNoteUseCase(this.repository);

  Future<Either<Failure, void>> call(String noteId) async {
    if (noteId.isEmpty) {
      return Left(ValidationFailure('Note ID cannot be empty'));
    }

    // Check if note exists before deletion
    final existingNoteResult = await repository.getNoteById(noteId);
    
    return existingNoteResult.fold(
      (failure) => Left(failure),
      (existingNote) {
        if (existingNote == null) {
          return Left(ValidationFailure('Note not found'));
        }

        return repository.deleteNote(noteId);
      },
    );
  }
}