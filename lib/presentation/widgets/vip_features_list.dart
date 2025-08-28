import 'package:flutter/material.dart';

class VipFeaturesList extends StatelessWidget {
  const VipFeaturesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VIP特权一览',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          const _FeatureItem(
            icon: '📷',
            title: 'OCR文字识别',
            description: '将图片中的文字快速识别并转换为可编辑文本',
          ),
          
          const SizedBox(height: 12),
          
          const _FeatureItem(
            icon: '📝',
            title: '无限笔记创建',
            description: '无限制创建和管理您的笔记内容',
          ),
          
          const SizedBox(height: 12),
          
          const _FeatureItem(
            icon: '🎤',
            title: '语音转文字',
            description: '将语音录音自动转换为文字笔记',
          ),
          
          const SizedBox(height: 12),
          
          const _FeatureItem(
            icon: '📤',
            title: '数据导出',
            description: '将笔记和设置导出为多种格式',
          ),
          
          const SizedBox(height: 12),
          
          const _FeatureItem(
            icon: '🎨',
            title: '笔记模板',
            description: '使用精美的笔记模板快速创建内容',
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}