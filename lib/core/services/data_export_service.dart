import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:file_picker/file_picker.dart';

import '../../domain/repositories/notes_repository.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/entities/reminder_entity.dart';
import 'user_preferences_service.dart';
import 'reminder_service.dart';

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

enum ImportResult {
  success,
  error,
  cancelled,
  invalidFormat,
  incompatibleVersion,
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

  factory ExportData.fromJson(Map<String, dynamic> json) {
    return ExportData(
      appVersion: json['appVersion'] as String,
      exportDate: DateTime.parse(json['exportDate'] as String),
      userId: json['userId'] as String,
      preferences: json['preferences'] as Map<String, dynamic>,
      notes: (json['notes'] as List).cast<Map<String, dynamic>>(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }
}

class DataExportService {
  static final DataExportService _instance = DataExportService._internal();
  factory DataExportService() => _instance;
  DataExportService._internal();

  final NotesRepository _notesRepository = GetIt.instance<NotesRepository>();
  final UserPreferencesService _prefsService = GetIt.instance<UserPreferencesService>();
  final ReminderService _reminderService = GetIt.instance<ReminderService>();

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
    final reminderSettings = _reminderService.exportReminderSettings();
    final allReminders = await _reminderService.getAllReminders();
    
    // 合并所有设置
    final allPreferences = Map<String, dynamic>.from(preferences);
    allPreferences['reminder_settings'] = reminderSettings;
    allPreferences['reminders'] = allReminders.map((r) => r.toJson()).toList();

    return ExportData(
      appVersion: '1.0.0',
      exportDate: DateTime.now(),
      userId: 'user_1', // TODO: 从用户会话获取
      preferences: allPreferences,
      notes: notes.map((note) => _noteToExportMap(note)).toList(),
      metadata: {
        'totalNotes': notes.length,
        'pinnedNotes': notes.where((n) => n.isPinned == true).length,
        'favoriteNotes': notes.where((n) => n.isFavorite == true).length,
        'encryptedNotes': notes.where((n) => n.isEncrypted == true).length,
        'uniqueTags': _getUniqueTags(notes).toList(),
        'totalReminders': allReminders.length,
        'activeReminders': allReminders.where((r) => r.isEnabled).length,
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
      
      final shareSuccess = await _shareFile(
        file,
        'NoteFlow完整数据备份',
        'NoteFlow数据导出',
      );
      
      return shareSuccess ? ExportResult.success : ExportResult.error;
    } catch (e) {
      print('JSON导出失败: $e');
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
    try {
      final directory = await getTemporaryDirectory();
      print('临时目录路径: ${directory.path}');
      
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content, encoding: utf8);
      
      // 验证文件是否创建成功
      final exists = await file.exists();
      final size = await file.length();
      print('文件创建成功: $exists, 大小: $size bytes, 路径: ${file.path}');
      
      return file;
    } catch (e) {
      print('创建临时文件失败: $e');
      rethrow;
    }
  }

  // 安全的分享文件方法
  Future<bool> _shareFile(File file, String text, String subject) async {
    try {
      print('准备分享文件: ${file.path}');
      
      // 确认文件存在
      if (!await file.exists()) {
        print('文件不存在: ${file.path}');
        return false;
      }
      
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: text,
        subject: subject,
      );
      
      print('分享结果: $result');
      return true;
    } catch (e) {
      print('分享文件失败: $e');
      return false;
    }
  }

  // 转义CSV字段
  String _escapeCsv(String value) {
    return value.replaceAll('"', '""');
  }

  // 诊断文件系统权限
  Future<Map<String, dynamic>> diagnosisFileSystem() async {
    final result = <String, dynamic>{};
    
    try {
      // 测试临时目录访问
      final tempDir = await getTemporaryDirectory();
      result['temp_directory'] = tempDir.path;
      result['temp_directory_exists'] = await tempDir.exists();
      
      // 测试创建文件
      final testFile = File('${tempDir.path}/test.txt');
      await testFile.writeAsString('test content');
      result['file_creation'] = await testFile.exists();
      result['file_size'] = await testFile.length();
      
      // 清理测试文件
      if (await testFile.exists()) {
        await testFile.delete();
      }
      
      result['diagnosis_success'] = true;
    } catch (e) {
      result['diagnosis_success'] = false;
      result['error'] = e.toString();
    }
    
    return result;
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

  // 导入备份数据
  Future<ImportResult> importBackupData(String jsonContent, {
    bool replaceExisting = false,
    bool importSettings = true,
    bool importNotes = true,
  }) async {
    try {
      // 首先尝试解析JSON
      final Map<String, dynamic> jsonData;
      try {
        jsonData = jsonDecode(jsonContent);
      } on FormatException {
        // JSON格式错误
        return ImportResult.invalidFormat;
      }
      
      // 验证数据格式
      if (!_isValidBackupFormat(jsonData)) {
        return ImportResult.invalidFormat;
      }

      final exportData = ExportData.fromJson(jsonData);
      
      // 检查版本兼容性
      if (!_isCompatibleVersion(exportData.appVersion)) {
        return ImportResult.incompatibleVersion;
      }

      // 导入设置
      if (importSettings && exportData.preferences.isNotEmpty) {
        // 导入基本偏好设置
        await _prefsService.importPreferences(exportData.preferences);
        
        // 导入提醒设置
        if (exportData.preferences.containsKey('reminder_settings')) {
          await _reminderService.importReminderSettings(
            exportData.preferences['reminder_settings'] as Map<String, dynamic>
          );
        }
        
        // 导入提醒数据
        if (exportData.preferences.containsKey('reminders')) {
          final remindersData = exportData.preferences['reminders'] as List<dynamic>;
          // 清空现有提醒
          await _reminderService.clearAllReminders();
          // 导入新提醒
          for (final reminderJson in remindersData) {
            try {
              final reminder = ReminderEntity.fromJson(reminderJson as Map<String, dynamic>);
              await _reminderService.createReminder(reminder);
            } catch (e) {
              // 跳过有问题的提醒
              continue;
            }
          }
        }
      }

      // 导入笔记
      if (importNotes && exportData.notes.isNotEmpty) {
        await _importNotes(exportData.notes, replaceExisting);
      }

      return ImportResult.success;
    } catch (e) {
      return ImportResult.error;
    }
  }

  // 导入仅笔记数据
  Future<ImportResult> importNotesData(String jsonContent, {
    bool replaceExisting = false,
  }) async {
    try {
      // 首先尝试解析JSON
      final Map<String, dynamic> jsonData;
      try {
        jsonData = jsonDecode(jsonContent);
      } on FormatException {
        // JSON格式错误
        return ImportResult.invalidFormat;
      }
      
      // 验证笔记数据格式
      if (!jsonData.containsKey('notes') || jsonData['notes'] is! List) {
        return ImportResult.invalidFormat;
      }

      final notes = jsonData['notes'] as List<dynamic>;
      await _importNotes(notes.cast<Map<String, dynamic>>(), replaceExisting);

      return ImportResult.success;
    } catch (e) {
      return ImportResult.error;
    }
  }

  // 验证备份数据格式
  bool _isValidBackupFormat(Map<String, dynamic> data) {
    return data.containsKey('appVersion') &&
           data.containsKey('exportDate') &&
           data.containsKey('userId') &&
           data.containsKey('preferences') &&
           data.containsKey('notes') &&
           data.containsKey('metadata');
  }

  // 检查版本兼容性
  bool _isCompatibleVersion(String backupVersion) {
    // 这里可以实现更复杂的版本兼容性检查
    // 目前简单地接受所有版本
    return true;
  }

  // 导入笔记数据
  Future<void> _importNotes(List<Map<String, dynamic>> notesData, bool replaceExisting) async {
    final currentNotes = await _getAllNotes();
    final currentNoteIds = currentNotes.map((n) => n.id).toSet();

    for (final noteData in notesData) {
      try {
        final noteEntity = _exportMapToNote(noteData);
        
        if (currentNoteIds.contains(noteEntity.id)) {
          if (replaceExisting) {
            // 更新现有笔记
            await _notesRepository.updateNote(noteEntity);
          }
          // 如果不替换，则跳过
        } else {
          // 创建新笔记
          await _notesRepository.createNote(noteEntity);
        }
      } catch (e) {
        // 跳过有问题的笔记，继续导入其他笔记
        continue;
      }
    }
  }

  // 将导出格式转换为笔记实体
  NoteEntity _exportMapToNote(Map<String, dynamic> data) {
    return NoteEntity(
      id: data['id'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      tags: (data['tags'] as List<dynamic>).cast<String>(),
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt'] as String)
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt'] as String)
          : DateTime.now(),
      isPinned: data['isPinned'] as bool? ?? false,
      isFavorite: data['isFavorite'] as bool? ?? false,
      isEncrypted: data['isEncrypted'] as bool? ?? false,
      password: data['password'] as String?,
      color: data['color'] as int?,
      userId: data['userId'] as String,
      attachments: (data['attachments'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  // 获取导入结果的描述信息
  String getImportResultDescription(ImportResult result) {
    switch (result) {
      case ImportResult.success:
        return '数据导入成功';
      case ImportResult.error:
        return '导入过程中发生错误，请检查文件是否为有效的JSON格式';
      case ImportResult.cancelled:
        return '用户取消了导入操作';
      case ImportResult.invalidFormat:
        return '备份文件格式不正确，仅支持JSON格式的备份文件';
      case ImportResult.incompatibleVersion:
        return '备份文件版本不兼容，请使用较新版本的备份文件';
    }
  }

  // 选择并导入备份文件
  Future<ImportResult> pickAndImportBackupFile({
    bool replaceExisting = false,
    bool importSettings = true,
    bool importNotes = true,
  }) async {
    try {
      // 选择文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult.cancelled;
      }

      final file = result.files.first;
      if (file.path == null) {
        return ImportResult.error;
      }

      // 读取文件内容
      final fileContent = await File(file.path!).readAsString();
      
      // 导入数据
      return await importBackupData(
        fileContent,
        replaceExisting: replaceExisting,
        importSettings: importSettings,
        importNotes: importNotes,
      );
    } catch (e) {
      return ImportResult.error;
    }
  }

  // 选择并导入笔记文件
  Future<ImportResult> pickAndImportNotesFile({
    bool replaceExisting = false,
  }) async {
    try {
      // 选择文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult.cancelled;
      }

      final file = result.files.first;
      if (file.path == null) {
        return ImportResult.error;
      }

      // 读取文件内容
      final fileContent = await File(file.path!).readAsString();
      
      // 导入笔记数据
      return await importNotesData(
        fileContent,
        replaceExisting: replaceExisting,
      );
    } catch (e) {
      return ImportResult.error;
    }
  }
}