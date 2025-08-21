// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `笔记流`
  String get appTitle {
    return Intl.message('笔记流', name: 'appTitle', desc: '', args: []);
  }

  /// `欢迎使用笔记流`
  String get welcomeMessage {
    return Intl.message('欢迎使用笔记流', name: 'welcomeMessage', desc: '', args: []);
  }

  /// `笔记`
  String get notes {
    return Intl.message('笔记', name: 'notes', desc: '', args: []);
  }

  /// `创建笔记`
  String get createNote {
    return Intl.message('创建笔记', name: 'createNote', desc: '', args: []);
  }

  /// `搜索`
  String get search {
    return Intl.message('搜索', name: 'search', desc: '', args: []);
  }

  /// `设置`
  String get settings {
    return Intl.message('设置', name: 'settings', desc: '', args: []);
  }

  /// `主题`
  String get theme {
    return Intl.message('主题', name: 'theme', desc: '', args: []);
  }

  /// `语言`
  String get language {
    return Intl.message('语言', name: 'language', desc: '', args: []);
  }

  /// `深色模式`
  String get darkMode {
    return Intl.message('深色模式', name: 'darkMode', desc: '', args: []);
  }

  /// `浅色模式`
  String get lightMode {
    return Intl.message('浅色模式', name: 'lightMode', desc: '', args: []);
  }

  /// `保存`
  String get save {
    return Intl.message('保存', name: 'save', desc: '', args: []);
  }

  /// `取消`
  String get cancel {
    return Intl.message('取消', name: 'cancel', desc: '', args: []);
  }

  /// `删除`
  String get delete {
    return Intl.message('删除', name: 'delete', desc: '', args: []);
  }

  /// `编辑`
  String get edit {
    return Intl.message('编辑', name: 'edit', desc: '', args: []);
  }

  /// `标题`
  String get title {
    return Intl.message('标题', name: 'title', desc: '', args: []);
  }

  /// `内容`
  String get content {
    return Intl.message('内容', name: 'content', desc: '', args: []);
  }

  /// `暂无笔记`
  String get emptyNotes {
    return Intl.message('暂无笔记', name: 'emptyNotes', desc: '', args: []);
  }

  /// `创建您的第一个笔记开始使用`
  String get createYourFirstNote {
    return Intl.message(
      '创建您的第一个笔记开始使用',
      name: 'createYourFirstNote',
      desc: '',
      args: [],
    );
  }

  /// `发生错误`
  String get errorOccurred {
    return Intl.message('发生错误', name: 'errorOccurred', desc: '', args: []);
  }

  /// `重试`
  String get tryAgain {
    return Intl.message('重试', name: 'tryAgain', desc: '', args: []);
  }

  /// `无网络连接`
  String get noInternet {
    return Intl.message('无网络连接', name: 'noInternet', desc: '', args: []);
  }

  /// `请检查您的网络连接`
  String get checkConnection {
    return Intl.message(
      '请检查您的网络连接',
      name: 'checkConnection',
      desc: '',
      args: [],
    );
  }

  /// `加载中...`
  String get loading {
    return Intl.message('加载中...', name: 'loading', desc: '', args: []);
  }

  /// `成功`
  String get success {
    return Intl.message('成功', name: 'success', desc: '', args: []);
  }

  /// `笔记保存成功`
  String get noteSaved {
    return Intl.message('笔记保存成功', name: 'noteSaved', desc: '', args: []);
  }

  /// `笔记删除成功`
  String get noteDeleted {
    return Intl.message('笔记删除成功', name: 'noteDeleted', desc: '', args: []);
  }

  /// `确定要删除此笔记吗？`
  String get confirmDelete {
    return Intl.message(
      '确定要删除此笔记吗？',
      name: 'confirmDelete',
      desc: '',
      args: [],
    );
  }

  /// `是`
  String get yes {
    return Intl.message('是', name: 'yes', desc: '', args: []);
  }

  /// `否`
  String get no {
    return Intl.message('否', name: 'no', desc: '', args: []);
  }

  /// `搜索你的笔记...`
  String get searchHint {
    return Intl.message('搜索你的笔记...', name: 'searchHint', desc: '', args: []);
  }

  /// `快捷操作`
  String get quickActions {
    return Intl.message('快捷操作', name: 'quickActions', desc: '', args: []);
  }

  /// `OCR\n扫描`
  String get ocrScan {
    return Intl.message('OCR\n扫描', name: 'ocrScan', desc: '', args: []);
  }

  /// `语音\n笔记`
  String get voiceNote {
    return Intl.message('语音\n笔记', name: 'voiceNote', desc: '', args: []);
  }

  /// `AI\n助手`
  String get aiHelp {
    return Intl.message('AI\n助手', name: 'aiHelp', desc: '', args: []);
  }

  /// `最近搜索`
  String get recentSearches {
    return Intl.message('最近搜索', name: 'recentSearches', desc: '', args: []);
  }

  /// `搜索提示`
  String get searchTips {
    return Intl.message('搜索提示', name: 'searchTips', desc: '', args: []);
  }

  /// `• 通过关键词、标签或内容搜索`
  String get searchTip1 {
    return Intl.message(
      '• 通过关键词、标签或内容搜索',
      name: 'searchTip1',
      desc: '',
      args: [],
    );
  }

  /// `• 使用引号搜索精确短语`
  String get searchTip2 {
    return Intl.message('• 使用引号搜索精确短语', name: 'searchTip2', desc: '', args: []);
  }

  /// `• 按日期搜索：'上周', '昨天`
  String get searchTip3 {
    return Intl.message(
      '• 按日期搜索：\'上周\', \'昨天',
      name: 'searchTip3',
      desc: '',
      args: [],
    );
  }

  /// `• 使用OCR搜索图片中的文字`
  String get searchTip4 {
    return Intl.message(
      '• 使用OCR搜索图片中的文字',
      name: 'searchTip4',
      desc: '',
      args: [],
    );
  }

  /// `未找到笔记`
  String get noNotesFound {
    return Intl.message('未找到笔记', name: 'noNotesFound', desc: '', args: []);
  }

  /// `尝试不同的关键词或创建新笔记`
  String get tryDifferentKeywords {
    return Intl.message(
      '尝试不同的关键词或创建新笔记',
      name: 'tryDifferentKeywords',
      desc: '',
      args: [],
    );
  }

  /// `搜索错误`
  String get searchError {
    return Intl.message('搜索错误', name: 'searchError', desc: '', args: []);
  }

  /// `找到 {count} 条笔记`
  String foundNotes(Object count) {
    return Intl.message(
      '找到 $count 条笔记',
      name: 'foundNotes',
      desc: '',
      args: [count],
    );
  }

  /// `AI助手功能即将推出...`
  String get aiFeatureComingSoon {
    return Intl.message(
      'AI助手功能即将推出...',
      name: 'aiFeatureComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `• 按关键词、标签或内容搜索\n• 使用引号表示精确短语\n'• 按日期搜索：上周、昨天\n• 使用 OCR 搜索图像中的文本`
  String get searchTipsDetails {
    return Intl.message(
      '• 按关键词、标签或内容搜索\n• 使用引号表示精确短语\n\'• 按日期搜索：上周、昨天\n• 使用 OCR 搜索图像中的文本',
      name: 'searchTipsDetails',
      desc: '',
      args: [],
    );
  }

  /// `搜索笔记`
  String get searchNotes {
    return Intl.message('搜索笔记', name: 'searchNotes', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[Locale.fromSubtags(languageCode: 'en')];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
