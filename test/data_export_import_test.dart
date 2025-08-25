import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:noteflow_app/core/services/data_export_service.dart';
import 'package:noteflow_app/core/services/user_preferences_service.dart';
import 'package:noteflow_app/core/services/reminder_service.dart';
import 'package:noteflow_app/data/datasources/local/database_helper.dart';
import 'package:noteflow_app/data/datasources/local/notes_local_data_source.dart';
import 'package:noteflow_app/data/repositories/notes_repository_impl.dart';
import 'package:noteflow_app/domain/repositories/notes_repository.dart';

void main() {
  late DataExportService exportService;

  setUp(() async {
    // Mock SharedPreferences with an empty map
    SharedPreferences.setMockInitialValues({});
    
    // Setup GetIt for testing
    if (GetIt.instance.isRegistered<UserPreferencesService>()) {
      await GetIt.instance.reset();
    }
    
    final userPrefs = UserPreferencesService.instance;
    await userPrefs.init();
    GetIt.instance.registerSingleton<UserPreferencesService>(userPrefs);
    
    final reminderService = ReminderService.instance;
    await reminderService.init();
    GetIt.instance.registerSingleton<ReminderService>(reminderService);
    
    // Mock database and repository for testing
    GetIt.instance.registerSingleton<DatabaseHelper>(DatabaseHelper());
    GetIt.instance.registerSingleton<NotesLocalDataSource>(
      NotesLocalDataSourceImpl(GetIt.instance<DatabaseHelper>())
    );
    GetIt.instance.registerSingleton<NotesRepository>(
      NotesRepositoryImpl(localDataSource: GetIt.instance<NotesLocalDataSource>())
    );
    
    exportService = DataExportService();
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('DataExportService Import Tests', () {
    test('should reject non-JSON content', () async {
      const textContent = '''
      这是一个文本格式的备份文件
      标题: 测试笔记
      内容: 这是笔记内容
      ''';

      final result = await exportService.importBackupData(textContent);
      expect(result, ImportResult.invalidFormat);
    });

    test('should reject CSV content', () async {
      const csvContent = '''
      ID,Title,Content,Tags,CreatedAt
      1,"Test Note","This is content","tag1,tag2","2023-01-01"
      ''';

      final result = await exportService.importBackupData(csvContent);
      expect(result, ImportResult.invalidFormat);
    });

    test('should reject invalid JSON format', () async {
      const invalidJson = '{"invalid": json format}';

      final result = await exportService.importBackupData(invalidJson);
      expect(result, ImportResult.invalidFormat);
    });

    test('should reject JSON without required fields', () async {
      const incompleteJson = '''
      {
        "appVersion": "1.0.0",
        "exportDate": "2023-01-01T00:00:00.000Z"
      }
      ''';

      final result = await exportService.importBackupData(incompleteJson);
      expect(result, ImportResult.invalidFormat);
    });

    test('should accept valid JSON backup format', () async {
      const validJson = '''
      {
        "appVersion": "1.0.0",
        "exportDate": "2023-01-01T00:00:00.000Z",
        "userId": "user_1",
        "preferences": {},
        "notes": [],
        "metadata": {}
      }
      ''';

      final result = await exportService.importBackupData(validJson);
      expect(result, ImportResult.success);
    });

    test('should provide correct error descriptions', () {
      expect(
        exportService.getImportResultDescription(ImportResult.invalidFormat),
        '备份文件格式不正确，仅支持JSON格式的备份文件',
      );
      
      expect(
        exportService.getImportResultDescription(ImportResult.error),
        '导入过程中发生错误，请检查文件是否为有效的JSON格式',
      );
      
      expect(
        exportService.getImportResultDescription(ImportResult.success),
        '数据导入成功',
      );
    });

    test('should reject notes-only import with invalid format', () async {
      const invalidNotesJson = '''
      {
        "totalNotes": 1,
        "invalidKey": []
      }
      ''';

      final result = await exportService.importNotesData(invalidNotesJson);
      expect(result, ImportResult.invalidFormat);
    });

    test('should accept valid notes-only JSON format', () async {
      const validNotesJson = '''
      {
        "exportDate": "2023-01-01T00:00:00.000Z",
        "totalNotes": 1,
        "notes": [
          {
            "id": "note_1",
            "title": "Test Note",
            "content": "This is a test note",
            "tags": ["test"],
            "createdAt": "2023-01-01T00:00:00.000Z",
            "updatedAt": "2023-01-01T00:00:00.000Z",
            "isPinned": false,
            "isFavorite": false,
            "isEncrypted": false,
            "color": null,
            "userId": "user_1",
            "attachments": [],
            "metadata": null
          }
        ]
      }
      ''';

      final result = await exportService.importNotesData(validNotesJson);
      expect(result, ImportResult.success);
    });
  });
}