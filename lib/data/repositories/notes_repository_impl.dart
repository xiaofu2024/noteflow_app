import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/local/notes_local_data_source.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;
  // Add remote data source later for sync functionality
  // final NotesRemoteDataSource remoteDataSource;

  NotesRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<NoteEntity>>> getNotes({
    String? userId,
    bool? isPinned,
    List<String>? tags,
    int? limit,
    int? offset,
  }) async {
    try {
      final noteModels = await localDataSource.getNotes(
        userId: userId,
        isPinned: isPinned,
        tags: tags,
        limit: limit,
        offset: offset,
      );
      
      final notes = noteModels.map((model) => model.toEntity()).toList();
      return Right(notes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to get notes: $e'));
    }
  }

  @override
  Future<Either<Failure, NoteEntity?>> getNoteById(String id) async {
    try {
      final noteModel = await localDataSource.getNoteById(id);
      return Right(noteModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to get note by id: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> createNote(NoteEntity note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      final noteId = await localDataSource.createNote(noteModel);
      return Right(noteId);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to create note: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateNote(NoteEntity note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      await localDataSource.updateNote(noteModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to update note: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String id) async {
    try {
      await localDataSource.deleteNote(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to delete note: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NoteEntity>>> searchNotes(
    String query, {
    String? userId,
  }) async {
    try {
      final noteModels = await localDataSource.searchNotes(query, userId: userId);
      final notes = noteModels.map((model) => model.toEntity()).toList();
      return Right(notes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to search notes: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearAllNotes();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to clear cache: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getNotesCount({String? userId}) async {
    try {
      final notes = await localDataSource.getNotes(userId: userId);
      return Right(notes.length);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to get notes count: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllTags({String? userId}) async {
    try {
      final notes = await localDataSource.getNotes(userId: userId);
      final Set<String> allTags = {};
      
      for (final note in notes) {
        allTags.addAll(note.tags);
      }
      
      final sortedTags = allTags.toList()..sort();
      return Right(sortedTags);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Failed to get all tags: $e'));
    }
  }

  // TODO: Implement remote sync operations
  @override
  Future<Either<Failure, List<NoteEntity>>> syncNotes(String userId) async {
    // This will be implemented when we add remote data source
    return Left(UnknownFailure('Sync not implemented yet'));
  }

  @override
  Future<Either<Failure, void>> uploadNote(NoteEntity note) async {
    // This will be implemented when we add remote data source
    return Left(UnknownFailure('Upload not implemented yet'));
  }

  @override
  Future<Either<Failure, void>> downloadNotes(String userId) async {
    // This will be implemented when we add remote data source
    return Left(UnknownFailure('Download not implemented yet'));
  }
}