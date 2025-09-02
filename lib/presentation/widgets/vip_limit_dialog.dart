import 'package:flutter/material.dart';
import '../../domain/entities/vip_config_entity.dart';
import '../pages/subscription/subscription_page.dart';
import '../bloc/subscription/subscription_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

enum LimitType {
  ocr,
  noteCreate,
  speech,
  ai,
  export,
}

extension LimitTypeExtension on LimitType {
  String get title {
    switch (this) {
      case LimitType.ocr:
        return 'OCR识别次数不足';
      case LimitType.noteCreate:
        return '笔记创建数量不足';
      case LimitType.speech:
        return '语音转文字次数不足';
      case LimitType.ai:
        return 'AI功能次数不足';
      case LimitType.export:
        return '数据导出权限不足';
    }
  }

  String get message {
    switch (this) {
      case LimitType.ocr:
        return '您今日的OCR识别次数已用完，升级会员即可享受更多次数。';
      case LimitType.noteCreate:
        return '您今日的笔记创建数量已达上限，升级会员即可创建更多笔记。';
      case LimitType.speech:
        return '您今日的语音转文字次数已用完，升级会员即可享受更多次数。';
      case LimitType.ai:
        return '您今日的AI功能使用次数已用完，升级会员即可享受更多次数。';
      case LimitType.export:
        return '您当前的会员等级无法使用此导出功能，升级会员即可解锁。';
    }
  }

  IconData get icon {
    switch (this) {
      case LimitType.ocr:
        return Icons.scanner;
      case LimitType.noteCreate:
        return Icons.note_add;
      case LimitType.speech:
        return Icons.mic;
      case LimitType.ai:
        return Icons.smart_toy;
      case LimitType.export:
        return Icons.download;
    }
  }
}

class VipLimitDialog extends StatelessWidget {
  final LimitType limitType;
  final VipLevel? suggestedLevel;

  const VipLimitDialog({
    super.key,
    required this.limitType,
    this.suggestedLevel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and Title
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                limitType.icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              limitType.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              limitType.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (suggestedLevel != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '建议升级至: ${suggestedLevel!.displayName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '稍后再说',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _navigateToSubscription(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      '升级会员',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSubscription(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GetIt.instance<SubscriptionBloc>(),
          child: const SubscriptionPage(),
        ),
      ),
    );
  }

  /// 显示限额弹窗的静态方法
  static Future<void> show({
    required BuildContext context,
    required LimitType limitType,
    VipLevel? suggestedLevel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => VipLimitDialog(
        limitType: limitType,
        suggestedLevel: suggestedLevel,
      ),
    );
  }

  /// 检查OCR限制并显示弹窗
  static Future<bool> checkOcrLimit(
    BuildContext context,
    bool canUse,
  ) async {
    if (!canUse) {
      await show(
        context: context,
        limitType: LimitType.ocr,
        suggestedLevel: VipLevel.vipLevel1,
      );
      return false;
    }
    return true;
  }

  /// 检查笔记创建限制并显示弹窗
  static Future<bool> checkNoteCreateLimit(
    BuildContext context,
    bool canUse,
  ) async {
    if (!canUse) {
      await show(
        context: context,
        limitType: LimitType.noteCreate,
        suggestedLevel: VipLevel.vipLevel1,
      );
      return false;
    }
    return true;
  }

  /// 检查语音转文字限制并显示弹窗
  static Future<bool> checkSpeechLimit(
    BuildContext context,
    bool canUse,
  ) async {
    if (!canUse) {
      await show(
        context: context,
        limitType: LimitType.speech,
        suggestedLevel: VipLevel.vipLevel1,
      );
      return false;
    }
    return true;
  }

  /// 检查AI功能限制并显示弹窗
  static Future<bool> checkAiLimit(
    BuildContext context,
    bool canUse,
  ) async {
    if (!canUse) {
      await show(
        context: context,
        limitType: LimitType.ai,
        suggestedLevel: VipLevel.vipLevel1,
      );
      return false;
    }
    return true;
  }

  /// 检查导出权限并显示弹窗
  static Future<bool> checkExportLimit(
    BuildContext context,
    bool canExport,
    {VipLevel? suggestedLevel}
  ) async {
    if (!canExport) {
      await show(
        context: context,
        limitType: LimitType.export,
        suggestedLevel: suggestedLevel ?? VipLevel.vipLevel2,
      );
      return false;
    }
    return true;
  }
}