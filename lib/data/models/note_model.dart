import '../../domain/entities/note_entity.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isEncrypted;
  final String? password;
  final int? color;
  final String userId;
  final bool isFavorite;
  final List<String> attachments;
  final Map<String, dynamic>? metadata;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.isPinned,
    required this.isEncrypted,
    this.password,
    this.color,
    required this.userId,
    required this.isFavorite,
    required this.attachments,
    this.metadata,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      tags: List<String>.from(json['tags'] as List),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
      isPinned: json['is_pinned'] as bool,
      isEncrypted: json['is_encrypted'] as bool,
      password: json['password'] as String?,
      color: json['color'] as int?,
      userId: json['user_id'] as String,
      isFavorite: json['is_favorite'] as bool,
      attachments: List<String>.from(json['attachments'] as List),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_pinned': isPinned,
      'is_encrypted': isEncrypted,
      'password': password,
      'color': color,
      'user_id': userId,
      'is_favorite': isFavorite,
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  // Convert to domain entity
  NoteEntity toEntity() {
    return NoteEntity(
      id: id,
      title: title,
      content: content,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPinned: isPinned,
      isEncrypted: isEncrypted,
      password: password,
      color: color,
      userId: userId,
      isFavorite: isFavorite,
      attachments: attachments,
      metadata: metadata,
    );
  }

  // Create from domain entity
  factory NoteModel.fromEntity(NoteEntity entity) {
    return NoteModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      tags: entity.tags,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isPinned: entity.isPinned,
      isEncrypted: entity.isEncrypted,
      password: entity.password,
      color: entity.color,
      userId: entity.userId,
      isFavorite: entity.isFavorite,
      attachments: entity.attachments,
      metadata: entity.metadata,
    );
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isEncrypted,
    String? password,
    int? color,
    String? userId,
    bool? isFavorite,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      password: password ?? this.password,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      isFavorite: isFavorite ?? this.isFavorite,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }
}