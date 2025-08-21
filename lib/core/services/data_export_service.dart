import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get_it/get_it.dart';

import '../../domain/repositories/notes_repository.dart';
import '../../domain/entities/note_entity.dart';
import 'user_preferences_service.dart';

enum ExportFormat {
  json,
  txt,
  csv,
}

enum ExportResult {
  success,
  error,
  cancelled,
}

class ExportData {
  final String appVersion;
  final DateTime exportDate;
  final String userId;
  final Map<String, dynamic> preferences;
  final List<Map<String, dynamic>> notes;
  final Map<String, dynamic> metadata;

  ExportData({
    required this.appVersion,
    required this.exportDate,
    required this.userId,
    required this.preferences,
    required this.notes,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'appVersion': appVersion,
      'exportDate': exportDate.toIso8601String(),
      'userId': userId,
      'preferences': preferences,
      'notes': notes,
      'metadata': metadata,
    };
  }
}

class DataExportService {
  static final DataExportService _instance = DataExportService._internal();
  factory DataExportService() => _instance;
  DataExportService._internal();

  final NotesRepository _notesRepository = GetIt.instance<NotesRepository>();
  final UserPreferencesService _prefsService = GetIt.instance<UserPreferencesService>();

  // 导出所有数据
  Future<ExportResult> exportAllData({
    ExportFormat format = ExportFormat.json,
    String? customFileName,
  }) async {
    try {
      final exportData = await _generateExportData();
      
      final fileName = customFileName ?? 
          'noteflow_backup_${DateTime.now().millisecondsSinceEpoch}';
      
      switch (format) {
        case ExportFormat.json:
          return await _exportAsJson(exportData, fileName);
        case ExportFormat.txt:
          return await _exportAsText(exportData, fileName);
        case ExportFormat.csv:
          return await _exportAsCsv(exportData, fileName);
      }
    } catch (e) {
      return ExportResult.error;
    }
  }

  // 只导出笔记数据
  Future<ExportResult> exportNotesOnly({
    ExportFormat format = ExportFormat.json,
    String? customFileName,
    List<String>? noteIds,
  }) async {
    try {
      final notes = await _getAllNotes();
      final filteredNotes = noteIds != null 
          ? notes.where((note) => noteIds.contains(note.id)).toList()
          : notes;

      final fileName = customFileName ?? 
          'noteflow_notes_${DateTime.now().millisecondsSinceEpoch}';
      
      switch (format) {
        case ExportFormat.json:
          return await _exportNotesAsJson(filteredNotes, fileName);
        case ExportFormat.txt:
          return await _exportNotesAsText(filteredNotes, fileName);
        case ExportFormat.csv:
          return await _exportNotesAsCsv(filteredNotes, fileName);
      }
    } catch (e) {
      return ExportResult.error;
    }
  }

  // 生成完整的导出数据
  Future<ExportData> _generateExportData() async {
    final notes = await _getAllNotes();
    final preferences = _prefsService.exportPreferences();

    return ExportData(
      appVersion: '1.0.0',
      exportDate: DateTime.now(),
      userId: 'user_1', // TODO: 从用户会话获取
      preferences: preferences,
      notes: notes.map((note) => _noteToExportMap(note)).toList(),
      metadata: {
        'totalNotes': notes.length,
        'pinnedNotes': notes.where((n) => n.isPinned == true).length,
        'favoriteNotes': notes.where((n) => n.isFavorite == true).length,
        'encryptedNotes': notes.where((n) => n.isEncrypted == true).length,
        'uniqueTags': _getUniqueTags(notes),
      },
    );
  }

  // 获取所有笔记
  Future<List<NoteEntity>> _getAllNotes() async {
    final result = await _notesRepository.getNotes(userId: 'user_1'); // TODO: 使用真实用户ID
    return result.fold(
      (failure) => <NoteEntity>[],
      (notes) => notes,
    );
  }

  // 获取所有唯一标签
  Set<String> _getUniqueTags(List<NoteEntity> notes) {
    final allTags = <String>{};
    for (final note in notes) {
      allTags.addAll(note.tags);
    }
    return allTags;
  }

