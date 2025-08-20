import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isEmailVerified;
  final UserPreferencesModel preferences;
  final UserSubscriptionModel? subscription;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
    required this.lastLoginAt,
    required this.isEmailVerified,
    required this.preferences,
    this.subscription,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      lastLoginAt: DateTime.fromMillisecondsSinceEpoch(json['last_login_at'] as int),
      isEmailVerified: json['is_email_verified'] as bool,
      preferences: UserPreferencesModel.fromJson(json['preferences'] as Map<String, dynamic>),
      subscription: json['subscription'] != null 
          ? UserSubscriptionModel.fromJson(json['subscription'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_login_at': lastLoginAt.millisecondsSinceEpoch,
      'is_email_verified': isEmailVerified,
      'preferences': preferences.toJson(),
      'subscription': subscription?.toJson(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      isEmailVerified: isEmailVerified,
      preferences: preferences.toEntity(),
      subscription: subscription?.toEntity(),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      avatarUrl: entity.avatarUrl,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      isEmailVerified: entity.isEmailVerified,
      preferences: UserPreferencesModel.fromEntity(entity.preferences),
      subscription: entity.subscription != null
          ? UserSubscriptionModel.fromEntity(entity.subscription!)
          : null,
    );
  }
}

class UserPreferencesModel {
  final String themeMode;
  final String language;
  final bool biometricEnabled;
  final bool autoSyncEnabled;
  final bool notificationsEnabled;
  final int defaultNoteColor;
  final String defaultFont;
  final double fontSize;
  final bool showPreviewInList;
  final bool confirmBeforeDelete;

  const UserPreferencesModel({
    required this.themeMode,
    required this.language,
    required this.biometricEnabled,
    required this.autoSyncEnabled,
    required this.notificationsEnabled,
    required this.defaultNoteColor,
    required this.defaultFont,
    required this.fontSize,
    required this.showPreviewInList,
    required this.confirmBeforeDelete,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      themeMode: json['theme_mode'] as String,
      language: json['language'] as String,
      biometricEnabled: json['biometric_enabled'] as bool,
      autoSyncEnabled: json['auto_sync_enabled'] as bool,
      notificationsEnabled: json['notifications_enabled'] as bool,
      defaultNoteColor: json['default_note_color'] as int,
      defaultFont: json['default_font'] as String,
      fontSize: (json['font_size'] as num).toDouble(),
      showPreviewInList: json['show_preview_in_list'] as bool,
      confirmBeforeDelete: json['confirm_before_delete'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme_mode': themeMode,
      'language': language,
      'biometric_enabled': biometricEnabled,
      'auto_sync_enabled': autoSyncEnabled,
      'notifications_enabled': notificationsEnabled,
      'default_note_color': defaultNoteColor,
      'default_font': defaultFont,
      'font_size': fontSize,
      'show_preview_in_list': showPreviewInList,
      'confirm_before_delete': confirmBeforeDelete,
    };
  }

  UserPreferences toEntity() {
    UserThemeMode parsedThemeMode;
    switch (themeMode.toLowerCase()) {
      case 'light':
        parsedThemeMode = UserThemeMode.light;
        break;
      case 'dark':
        parsedThemeMode = UserThemeMode.dark;
        break;
      default:
        parsedThemeMode = UserThemeMode.system;
    }

    return UserPreferences(
      themeMode: parsedThemeMode,
      language: language,
      biometricEnabled: biometricEnabled,
      autoSyncEnabled: autoSyncEnabled,
      notificationsEnabled: notificationsEnabled,
      defaultNoteColor: defaultNoteColor,
      defaultFont: defaultFont,
      fontSize: fontSize,
      showPreviewInList: showPreviewInList,
      confirmBeforeDelete: confirmBeforeDelete,
    );
  }

  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    String themeModeString;
    switch (entity.themeMode) {
      case UserThemeMode.light:
        themeModeString = 'light';
        break;
      case UserThemeMode.dark:
        themeModeString = 'dark';
        break;
      case UserThemeMode.system:
        themeModeString = 'system';
        break;
    }

    return UserPreferencesModel(
      themeMode: themeModeString,
      language: entity.language,
      biometricEnabled: entity.biometricEnabled,
      autoSyncEnabled: entity.autoSyncEnabled,
      notificationsEnabled: entity.notificationsEnabled,
      defaultNoteColor: entity.defaultNoteColor,
      defaultFont: entity.defaultFont,
      fontSize: entity.fontSize,
      showPreviewInList: entity.showPreviewInList,
      confirmBeforeDelete: entity.confirmBeforeDelete,
    );
  }
}

class UserSubscriptionModel {
  final String id;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool autoRenew;

  const UserSubscriptionModel({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.autoRenew,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(json['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(json['end_date'] as int),
      isActive: json['is_active'] as bool,
      autoRenew: json['auto_renew'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'is_active': isActive,
      'auto_renew': autoRenew,
    };
  }

  UserSubscription toEntity() {
    SubscriptionType parsedType;
    switch (type.toLowerCase()) {
      case 'pro':
        parsedType = SubscriptionType.pro;
        break;
      case 'premium':
        parsedType = SubscriptionType.premium;
        break;
      default:
        parsedType = SubscriptionType.free;
    }

    return UserSubscription(
      id: id,
      type: parsedType,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      autoRenew: autoRenew,
    );
  }

  factory UserSubscriptionModel.fromEntity(UserSubscription entity) {
    String typeString;
    switch (entity.type) {
      case SubscriptionType.pro:
        typeString = 'pro';
        break;
      case SubscriptionType.premium:
        typeString = 'premium';
        break;
      case SubscriptionType.free:
        typeString = 'free';
        break;
    }

    return UserSubscriptionModel(
      id: entity.id,
      type: typeString,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
      autoRenew: entity.autoRenew,
    );
  }
}