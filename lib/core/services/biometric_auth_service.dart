import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

enum BiometricStatus {
  unknown,
  available,
  notAvailable,
  notEnrolled,
}

enum AuthenticationStatus {
  unknown,
  authenticated,
  error,
  canceled,
  timeout,
  notAvailable,
}

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  String? _lastError;

  // 获取最后的错误信息
  String? get lastError => _lastError;

  // 清除错误信息
  void clearError() {
    _lastError = null;
  }

  // 检查设备是否支持生物识别
  Future<bool> get isDeviceSupported async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  // 检查生物识别状态
  Future<BiometricStatus> checkBiometricStatus() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await this.isDeviceSupported;
      
      if (!isDeviceSupported || !isAvailable) {
        return BiometricStatus.notAvailable;
      }

      final List<BiometricType> availableBiometrics = 
          await _localAuth.getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty) {
        return BiometricStatus.notEnrolled;
      }

      return BiometricStatus.available;
    } on PlatformException catch (e) {
      // 如果发生异常，返回未知状态
      debugPrint('Error checking biometric status: ${e.code} - ${e.message}');
      return BiometricStatus.unknown;
    }
  }

  // 获取可用的生物识别类型
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  // 执行生物识别认证
  Future<AuthenticationStatus> authenticate({
    String localizedReason = '请验证身份以访问您的笔记',
    String cancelButtonText = '取消',
    String fallbackButtonText = '使用密码',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool sensitiveTransaction = true,
  }) async {
    try {
      // 清除之前的错误
      _lastError = null;
      
      final BiometricStatus status = await checkBiometricStatus();
      
      if (status == BiometricStatus.notAvailable || 
          status == BiometricStatus.notEnrolled) {
        _lastError = '生物识别不可用或未设置';
        return AuthenticationStatus.notAvailable;
      }

      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
          biometricOnly: true,
        ),
      );

      if (!isAuthenticated) {
        _lastError = '身份验证失败';
      }

      return isAuthenticated 
          ? AuthenticationStatus.authenticated 
          : AuthenticationStatus.error;

    } on PlatformException catch (e) {
      debugPrint('Error during biometric authentication: ${e.code} - ${e.message}');
      _lastError = e.message ?? '认证过程中发生错误: ${e.code}';
      
      switch (e.code) {
        case 'NotAvailable':
        case 'NotEnrolled':
          return AuthenticationStatus.notAvailable;
        case 'UserCancel':
          return AuthenticationStatus.canceled;
        case 'Timeout':
          return AuthenticationStatus.timeout;
        default:
          return AuthenticationStatus.error;
      }
    }
  }

  // 获取生物识别类型的显示名称
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return '指纹识别';
      case BiometricType.iris:
        return '虹膜识别';
      case BiometricType.weak:
        return '弱生物识别';
      case BiometricType.strong:
        return '强生物识别';
    }
  }

  // 获取生物识别状态的描述
  String getBiometricStatusDescription(BiometricStatus status) {
    switch (status) {
      case BiometricStatus.available:
        return '生物识别可用';
      case BiometricStatus.notAvailable:
        return '设备不支持生物识别';
      case BiometricStatus.notEnrolled:
        return '未设置生物识别';
      case BiometricStatus.unknown:
        return '生物识别状态未知';
    }
  }

  // 获取认证状态的描述
  String getAuthenticationStatusDescription(AuthenticationStatus status) {
    switch (status) {
      case AuthenticationStatus.authenticated:
        return '认证成功';
      case AuthenticationStatus.error:
        return '认证失败';
      case AuthenticationStatus.canceled:
        return '用户取消';
      case AuthenticationStatus.timeout:
        return '认证超时';
      case AuthenticationStatus.notAvailable:
        return '生物识别不可用';
      case AuthenticationStatus.unknown:
        return '未知错误';
    }
  }
}