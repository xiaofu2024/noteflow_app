import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/vip_config_entity.dart';
import '../../domain/repositories/vip_repository.dart';

class VipManager {
  static final VipManager _instance = VipManager._internal();
  factory VipManager() => _instance;
  VipManager._internal();

  static const String _keyCurrentVipLevel = 'current_vip_level';
  static const String _keyVipExpireTime = 'vip_expire_time';
  static const String _keyOcrUsageCount = 'ocr_usage_count';
  static const String _keyOcrUsageDate = 'ocr_usage_date';
  static const String _keySpeechUsageCount = 'speech_usage_count';
  static const String _keySpeechUsageDate = 'speech_usage_date';
  static const String _keyAiUsageCount = 'ai_usage_count';
  static const String _keyAiUsageDate = 'ai_usage_date';
  static const String _keyNoteCreateCount = 'note_create_count';
  static const String _keyNoteCreateDate = 'note_create_date';

  SharedPreferences? _prefs;
  VipConfigEntity? _vipConfig;
  
  StreamController<VipLevel>? _vipLevelController;
  Stream<VipLevel> get vipLevelStream {
    if (_vipLevelController == null || _vipLevelController!.isClosed) {
      _vipLevelController = StreamController<VipLevel>.broadcast();
    }
    return _vipLevelController!.stream;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load VIP configuration from API
    await loadVipConfig();
  }

  /// Load VIP configuration from remote API
  Future<void> loadVipConfig() async {
    try {
      final vipRepository = GetIt.instance<VipRepository>();
      final result = await vipRepository.getIapConfig();
      
      result.fold(
        (failure) {
          debugPrint('Failed to load VIP config: ${failure.message}');
          _setDefaultConfig();
        },
        (config) {
          debugPrint('VIP config loaded successfully, goods count: ${config.goods.length}');
          if (config.goods.isEmpty) {
            debugPrint('Warning: API returned empty goods list, using default config');
            _setDefaultConfig();
          } else {
            updateVipConfig(config);
          }
        },
      );
    } catch (e) {
      debugPrint('Error loading VIP config: $e');
      _setDefaultConfig();
    }
  }

  /// Set default VIP configuration when API fails or returns empty data
  void _setDefaultConfig() {
    debugPrint('Setting default VIP configuration');
    final defaultConfig = VipConfigEntity(
      goods: [
        // Free level
        VipProduct(
          id: 0,
          productId: '',
          level: VipLevel.vipLevel0,
          ocrLimit: 5,
          noteCreateLimit: -1, // Unlimited for notes
          speechLimit: 2,
          aiLimit: 1,
          exportData: ExportData.none,
          hasTemplate: false,
          period: 0,
          price: 0,
        ),
        // VIP Level 1
        VipProduct(
          id: 1,
          productId: 'com.shenghua.note.vip_3001',
          level: VipLevel.vipLevel1,
          ocrLimit: -1,
          noteCreateLimit: 10,
          speechLimit: 10,
          aiLimit: 5,
          exportData: ExportData.note,
          hasTemplate: true,
          period: 30,
          price: 388,
        ),
        // VIP Level 2
        VipProduct(
          id: 2,
          productId: 'com.shenghua.note.vip3002',
          level: VipLevel.vipLevel2,
          ocrLimit: -1,
          noteCreateLimit: 50,
          speechLimit: 60,
          aiLimit: 10,
          exportData: ExportData.setting,
          hasTemplate: true,
          period: 30,
          price: 588,
        ),
        // VIP Level 3
        VipProduct(
          id: 3,
          productId: 'com.shenghua.note.vip_3003',
          level: VipLevel.vipLevel3,
          ocrLimit: -1,
          noteCreateLimit: -1,
          speechLimit: -1,
          aiLimit: -1,
          exportData: ExportData.noteAndSetting,
          hasTemplate: true,
          period: 16,
          price: 688,
        ),
      ],
    );
    
    updateVipConfig(defaultConfig);
  }

  void updateVipConfig(VipConfigEntity config) {
    _vipConfig = config;
  }

  /// Get current VIP configuration (for debugging)
  VipConfigEntity? get currentVipConfig => _vipConfig;

  // VIP Level Management
  Future<void> setVipLevel(VipLevel level, {int? durationDays}) async {
    await _prefs?.setInt(_keyCurrentVipLevel, level.index);
    
    if (durationDays != null) {
      final expireTime = DateTime.now().add(Duration(days: durationDays));
      await _prefs?.setInt(_keyVipExpireTime, expireTime.millisecondsSinceEpoch);
    }
    
    if (_vipLevelController == null || _vipLevelController!.isClosed) {
      _vipLevelController = StreamController<VipLevel>.broadcast();
    }
    _vipLevelController!.add(level);
  }

  VipLevel getCurrentVipLevel() {
    final now = DateTime.now();
    final expireTime = getVipExpireTime();
    
    // Check if VIP has expired
    if (expireTime != null && now.isAfter(expireTime)) {
      // Reset to free level
      setVipLevel(VipLevel.vipLevel0);
      return VipLevel.vipLevel0;
    }
    
    final levelIndex = _prefs?.getInt(_keyCurrentVipLevel) ?? 0;
    return VipLevel.values[levelIndex];
  }

