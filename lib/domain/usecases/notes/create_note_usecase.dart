import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/reminder_service.dart';
import '../../entities/note_entity.dart';
import '../../repositories/notes_repository.dart';

class CreateNoteUseCase {
  final NotesRepository repository;
  final ReminderService reminderService;

  CreateNoteUseCase(this.repository, this.reminderService);

  Future<Either<Failure, String>> call(CreateNoteParams params) async {
    final now = DateTime.now();
    
    final note = NoteEntity(
      id: params.id ?? const Uuid().v4(),
      title: params.title.trim(),
      content: params.content.trim(),
      tags: params.tags ?? [],
      createdAt: params.createdAt ?? now,
      updatedAt: params.updatedAt ?? now,
      isPinned: params.isPinned ?? false,
      isEncrypted: params.isEncrypted ?? false,
      password: params.password,
      color: params.color,
      userId: params.userId,
      isFavorite: params.isFavorite ?? false,
      attachments: params.attachments ?? [],
      metadata: params.metadata,
    );

    // Validate note data
    if (note.title.isEmpty && note.content.isEmpty) {
      return Left(ValidationFailure('Note title and content cannot both be empty'));
    }

    if (note.userId.isEmpty) {
      return Left(ValidationFailure('User ID is required'));
    }

    final result = await repository.createNote(note);
    
    // 如果笔记创建成功，尝试自动创建提醒
    result.fold(
      (failure) => null, // 创建失败时不创建提醒
      (noteId) async {
        try {
          await reminderService.createReminderForNote(note.id, note.title);
        } catch (e) {
          // 如果创建提醒失败，不影响笔记创建的结果
          print('创建自动提醒失败: $e');
        }
      },
    );
    
    return result;
  }
}

class CreateNoteParams {
  final String? id;
  final String title;
  final String content;
  final List<String>? tags;
  final bool? isPinned;
  final bool? isEncrypted;
  final String? password;
  final int? color;
  final String userId;
  final bool? isFavorite;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CreateNoteParams({
    this.id,
    required this.title,
    required this.content,
    this.tags,
    this.isPinned,
    this.isEncrypted,
    this.password,
    this.color,
    required this.userId,
    this.isFavorite,
    this.attachments,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });
}