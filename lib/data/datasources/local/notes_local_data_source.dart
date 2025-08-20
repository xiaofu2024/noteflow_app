import 'dart:convert';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/note_entity.dart';
import 'database_helper.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteEntity>> getNotes({
    String? userId,
    bool? isPinned,
    List<String>? tags,
    int? limit,
    int? offset,
  });
  Future<NoteEntity?> getNoteById(String id);
  Future<String> createNote(NoteEntity note);
  Future<void> updateNote(NoteEntity note);
  Future<void> deleteNote(String id);
  Future<List<NoteEntity>> searchNotes(String query, {String? userId});
  Future<void> clearAllNotes();
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final DatabaseHelper _databaseHelper;

  NotesLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<NoteEntity>> getNotes({
    String? userId,
    bool? isPinned,
    List<String>? tags,
    int? limit,
    int? offset,
  }) async {
    try {
      String? where;
      List<Object?> whereArgs = [];

      // Build WHERE clause
      List<String> conditions = [];
      
      if (userId != null) {
        conditions.add('user_id = ?');
        whereArgs.add(userId);
      }
      
      if (isPinned != null) {
        conditions.add('is_pinned = ?');
        whereArgs.add(isPinned ? 1 : 0);
      }

      if (tags != null && tags.isNotEmpty) {
        // Search for notes that contain any of the specified tags
        List<String> tagConditions = [];
        for (String tag in tags) {
          tagConditions.add('tags LIKE ?');
          whereArgs.add('%"$tag"%');
        }
        conditions.add('(${tagConditions.join(' OR ')})');
      }

      if (conditions.isNotEmpty) {
        where = conditions.join(' AND ');
      }

      final result = await _databaseHelper.query(
        'notes',
        where: where,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'is_pinned DESC, updated_at DESC',
        limit: limit,
        offset: offset,
      );

      return result.map((json) => NoteEntity.fromDatabaseJson(json)).toList();
    } catch (e) {
      throw CacheException('Failed to get notes: $e');
    }
  }

  @override
  Future<NoteEntity?> getNoteById(String id) async {
    try {
      final result = await _databaseHelper.query(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return NoteEntity.fromDatabaseJson(result.first);
    } catch (e) {
      throw CacheException('Failed to get note by id: $e');
    }
  }

  @override
  Future<String> createNote(NoteEntity note) async {
    try {
      await _databaseHelper.insert('notes', note.toDatabaseJson());
      return note.id;
    } catch (e) {
      throw CacheException('Failed to create note: $e');
    }
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    try {
      final rowsAffected = await _databaseHelper.update(
        'notes',
        note.toDatabaseJson(),
        where: 'id = ?',
        whereArgs: [note.id],
      );

      if (rowsAffected == 0) {
        throw CacheException('Note not found for update: ${note.id}');
      }
    } catch (e) {
      throw CacheException('Failed to update note: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      final rowsAffected = await _databaseHelper.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw CacheException('Note not found for deletion: $id');
      }
    } catch (e) {
      throw CacheException('Failed to delete note: $e');
    }
  }

  @override
  Future<List<NoteEntity>> searchNotes(String query, {String? userId}) async {
    try {
      String where = '(title LIKE ? OR content LIKE ?)';
      List<Object?> whereArgs = ['%$query%', '%$query%'];

      if (userId != null) {
        where += ' AND user_id = ?';
        whereArgs.add(userId);
      }

      final result = await _databaseHelper.query(
        'notes',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'updated_at DESC',
      );

      return result.map((json) => NoteEntity.fromDatabaseJson(json)).toList();
    } catch (e) {
      throw CacheException('Failed to search notes: $e');
    }
  }

  @override
  Future<void> clearAllNotes() async {
    try {
      await _databaseHelper.delete('notes');
    } catch (e) {
      throw CacheException('Failed to clear all notes: $e');
    }
  }

}