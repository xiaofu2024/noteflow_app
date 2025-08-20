import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/note_entity.dart';
import '../../repositories/notes_repository.dart';

class UpdateNoteUseCase {
  final NotesRepository repository;

  UpdateNoteUseCase(this.repository);

  Future<Either<Failure, void>> call(UpdateNoteParams params) async {
    // Get the existing note first
    final existingNoteResult = await repository.getNoteById(params.noteId);
    
    return existingNoteResult.fold(
      (failure) => Left(failure),
      (existingNote) {
        if (existingNote == null) {
          return Left(ValidationFailure('Note not found'));
        }

        // Create updated note
        final updatedNote = existingNote.copyWith(
          title: params.title?.trim(),
          content: params.content?.trim(),
          tags: params.tags,
          updatedAt: DateTime.now(),
          isPinned: params.isPinned,
          isEncrypted: params.isEncrypted,
          password: params.password,
          color: params.color,
          isFavorite: params.isFavorite,
          attachments: params.attachments,
          metadata: params.metadata,
        );

        // Validate updated note data
        if (updatedNote.title.isEmpty && updatedNote.content.isEmpty) {
          return Left(ValidationFailure('Note title and content cannot both be empty'));
        }

        return repository.updateNote(updatedNote);
      },
    );
  }
}

class UpdateNoteParams {
  final String noteId;
  final String? title;
  final String? content;
  final List<String>? tags;
  final bool? isPinned;
  final bool? isEncrypted;
  final String? password;
  final int? color;
  final bool? isFavorite;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;

  UpdateNoteParams({
    required this.noteId,
    this.title,
    this.content,
    this.tags,
    this.isPinned,
    this.isEncrypted,
    this.password,
    this.color,
    this.isFavorite,
    this.attachments,
    this.metadata,
  });
}