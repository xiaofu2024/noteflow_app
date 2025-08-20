import 'dart:convert';
import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isPinned;
  final bool? isEncrypted;
  final String? password;
  final int? color;
  final String userId;
  final bool? isFavorite;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
     this.createdAt,
     this.updatedAt,
    required this.isPinned,
     this.isEncrypted,
    this.password,
    this.color,
    required this.userId,
    this.isFavorite,
     this.attachments,
    this.metadata,
  });

  NoteEntity copyWith({
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
    return NoteEntity(
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

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        tags,
        createdAt,
        updatedAt,
        isPinned,
        isEncrypted,
        password,
        color,
        userId,
        isFavorite,
        attachments,
        metadata,
      ];

  // Helper methods
  bool get hasPassword => password != null && password!.isNotEmpty;
  
  String get previewText {
    final plainText = content.replaceAll(RegExp(r'<[^>]*>'), '');
    return plainText.length > 100 
        ? '${plainText.substring(0, 100)}...' 
        : plainText;
  }
  
  bool get isEmpty => title.trim().isEmpty && content.trim().isEmpty;
  
  Duration get age => DateTime.now().difference(createdAt ?? DateTime.now());
  
  bool get isRecentlyModified => 
      updatedAt != null && DateTime.now().difference(updatedAt!).inHours < 24;

  // JSON Serialization Methods
  factory NoteEntity.fromJson(Map<String, dynamic> json) {
    return NoteEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      tags: List<String>.from(json['tags'] as List),
      createdAt: json['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int)
          : DateTime.now(),
      isPinned: json['is_pinned'] as bool? ?? false,
      isEncrypted: json['is_encrypted'] as bool? ?? false,
      password: json['password'] as String?,
      color: json['color'] as int?,
      userId: json['user_id'] as String,
      isFavorite: json['is_favorite'] as bool? ?? false,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'created_at': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      'is_pinned': isPinned,
      'is_encrypted': isEncrypted ?? false,
      'password': password,
      'color': color,
      'user_id': userId,
      'is_favorite': isFavorite ?? false,
      'attachments': attachments ?? [],
      'metadata': metadata,
    };
  }

  // Database-compatible JSON conversion
  factory NoteEntity.fromDatabaseJson(Map<String, dynamic> json) {
    return NoteEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      tags: List<String>.from(jsonDecode(json['tags'] as String? ?? '[]')),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
      isPinned: (json['is_pinned'] as int) == 1,
      isEncrypted: (json['is_encrypted'] as int? ?? 0) == 1,
      password: json['password'] as String?,
      color: json['color'] as int?,
      userId: json['user_id'] as String,
      isFavorite: (json['is_favorite'] as int? ?? 0) == 1,
      attachments: List<String>.from(jsonDecode(json['attachments'] as String? ?? '[]')),
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(jsonDecode(json['metadata'] as String))
          : null,
    );
  }

  Map<String, Object?> toDatabaseJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': jsonEncode(tags),
      'created_at': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      'is_pinned': isPinned ? 1 : 0,
      'is_encrypted': (isEncrypted ?? false) ? 1 : 0,
      'password': password,
      'color': color,
      'user_id': userId,
      'is_favorite': (isFavorite ?? false) ? 1 : 0,
      'attachments': jsonEncode(attachments ?? []),
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }
}