import 'package:get_it/get_it.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/notes_local_data_source.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/usecases/notes/get_notes_usecase.dart';
import '../../domain/usecases/notes/create_note_usecase.dart';
import '../../domain/usecases/notes/update_note_usecase.dart';
import '../../domain/usecases/notes/delete_note_usecase.dart';
import '../../domain/usecases/notes/search_notes_usecase.dart';
import '../../presentation/bloc/notes/notes_bloc.dart';
import 'user_preferences_service.dart';
import 'theme_manager.dart';
import 'biometric_auth_service.dart';
import 'data_export_service.dart';
import 'note_color_service.dart';
import 'reminder_service.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Core
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  
  // Services
  sl.registerLazySingleton<UserPreferencesService>(() => UserPreferencesService.instance);
  await sl<UserPreferencesService>().init();
  
  sl.registerLazySingleton<NoteColorService>(() => NoteColorService.instance);
  await sl<NoteColorService>().init();
  
  sl.registerLazySingleton<ReminderService>(() => ReminderService.instance);
  await sl<ReminderService>().init();
  
  sl.registerLazySingleton<ThemeManager>(() => ThemeManager(sl()));
  sl.registerLazySingleton<BiometricAuthService>(() => BiometricAuthService());
  sl.registerLazySingleton<DataExportService>(() => DataExportService());
  
  // Initialize database and add sample data
  await _initializeSampleData();

  // Data sources
  sl.registerLazySingleton<NotesLocalDataSource>(
    () => NotesLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotesUseCase(sl()));
  sl.registerLazySingleton(() => CreateNoteUseCase(sl()));
  sl.registerLazySingleton(() => UpdateNoteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNoteUseCase(sl()));
  sl.registerLazySingleton(() => SearchNotesUseCase(sl()));

  // BLoCs - Use singleton to share state across the app
  sl.registerLazySingleton(
    () => NotesBloc(
      getNotesUseCase: sl(),
      createNoteUseCase: sl(),
      updateNoteUseCase: sl(),
      deleteNoteUseCase: sl(),
      searchNotesUseCase: sl(),
    ),
  );
}

Future<void> disposeDependencies() async {
  await sl.reset();
}

Future<void> _initializeSampleData() async {
  final dbHelper = sl<DatabaseHelper>();
  
  // Check if we already have data
  final existingNotes = await dbHelper.query('notes', limit: 1);
  if (existingNotes.isNotEmpty) return; // Already initialized
  
  // Sample notes data
  final sampleNotes = [
    {
      'id': 'note_1',
      'title': '会议笔记',
      'content': '今天的项目会议讨论了以下要点：\n1. 项目时间表调整\n2. 资源分配优化\n3. 下周milestone检查',
      'tags': '["工作", "会议"]',
      'created_at': DateTime.now().subtract(Duration(hours: 2)).millisecondsSinceEpoch,
      'updated_at': DateTime.now().subtract(Duration(hours: 2)).millisecondsSinceEpoch,
      'is_pinned': 1,
      'is_encrypted': 0,
      'password': null,
      'color': 0xFF4CAF50,
      'user_id': 'user_1',
      'is_favorite': 0,
      'attachments': '[]',
      'metadata': null,
    },
    {
      'id': 'note_2',
      'title': '购物清单',
      'content': '本周需要购买的物品：\n□ 牛奶\n□ 鸡蛋\n□ 面包\n□ 苹果\n□ 洗发水',
      'tags': '["生活", "购物"]',
      'created_at': DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch,
      'updated_at': DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch,
      'is_pinned': 1,
      'is_encrypted': 0,
      'password': null,
      'color': 0xFF2196F3,
      'user_id': 'user_1',
      'is_favorite': 1,
      'attachments': '[]',
      'metadata': null,
    },
    {
      'id': 'note_3',
      'title': '读书笔记',
      'content': '《高效能人士的七个习惯》阅读摘要：\n\n习惯一：积极主动\n- 关注影响圈而非关注圈\n- 承担责任，主动解决问题\n\n习惯二：以终为始\n- 制定个人使命宣言\n- 设定长远目标',
      'tags': '["学习", "读书"]',
      'created_at': DateTime.now().subtract(Duration(hours: 5)).millisecondsSinceEpoch,
      'updated_at': DateTime.now().subtract(Duration(hours: 5)).millisecondsSinceEpoch,
      'is_pinned': 0,
      'is_encrypted': 0,
      'password': null,
      'color': 0xFFFF9800,
      'user_id': 'user_1',
      'is_favorite': 1,
      'attachments': '[]',
      'metadata': null,
    },
    {
      'id': 'note_4',
      'title': '旅行计划',
      'content': '日本旅行行程安排：\n\n第1-3天：东京\n- 浅草寺、东京塔\n- 新宿、涩谷购物\n- 筑地市场美食\n\n第4-6天：京都\n- 清水寺、金阁寺\n- 岚山竹林\n- 传统温泉体验',
      'tags': '["旅行", "计划", "日本"]',
      'created_at': DateTime.now().subtract(Duration(days: 3)).millisecondsSinceEpoch,
      'updated_at': DateTime.now().subtract(Duration(days: 3)).millisecondsSinceEpoch,
      'is_pinned': 0,
      'is_encrypted': 0,
      'password': null,
      'color': 0xFFE91E63,
      'user_id': 'user_1',
      'is_favorite': 0,
      'attachments': '[]',
      'metadata': null,
    },
    {
      'id': 'note_5',
      'title': '健身计划',
      'content': '本周健身安排：\n\n周一：胸部+三头肌\n- 卧推 4组x8-10\n- 上斜哑铃推举 3组x12\n- 三头肌下压 3组x15\n\n周三：背部+二头肌\n- 引体向上 4组x6-8\n- 划船 3组x12\n- 二头肌弯举 3组x15',
      'tags': '["健身", "健康"]',
      'created_at': DateTime.now().subtract(Duration(days: 4)).millisecondsSinceEpoch,
      'updated_at': DateTime.now().subtract(Duration(days: 4)).millisecondsSinceEpoch,
      'is_pinned': 0,
      'is_encrypted': 0,
      'password': null,
      'color': 0xFF9C27B0,
      'user_id': 'user_1',
      'is_favorite': 0,
      'attachments': '[]',
      'metadata': null,
    },
  ];
  
  // Insert sample notes
  for (final noteData in sampleNotes) {
    await dbHelper.insert('notes', noteData);
  }
}