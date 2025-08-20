import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isEmailVerified;
  final UserPreferences preferences;
  final UserSubscription? subscription;

  const UserEntity({
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

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    UserPreferences? preferences,
    UserSubscription? subscription,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferences: preferences ?? this.preferences,
      subscription: subscription ?? this.subscription,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        avatarUrl,
        createdAt,
        lastLoginAt,
        isEmailVerified,
        preferences,
        subscription,
      ];

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
  bool get isPremium => subscription?.isActive ?? false;
  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
  }
}

class UserPreferences extends Equatable {
  final UserThemeMode themeMode;
  final String language;
  final bool biometricEnabled;
  final bool autoSyncEnabled;
  final bool notificationsEnabled;
  final int defaultNoteColor;
  final String defaultFont;
  final double fontSize;
  final bool showPreviewInList;
  final bool confirmBeforeDelete;

  const UserPreferences({
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

  UserPreferences copyWith({
    UserThemeMode? themeMode,
    String? language,
    bool? biometricEnabled,
    bool? autoSyncEnabled,
    bool? notificationsEnabled,
    int? defaultNoteColor,
    String? defaultFont,
    double? fontSize,
    bool? showPreviewInList,
    bool? confirmBeforeDelete,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultNoteColor: defaultNoteColor ?? this.defaultNoteColor,
      defaultFont: defaultFont ?? this.defaultFont,
      fontSize: fontSize ?? this.fontSize,
      showPreviewInList: showPreviewInList ?? this.showPreviewInList,
      confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
    );
  }

  static const UserPreferences defaultPreferences = UserPreferences(
    themeMode: UserThemeMode.system,
    language: 'en',
    biometricEnabled: false,
    autoSyncEnabled: true,
    notificationsEnabled: true,
    defaultNoteColor: 0xFFFFFFFF,
    defaultFont: 'Inter',
    fontSize: 16.0,
    showPreviewInList: true,
    confirmBeforeDelete: true,
  );

  @override
  List<Object?> get props => [
        themeMode,
        language,
        biometricEnabled,
        autoSyncEnabled,
        notificationsEnabled,
        defaultNoteColor,
        defaultFont,
        fontSize,
        showPreviewInList,
        confirmBeforeDelete,
      ];
}

enum UserThemeMode { light, dark, system }

class UserSubscription extends Equatable {
  final String id;
  final SubscriptionType type;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool autoRenew;

  const UserSubscription({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.autoRenew,
  });

  UserSubscription copyWith({
    String? id,
    SubscriptionType? type,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? autoRenew,
  }) {
    return UserSubscription(
      id: id ?? this.id,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        startDate,
        endDate,
        isActive,
        autoRenew,
      ];

  bool get isExpired => DateTime.now().isAfter(endDate);
  Duration get timeRemaining => endDate.difference(DateTime.now());
}

enum SubscriptionType { free, pro, premium }