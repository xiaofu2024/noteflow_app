import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list.
///
/// For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project's Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'笔记流'**
  String get appName;

  /// No description provided for @appSlogan.
  ///
  /// In zh, this message translates to:
  /// **'随心记录，畅享思维'**
  String get appSlogan;

  /// No description provided for @goodMorning.
  ///
  /// In zh, this message translates to:
  /// **'早上好！☀️'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In zh, this message translates to:
  /// **'下午好！☀️'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In zh, this message translates to:
  /// **'晚上好！🌙'**
  String get goodEvening;

  /// No description provided for @notes.
  ///
  /// In zh, this message translates to:
  /// **'笔记'**
  String get notes;

  /// No description provided for @calendar.
  ///
  /// In zh, this message translates to:
  /// **'日历'**
  String get calendar;

  /// No description provided for @search.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @newNote.
  ///
  /// In zh, this message translates to:
  /// **'新建笔记'**
  String get newNote;

  /// No description provided for @pinned.
  ///
  /// In zh, this message translates to:
  /// **'已置顶'**
  String get pinned;

  /// No description provided for @recentNotes.
  ///
  /// In zh, this message translates to:
  /// **'最近笔记'**
  String get recentNotes;

  /// No description provided for @filterAndSort.
  ///
  /// In zh, this message translates to:
  /// **'筛选和排序'**
  String get filterAndSort;

  /// No description provided for @recentlyModified.
  ///
  /// In zh, this message translates to:
  /// **'最近修改'**
  String get recentlyModified;

  /// No description provided for @createdDate.
  ///
  /// In zh, this message translates to:
  /// **'创建日期'**
  String get createdDate;

  /// No description provided for @byTags.
  ///
  /// In zh, this message translates to:
  /// **'按标签'**
  String get byTags;

  /// No description provided for @createNewNote.
  ///
  /// In zh, this message translates to:
  /// **'创建新笔记 - 待办：导航到编辑器'**
  String get createNewNote;

  /// No description provided for @pageNotFound.
  ///
  /// In zh, this message translates to:
  /// **'页面未找到'**
  String get pageNotFound;

  /// No description provided for @pageNotFoundError.
  ///
  /// In zh, this message translates to:
  /// **'404 - 页面未找到'**
  String get pageNotFoundError;

  /// No description provided for @pageNotFoundMessage.
  ///
  /// In zh, this message translates to:
  /// **'您要查找的页面不存在。'**
  String get pageNotFoundMessage;

  /// No description provided for @securityPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'🔒 安全与隐私'**
  String get securityPrivacy;

  /// No description provided for @biometricLock.
  ///
  /// In zh, this message translates to:
  /// **'生物识别锁'**
  String get biometricLock;

  /// No description provided for @biometricLockDesc.
  ///
  /// In zh, this message translates to:
  /// **'使用指纹或面容ID解锁'**
  String get biometricLockDesc;

  /// No description provided for @notePasswords.
  ///
  /// In zh, this message translates to:
  /// **'笔记密码'**
  String get notePasswords;

  /// No description provided for @notePasswordsDesc.
  ///
  /// In zh, this message translates to:
  /// **'管理受密码保护的笔记'**
  String get notePasswordsDesc;

  /// No description provided for @dataExport.
  ///
  /// In zh, this message translates to:
  /// **'数据导出'**
  String get dataExport;

  /// No description provided for @dataExportDesc.
  ///
  /// In zh, this message translates to:
  /// **'导出您的笔记和数据'**
  String get dataExportDesc;

  /// No description provided for @appearance.
  ///
  /// In zh, this message translates to:
  /// **'🎨 外观'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get theme;

  /// No description provided for @noteColors.
  ///
  /// In zh, this message translates to:
  /// **'笔记颜色'**
  String get noteColors;

  /// No description provided for @noteColorsDesc.
  ///
  /// In zh, this message translates to:
  /// **'自定义笔记分类颜色'**
  String get noteColorsDesc;

  /// No description provided for @fontSettings.
  ///
  /// In zh, this message translates to:
  /// **'字体设置'**
  String get fontSettings;

  /// No description provided for @fontSettingsDesc.
  ///
  /// In zh, this message translates to:
  /// **'调整字体大小和字体'**
  String get fontSettingsDesc;

  /// No description provided for @syncBackup.
  ///
  /// In zh, this message translates to:
  /// **'☁️ 同步与备份'**
  String get syncBackup;

  /// No description provided for @cloudSync.
  ///
  /// In zh, this message translates to:
  /// **'云同步'**
  String get cloudSync;

  /// No description provided for @cloudSyncDesc.
  ///
  /// In zh, this message translates to:
  /// **'自动跨设备同步'**
  String get cloudSyncDesc;

  /// No description provided for @backupNow.
  ///
  /// In zh, this message translates to:
  /// **'立即备份'**
  String get backupNow;

  /// No description provided for @backupNowDesc.
  ///
  /// In zh, this message translates to:
  /// **'手动备份您的数据'**
  String get backupNowDesc;

  /// No description provided for @storageUsage.
  ///
  /// In zh, this message translates to:
  /// **'存储使用情况'**
  String get storageUsage;

  /// No description provided for @storageUsageDesc.
  ///
  /// In zh, this message translates to:
  /// **'查看存储和使用详情'**
  String get storageUsageDesc;

  /// No description provided for @notifications.
  ///
  /// In zh, this message translates to:
  /// **'🔔 通知'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In zh, this message translates to:
  /// **'推送通知'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsDesc.
  ///
  /// In zh, this message translates to:
  /// **'接收提醒和更新'**
  String get pushNotificationsDesc;

  /// No description provided for @reminderSettings.
  ///
  /// In zh, this message translates to:
  /// **'提醒设置'**
  String get reminderSettings;

  /// No description provided for @reminderSettingsDesc.
  ///
  /// In zh, this message translates to:
  /// **'配置笔记提醒'**
  String get reminderSettingsDesc;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'📱 关于'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In zh, this message translates to:
  /// **'应用版本'**
  String get appVersion;

  /// No description provided for @privacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDesc.
  ///
  /// In zh, this message translates to:
  /// **'查看我们的隐私政策'**
  String get privacyPolicyDesc;

  /// No description provided for @termsOfService.
  ///
  /// In zh, this message translates to:
  /// **'服务条款'**
  String get termsOfService;

  /// No description provided for @termsOfServiceDesc.
  ///
  /// In zh, this message translates to:
  /// **'查看条款和条件'**
  String get termsOfServiceDesc;

  /// No description provided for @contactSupport.
  ///
  /// In zh, this message translates to:
  /// **'联系支持'**
  String get contactSupport;

  /// No description provided for @contactSupportDesc.
  ///
  /// In zh, this message translates to:
  /// **'获取帮助和报告问题'**
  String get contactSupportDesc;

  /// No description provided for @rateApp.
  ///
  /// In zh, this message translates to:
  /// **'评价应用'**
  String get rateApp;

  /// No description provided for @rateAppDesc.
  ///
  /// In zh, this message translates to:
  /// **'在应用商店给我们评分'**
  String get rateAppDesc;

  /// No description provided for @chooseTheme.
  ///
  /// In zh, this message translates to:
  /// **'选择主题'**
  String get chooseTheme;

  /// No description provided for @system.
  ///
  /// In zh, this message translates to:
  /// **'系统'**
  String get system;

  /// No description provided for @light.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get dark;

  /// No description provided for @backupStarted.
  ///
  /// In zh, this message translates to:
  /// **'备份已开始...'**
  String get backupStarted;

  /// No description provided for @searchNotes.
  ///
  /// In zh, this message translates to:
  /// **'搜索笔记'**
  String get searchNotes;

  /// No description provided for @searchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索标题、内容或标签...'**
  String get searchHint;

  /// No description provided for @noResultsFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到结果'**
  String get noResultsFound;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In zh, this message translates to:
  /// **'尝试使用不同的关键词'**
  String get tryDifferentKeywords;

  /// No description provided for @todaySchedule.
  ///
  /// In zh, this message translates to:
  /// **'今日日程'**
  String get todaySchedule;

  /// No description provided for @noEventsToday.
  ///
  /// In zh, this message translates to:
  /// **'今天没有活动'**
  String get noEventsToday;

  /// No description provided for @addEvent.
  ///
  /// In zh, this message translates to:
  /// **'添加活动'**
  String get addEvent;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}