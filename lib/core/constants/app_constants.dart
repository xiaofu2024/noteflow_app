class AppConstants {
  // App Info
  static const String appName = '盛华笔记';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://shl-api.weletter01.com';
  static const String apiVersion = 'v1';

  //上传文件访问地址
  static const String imagebase = "https://shl-api.weletter01.com/assets/文件ID";
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String autoSyncKey = 'auto_sync';
  
  // Database
  static const String databaseName = 'noteflow.db';
  static const int databaseVersion = 1;
  
  // Pagination
  static const int pageSize = 20;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'jpg', 'jpeg', 'png', 'gif', 'webp'
  ];
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Security
  static const int maxPasswordAttempts = 3;
  static const Duration lockoutDuration = Duration(minutes: 5);
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  
  // Spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Icon Sizes
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
}