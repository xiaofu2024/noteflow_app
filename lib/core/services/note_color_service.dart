import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/app_colors.dart';

class NoteColorService {
  static const String _noteColorsKey = 'note_colors';
  static const String _defaultColorKey = 'default_note_color';
  static const String _colorPresetsKey = 'color_presets';

  late SharedPreferences _prefs;
  
  static NoteColorService? _instance;
  
  NoteColorService._();
  
  static NoteColorService get instance {
    _instance ??= NoteColorService._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _initializeDefaultPresets();
  }

  // 初始化默认颜色预设
  void _initializeDefaultPresets() {
    if (!_prefs.containsKey(_colorPresetsKey)) {
      final defaultPresets = _getDefaultColorPresets();
      _prefs.setString(_colorPresetsKey, jsonEncode(defaultPresets));
    }
  }

  Map<String, dynamic> _getDefaultColorPresets() {
    return {
      'work': {'name': '工作', 'color': AppColors.noteCategoryColors[4].value},
      'personal': {'name': '个人', 'color': AppColors.noteCategoryColors[9].value},
      'study': {'name': '学习', 'color': AppColors.noteCategoryColors[12].value},
      'ideas': {'name': '想法', 'color': AppColors.noteCategoryColors[6].value},
      'important': {'name': '重要', 'color': AppColors.noteCategoryColors[0].value},
    };
  }

  // 获取笔记的颜色
  int? getNoteColor(String noteId) {
    final colorsJson = _prefs.getString(_noteColorsKey);
    if (colorsJson == null) return null;
    
    try {
      final colors = Map<String, int>.from(jsonDecode(colorsJson));
      return colors[noteId];
    } catch (e) {
      return null;
    }
  }

  // 设置笔记颜色
  Future<void> setNoteColor(String noteId, int? color) async {
    final colorsJson = _prefs.getString(_noteColorsKey);
    Map<String, int> colors = {};
    
    if (colorsJson != null) {
      try {
        colors = Map<String, int>.from(jsonDecode(colorsJson));
      } catch (e) {
        colors = {};
      }
    }
    
    if (color != null) {
      colors[noteId] = color;
    } else {
      colors.remove(noteId);
    }
    
    await _prefs.setString(_noteColorsKey, jsonEncode(colors));
  }

  // 删除笔记颜色
  Future<void> removeNoteColor(String noteId) async {
    final colorsJson = _prefs.getString(_noteColorsKey);
    if (colorsJson == null) return;
    
    try {
      final colors = Map<String, int>.from(jsonDecode(colorsJson));
      colors.remove(noteId);
      await _prefs.setString(_noteColorsKey, jsonEncode(colors));
    } catch (e) {
      // Ignore error
    }
  }

  // 获取所有笔记颜色
  Map<String, int> getAllNoteColors() {
    final colorsJson = _prefs.getString(_noteColorsKey);
    if (colorsJson == null) return {};
    
    try {
      return Map<String, int>.from(jsonDecode(colorsJson));
    } catch (e) {
      return {};
    }
  }

  // 获取默认笔记颜色
  int? get defaultNoteColor => _prefs.getInt(_defaultColorKey);

  // 设置默认笔记颜色
  Future<void> setDefaultNoteColor(int? color) async {
    if (color != null) {
      await _prefs.setInt(_defaultColorKey, color);
    } else {
      await _prefs.remove(_defaultColorKey);
    }
  }