  DateTime? getVipExpireTime() {
    final expireTimeMs = _prefs?.getInt(_keyVipExpireTime);
    if (expireTimeMs == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(expireTimeMs);
  }

  bool get isVipActive {
    final level = getCurrentVipLevel();
    final expireTime = getVipExpireTime();
    
    if (level == VipLevel.vipLevel0) return false;
    if (expireTime == null) return true;
    
    return DateTime.now().isBefore(expireTime);
  }

  VipProduct? getCurrentVipProduct() {
    final currentLevel = getCurrentVipLevel();
    if (_vipConfig == null || _vipConfig!.goods.isEmpty) return null;
    
    try {
      return _vipConfig!.goods.firstWhere(
        (product) => product.level == currentLevel,
      );
    } catch (e) {
      // If no product matches current level, return the first product (free level)
      return _vipConfig!.goods.first;
    }
  }

  // Feature Restrictions
  Future<bool> canUseOCR() async {
    final product = getCurrentVipProduct();
    if (product == null) return false;
    
    if (product.isUnlimited) return true;
    
    final usage = await _getDailyUsage(_keyOcrUsageCount, _keyOcrUsageDate);
    return usage < product.ocrLimit;
  }

  Future<bool> canCreateNote() async {
    final product = getCurrentVipProduct();
    if (product == null) return false;
    
    if (product.hasUnlimitedNotes) return true;
    
    final usage = await _getDailyUsage(_keyNoteCreateCount, _keyNoteCreateDate);
    debugPrint("canCreateNote: $usage < ${product.noteCreateLimit}");
    return usage < product.noteCreateLimit;
  }

  Future<bool> canUseSpeechToText() async {
    final product = getCurrentVipProduct();
    if (product == null) return false;
    
    if (product.hasUnlimitedSpeech) return true;
    
    final usage = await _getDailyUsage(_keySpeechUsageCount, _keySpeechUsageDate);
    debugPrint("canUseSpeechToText: $usage < ${product.speechLimit}");
    return usage < product.speechLimit;
  }

  Future<bool> canUseAI() async {
    final product = getCurrentVipProduct();
    if (product == null) return false;
    
    if (product.hasUnlimitedAi) return true;
    
    final usage = await _getDailyUsage(_keyAiUsageCount, _keyAiUsageDate);
    return usage < product.aiLimit;
  }

  bool canExport(ExportData exportType) {
    final product = getCurrentVipProduct();
    debugPrint("canExport: $product, $exportType");
    if (product == null) return false;
    
    switch (product.exportData) {
      case ExportData.none:
        return false;
      case ExportData.note:
        return exportType == ExportData.note;
      case ExportData.setting:
        return exportType == ExportData.setting;
      case ExportData.noteAndSetting:
        return exportType == ExportData.note || 
               exportType == ExportData.setting ||
               exportType == ExportData.noteAndSetting;
      case ExportData.all:
        return true;
    }
  }

  // Usage Tracking
  Future<void> recordOCRUsage() async {
    await _incrementDailyUsage(_keyOcrUsageCount, _keyOcrUsageDate);
  }

  Future<void> recordNoteCreation() async {
    await _incrementDailyUsage(_keyNoteCreateCount, _keyNoteCreateDate);
  }

  Future<void> recordSpeechUsage() async {
    await _incrementDailyUsage(_keySpeechUsageCount, _keySpeechUsageDate);
  }

  Future<void> recordAIUsage() async {
    await _incrementDailyUsage(_keyAiUsageCount, _keyAiUsageDate);
  }

  // Usage Statistics
  Future<int> getOCRUsageCount() async {
    return await _getDailyUsage(_keyOcrUsageCount, _keyOcrUsageDate);
  }

  Future<int> getNoteCreateCount() async {
    return await _getDailyUsage(_keyNoteCreateCount, _keyNoteCreateDate);
  }

  Future<int> getSpeechUsageCount() async {
    return await _getDailyUsage(_keySpeechUsageCount, _keySpeechUsageDate);
  }

  Future<int> getAIUsageCount() async {
    return await _getDailyUsage(_keyAiUsageCount, _keyAiUsageDate);
  }

  // Helper Methods
  Future<int> _getDailyUsage(String countKey, String dateKey) async {
    final today = _getTodayString();
    final savedDate = _prefs?.getString(dateKey);
    
    if (savedDate != today) {
      // Reset usage count for new day
      await _prefs?.setInt(countKey, 0);
      await _prefs?.setString(dateKey, today);
      return 0;
    }
    
    return _prefs?.getInt(countKey) ?? 0;
  }

  Future<void> _incrementDailyUsage(String countKey, String dateKey) async {
    final currentUsage = await _getDailyUsage(countKey, dateKey);
    await _prefs?.setInt(countKey, currentUsage + 1);
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _vipLevelController?.close();
    _vipLevelController = null;
  }
}