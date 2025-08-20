import 'dart:convert';
import '../../../core/errors/exceptions.dart';
import '../../models/note_model.dart';
import 'database_helper.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteModel>> getNotes({
    String? userId,
    bool? isPinned,
    List<String>? tags,
    int? limit,
    int? offset,
  });
  Future<NoteModel?> getNoteById(String id);
  Future<String> createNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<List<NoteModel>> searchNotes(String query, {String? userId});
  Future<void> clearAllNotes();
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final DatabaseHelper _databaseHelper;

  NotesLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<NoteModel>> getNotes({
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

      return result.map((json) => _mapToNoteModel(json)).toList();
    } catch (e) {
      throw CacheException('Failed to get notes: $e');
    }
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    try {
      final result = await _databaseHelper.query(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return _mapToNoteModel(result.first);
    } catch (e) {
      throw CacheException('Failed to get note by id: $e');
    }
  }

  @override
  Future<String> createNote(NoteModel note) async {
    try {
      await _databaseHelper.insert('notes', _noteModelToMap(note));
      return note.id;
    } catch (e) {
      throw CacheException('Failed to create note: $e');
    }
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    try {
      final rowsAffected = await _databaseHelper.update(
        'notes',
        _noteModelToMap(note),
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
  Future<List<NoteModel>> searchNotes(String query, {String? userId}) async {
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

      return result.map((json) => _mapToNoteModel(json)).toList();
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

  // Helper methods for mapping between NoteModel and database Map
  Map<String, Object?> _noteModelToMap(NoteModel note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'tags': jsonEncode(note.tags),
      'created_at': note.createdAt.millisecondsSinceEpoch,
      'updated_at': note.updatedAt.millisecondsSinceEpoch,
      'is_pinned': note.isPinned ? 1 : 0,
      'is_encrypted': note.isEncrypted ? 1 : 0,
      'password': note.password,
      'color': note.color,
      'user_id': note.userId,
      'is_favorite': note.isFavorite ? 1 : 0,
      'attachments': jsonEncode(note.attachments),
      'metadata': note.metadata != null ? jsonEncode(note.metadata) : null,
    };
  }

  NoteModel _mapToNoteModel(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      tags: List<String>.from(jsonDecode(map['tags'] as String)),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isPinned: (map['is_pinned'] as int) == 1,
      isEncrypted: (map['is_encrypted'] as int) == 1,
      password: map['password'] as String?,
      color: map['color'] as int?,
      userId: map['user_id'] as String,
      isFavorite: (map['is_favorite'] as int) == 1,
      attachments: List<String>.from(jsonDecode(map['attachments'] as String)),
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(jsonDecode(map['metadata'] as String))
          : null,
    );
  }
}