import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
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

  const NoteEntity({
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
  
  Duration get age => DateTime.now().difference(createdAt);
  
  bool get isRecentlyModified => 
      DateTime.now().difference(updatedAt).inHours < 24;
}