  // 将笔记转换为导出格式
  Map<String, dynamic> _noteToExportMap(NoteEntity note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'tags': note.tags,
      'createdAt': note.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': note.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'isPinned': note.isPinned,
      'isFavorite': note.isFavorite,
      'isEncrypted': note.isEncrypted,
      'color': note.color,
      'userId': note.userId,
      'attachments': note.attachments,
      'metadata': note.metadata,
    };
  }

  // 导出为JSON格式
  Future<ExportResult> _exportAsJson(ExportData data, String fileName) async {
    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(data.toJson());
      final file = await _createTempFile('$fileName.json', jsonString);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'NoteFlow完整数据备份',
        subject: 'NoteFlow数据导出',
      );
      
      return ExportResult.success;
    } catch (e) {
      return ExportResult.error;
    }
  }

  // 导出笔记为JSON格式
  Future<ExportResult> _exportNotesAsJson(List<NoteEntity> notes, String fileName) async {
    try {
      final notesData = {
        'exportDate': DateTime.now().toIso8601String(),
        'totalNotes': notes.length,
        'notes': notes.map((note) => _noteToExportMap(note)).toList(),
      };
      
      final jsonString = const JsonEncoder.withIndent('  ').convert(notesData);
      final file = await _createTempFile('$fileName.json', jsonString);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'NoteFlow笔记备份',
        subject: 'NoteFlow笔记导出',
      );
      
      return ExportResult.success;
    } catch (e) {
      return ExportResult.error;
    }
  }

  // 导出为文本格式
  Future<ExportResult> _exportAsText(ExportData data, String fileName) async {
    try {
      final buffer = StringBuffer();
      
      buffer.writeln('NoteFlow 数据导出');
      buffer.writeln('=' * 50);
      buffer.writeln('导出时间: ${data.exportDate}');
      buffer.writeln('应用版本: ${data.appVersion}');
      buffer.writeln('用户ID: ${data.userId}');
      buffer.writeln('笔记总数: ${data.notes.length}');
      buffer.writeln();
      
      // 导出笔记
      buffer.writeln('笔记内容');
      buffer.writeln('-' * 30);
      
      for (var i = 0; i < data.notes.length; i++) {
        final note = data.notes[i];
        buffer.writeln('${i + 1}. ${note['title']}');
        buffer.writeln('   创建时间: ${note['createdAt']}');
        buffer.writeln('   标签: ${note['tags'].join(', ')}');
        if (note['isPinned'] == true) buffer.writeln('   📌 置顶');
        if (note['isFavorite'] == true) buffer.writeln('   ❤️ 收藏');
        buffer.writeln();
        buffer.writeln('   ${note['content']}');
        buffer.writeln();
        buffer.writeln('-' * 30);
        buffer.writeln();
      }
      
      final file = await _createTempFile('$fileName.txt', buffer.toString());
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'NoteFlow数据备份（文本格式）',
        subject: 'NoteFlow数据导出',
      );
      
      return ExportResult.success;
    } catch (e) {
      return ExportResult.error;
    }
  }

  // 导出笔记为文本格式
  Future<ExportResult> _exportNotesAsText(List<NoteEntity> notes, String fileName) async {
    try {
      final buffer = StringBuffer();
      
      buffer.writeln('NoteFlow 笔记导出');
      buffer.writeln('=' * 50);
      buffer.writeln('导出时间: ${DateTime.now()}');
      buffer.writeln('笔记总数: ${notes.length}');
      buffer.writeln();
      
      for (var i = 0; i < notes.length; i++) {
        final note = notes[i];
        buffer.writeln('${i + 1}. ${note.title}');
        buffer.writeln('   创建时间: ${note.createdAt}');
        buffer.writeln('   标签: ${note.tags.join(', ')}');
        if (note.isPinned) buffer.writeln('   📌 置顶');
       // if (note.isFavorite) buffer.writeln('   ❤️ 收藏');
        buffer.writeln();
        buffer.writeln('   ${note.content}');
        buffer.writeln();
        buffer.writeln('-' * 30);
        buffer.writeln();
      }
      
      final file = await _createTempFile('$fileName.txt', buffer.toString());
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'NoteFlow笔记备份（文本格式）',
        subject: 'NoteFlow笔记导出',
      );
      
      return ExportResult.success;
    } catch (e) {
      return ExportResult.error;
    }
  }

  // 导出为CSV格式
  Future<ExportResult> _exportAsCsv(ExportData data, String fileName) async {
    try {
      final buffer = StringBuffer();
      
      // CSV 头部
      buffer.writeln('"标题","内容","标签","创建时间","更新时间","是否置顶","是否收藏","是否加密"');
      
      // CSV 数据
      for (final note in data.notes) {
        final title = _escapeCsv(note['title'] ?? '');
        final content = _escapeCsv(note['content'] ?? '');
        final tags = _escapeCsv((note['tags'] as List).join(', '));
        final createdAt = note['createdAt'] ?? '';
        final updatedAt = note['updatedAt'] ?? '';
        final isPinned = note['isPinned'] == true ? '是' : '否';
        final isFavorite = note['isFavorite'] == true ? '是' : '否';
        final isEncrypted = note['isEncrypted'] == true ? '是' : '否';
        
        buffer.writeln('"$title","$content","$tags","$createdAt","$updatedAt","$isPinned","$isFavorite","$isEncrypted"');
      }
      
      final file = await _createTempFile('$fileName.csv', buffer.toString());
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'NoteFlow数据备份（CSV格式）',
        subject: 'NoteFlow数据导出',
      );
      
      return ExportResult.success;
    } catch (e) {
      return ExportResult.error;
    }
  }

  // 导出笔记为CSV格式
  Future<ExportResult> _exportNotesAsCsv(List<NoteEntity> notes, String fileName) async {
    try {
      final buffer = StringBuffer();
      
      // CSV 头部
      buffer.writeln('"标题","内容","标签","创建时间","更新时间","是否置顶","是否收藏","是否加密"');
      
      // CSV 数据
      for (final note in notes) {
        final title = _escapeCsv(note.title);
        final content = _escapeCsv(note.content);
        final tags = _escapeCsv(note.tags.join(', '));
        final createdAt = note.createdAt?.toIso8601String() ?? '';
        final updatedAt = note.updatedAt?.toIso8601String() ?? '';
        final isPinned = (note.isPinned == true) ? '是' : '否';
        final isFavorite = (note.isFavorite == true) ? '是' : '否';
        final isEncrypted = (note.isEncrypted == true) ? '是' : '否';
        
        buffer.writeln('"$title","$content","$tags","$createdAt","$updatedAt","$isPinned","$isFavorite","$isEncrypted"');
      }
      
      final file = await _createTempFile('$fileName.csv', buffer.toString());
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'NoteFlow笔记备份（CSV格式）',
        subject: 'NoteFlow笔记导出',
      );
      
      return ExportResult.success;
    } catch (e) {
      return ExportResult.error;
    }
  }

  // 创建临时文件
  Future<File> _createTempFile(String fileName, String content) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.writeAsString(content, encoding: utf8);
  }

  // 转义CSV字段
  String _escapeCsv(String value) {
    return value.replaceAll('"', '""');
  }

  // 获取导出统计信息
  Future<Map<String, dynamic>> getExportStatistics() async {
    final notes = await _getAllNotes();
    final uniqueTags = _getUniqueTags(notes);
    
    return {
      'totalNotes': notes.length,
      'pinnedNotes': notes.where((n) => n.isPinned).length,
      //'favoriteNotes': notes.where((n) => n.isFavorite).length,
      'encryptedNotes': notes.where((n) => n.isEncrypted == true).length,
      'uniqueTags': uniqueTags.length,
      'tagsList': uniqueTags.toList(),
      'oldestNote': notes.isNotEmpty 
          ? notes.reduce((a, b) => (a.createdAt ?? DateTime.now()).isBefore(b.createdAt ?? DateTime.now()) ? a : b).createdAt
          : null,
      'newestNote': notes.isNotEmpty 
          ? notes.reduce((a, b) => (a.createdAt ?? DateTime.now()).isBefore(b.createdAt ?? DateTime.now()) ? a : b).createdAt
          : null,
    };
  }
}