  // 获取颜色预设
  Map<String, Map<String, dynamic>> getColorPresets() {
    final presetsJson = _prefs.getString(_colorPresetsKey);
    if (presetsJson == null) {
      final defaultPresets = _getDefaultColorPresets();
      _prefs.setString(_colorPresetsKey, jsonEncode(defaultPresets));
      return Map<String, Map<String, dynamic>>.from(defaultPresets);
    }
    
    try {
      final presets = Map<String, dynamic>.from(jsonDecode(presetsJson));
      return Map<String, Map<String, dynamic>>.from(
        presets.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value))),
      );
    } catch (e) {
      return Map<String, Map<String, dynamic>>.from(_getDefaultColorPresets());
    }
  }

  // 添加自定义颜色预设
  Future<void> addColorPreset(String id, String name, int color) async {
    final presets = getColorPresets();
    presets[id] = {'name': name, 'color': color};
    await _prefs.setString(_colorPresetsKey, jsonEncode(presets));
  }

  // 删除颜色预设
  Future<void> removeColorPreset(String id) async {
    final presets = getColorPresets();
    presets.remove(id);
    await _prefs.setString(_colorPresetsKey, jsonEncode(presets));
  }

  // 根据标签获取建议颜色
  int? getSuggestedColorForTag(String tag) {
    final presets = getColorPresets();
    final tagLower = tag.toLowerCase();
    
    // 匹配预设分类
    for (final preset in presets.entries) {
      final name = preset.value['name'] as String;
      if (name.toLowerCase().contains(tagLower) || tagLower.contains(name.toLowerCase())) {
        return preset.value['color'] as int;
      }
    }
    
    // 基于标签内容的简单规则
    if (tagLower.contains('工作') || tagLower.contains('work') || tagLower.contains('项目')) {
      return AppColors.noteCategoryColors[4].value; // 靛蓝
    }
    if (tagLower.contains('个人') || tagLower.contains('私人') || tagLower.contains('personal')) {
      return AppColors.noteCategoryColors[9].value; // 绿色
    }
    if (tagLower.contains('学习') || tagLower.contains('study') || tagLower.contains('教育')) {
      return AppColors.noteCategoryColors[12].value; // 黄色
    }
    if (tagLower.contains('想法') || tagLower.contains('创意') || tagLower.contains('idea')) {
      return AppColors.noteCategoryColors[6].value; // 浅蓝
    }
    if (tagLower.contains('重要') || tagLower.contains('urgent') || tagLower.contains('紧急')) {
      return AppColors.noteCategoryColors[0].value; // 红色
    }
    
    return null;
  }

  // 获取颜色使用统计
  Map<int, int> getColorUsageStats() {
    final noteColors = getAllNoteColors();
    final stats = <int, int>{};
    
    for (final color in noteColors.values) {
      stats[color] = (stats[color] ?? 0) + 1;
    }
    
    return stats;
  }

  // 获取最常用的颜色
  List<int> getMostUsedColors({int limit = 5}) {
    final stats = getColorUsageStats();
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedEntries.take(limit).map((e) => e.key).toList();
  }

  // 清除所有笔记颜色
  Future<void> clearAllNoteColors() async {
    await _prefs.remove(_noteColorsKey);
  }

  // 导出颜色设置
  Map<String, dynamic> exportColorSettings() {
    return {
      'note_colors': getAllNoteColors(),
      'default_color': defaultNoteColor,
      'color_presets': getColorPresets(),
    };
  }

  // 导入颜色设置
  Future<void> importColorSettings(Map<String, dynamic> settings) async {
    if (settings.containsKey('note_colors')) {
      final noteColors = Map<String, int>.from(settings['note_colors']);
      await _prefs.setString(_noteColorsKey, jsonEncode(noteColors));
    }
    
    if (settings.containsKey('default_color')) {
      await setDefaultNoteColor(settings['default_color']);
    }
    
    if (settings.containsKey('color_presets')) {
      final presets = Map<String, Map<String, dynamic>>.from(settings['color_presets']);
      await _prefs.setString(_colorPresetsKey, jsonEncode(presets));
    }
  }

  // 重置为默认设置
  Future<void> resetToDefaults() async {
    await _prefs.remove(_noteColorsKey);
    await _prefs.remove(_defaultColorKey);
    await _prefs.remove(_colorPresetsKey);
    _initializeDefaultPresets();
  }

  // 获取新笔记的颜色：默认颜色 > 随机颜色
  int getNewNoteColor() {
    // 检查是否有默认颜色设置
    final defaultColor = this.defaultNoteColor;
    if (defaultColor != null) {
      return defaultColor;
    }
    
    // 从颜色数组中随机选择一个颜色
    const colors = AppColors.noteCategoryColors;
    final randomIndex = DateTime.now().millisecondsSinceEpoch % colors.length;
    return colors[randomIndex].value;
  }
}

// 颜色预设模型
class ColorPreset {
  final String id;
  final String name;
  final int color;

  const ColorPreset({
    required this.id,
    required this.name,
    required this.color,
  });

  factory ColorPreset.fromJson(String id, Map<String, dynamic> json) {
    return ColorPreset(
      id: id,
      name: json['name'] as String,
      color: json['color'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
    };
  }

  Color get colorValue => Color(color);
}