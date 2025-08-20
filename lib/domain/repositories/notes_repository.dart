import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/note_entity.dart';

abstract class NotesRepository {
  // Local operations
  Future<Either<Failure, List<NoteEntity>>> getNotes({
    String? userId,
    bool? isPinned,
    List<String>? tags,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, NoteEntity?>> getNoteById(String id);

  Future<Either<Failure, String>> createNote(NoteEntity note);

  Future<Either<Failure, void>> updateNote(NoteEntity note);

  Future<Either<Failure, void>> deleteNote(String id);

  Future<Either<Failure, List<NoteEntity>>> searchNotes(
    String query, {
    String? userId,
  });

  // Remote operations (for sync)
  Future<Either<Failure, List<NoteEntity>>> syncNotes(String userId);

  Future<Either<Failure, void>> uploadNote(NoteEntity note);

  Future<Either<Failure, void>> downloadNotes(String userId);

  // Utility operations
  Future<Either<Failure, void>> clearCache();

  Future<Either<Failure, int>> getNotesCount({String? userId});

  Future<Either<Failure, List<String>>> getAllTags({String? userId});
}