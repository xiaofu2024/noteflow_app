import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/services/biometric_auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class BiometricLockPage extends StatefulWidget {
  final VoidCallback onAuthenticated;
  final VoidCallback? onCancel;

  const BiometricLockPage({
    super.key,
    required this.onAuthenticated,
    this.onCancel,
  });

  @override
  State<BiometricLockPage> createState() => _BiometricLockPageState();
}

class _BiometricLockPageState extends State<BiometricLockPage>
    with TickerProviderStateMixin {
  final BiometricAuthService _biometricService = BiometricAuthService();
  
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  late AnimationController _shakeAnimationController;
  late Animation<double> _shakeAnimation;

  BiometricStatus _biometricStatus = BiometricStatus.unknown;
  List<BiometricType> _availableBiometrics = [];
  bool _isAuthenticating = false;
  String _statusMessage = '请验证身份';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricStatus();
    _authenticateOnStart();
  }

  void _initializeAnimations() {
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _shakeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeAnimationController,
        curve: Curves.elasticIn,
      ),
    );

    _pulseAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _shakeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricStatus() async {
    final status = await _biometricService.checkBiometricStatus();
    final biometrics = await _biometricService.getAvailableBiometrics();
    
    setState(() {
      _biometricStatus = status;
      _availableBiometrics = biometrics;
    });
  }

  Future<void> _authenticateOnStart() async {
    // 延迟一下让用户看到界面
    await Future.delayed(const Duration(milliseconds: 500));
    _performAuthentication();
  }

  Future<void> _performAuthentication() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = '正在验证身份...';
    });

    debugPrint('开始生物识别验证');

    final result = await _biometricService.authenticate(
      localizedReason: '请验证身份以访问您的笔记',
      cancelButtonText: '取消',
      fallbackButtonText: '使用密码',
    );

    switch (result) {
      case AuthenticationStatus.authenticated:
        setState(() {
          _statusMessage = '验证成功!';
        });
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onAuthenticated();
        break;
        
      case AuthenticationStatus.canceled:
        setState(() {
          _statusMessage = '验证已取消';
          _isAuthenticating = false;
        });
        if (widget.onCancel != null) {
          widget.onCancel!();
        }
        break;
        
      case AuthenticationStatus.error:
        setState(() {
          _statusMessage = '验证失败，请重试';
          _isAuthenticating = false;
        });
        _shakeAnimationController.forward().then((_) {
          _shakeAnimationController.reset();
        });
        break;
        
      case AuthenticationStatus.timeout:
        setState(() {
          _statusMessage = '验证超时，请重试';
          _isAuthenticating = false;
        });
        break;
        
      case AuthenticationStatus.notAvailable:
        setState(() {
          _statusMessage = '生物识别不可用';
          _isAuthenticating = false;
        });
        break;
        
      case AuthenticationStatus.unknown:
        setState(() {
          _statusMessage = '未知错误，请重试';
          _isAuthenticating = false;
        });
        break;
    }
  }

  Widget _buildBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icon(
        Icons.face_rounded,
        size: 80.sp,
        color: AppColors.primary,
      );
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icon(
        Icons.fingerprint_rounded,
        size: 80.sp,
        color: AppColors.primary,
      );
    } else {
      return Icon(
        Icons.lock_rounded,
        size: 80.sp,
        color: AppColors.primary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // App Logo/Title
              Text(
                'NoteFlow',
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 12.h),
              
              Text(
                '智能笔记管理',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              
              SizedBox(height: 64.h),
              
              // Biometric Icon with Animation
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 120.w,
                            height: 120.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.1),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: _buildBiometricIcon(),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              
              SizedBox(height: 32.h),
              
              // Status Message
              Text(
                _statusMessage,
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 12.h),
              
              // Instruction Text
              if (_biometricStatus == BiometricStatus.available)
                Text(
                  _availableBiometrics.contains(BiometricType.face)
                      ? '将面部对准摄像头进行验证'
                      : '将手指放在指纹传感器上',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              
              const Spacer(),
              
              // Action Buttons
              if (!_isAuthenticating) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _performAuthentication,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('重新验证'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                
                if (widget.onCancel != null) ...[
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: widget.onCancel,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: const Text('跳过验证'),
                    ),
                  ),
                ],
              ] else ...[
                const CircularProgressIndicator(),
              ],
              
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}