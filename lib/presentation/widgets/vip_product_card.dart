import 'package:flutter/material.dart';
import '../../domain/entities/vip_config_entity.dart';

class VipProductCard extends StatelessWidget {
  final VipProduct product;
  final bool isCurrentPlan;
  final VoidCallback onPurchase;

  const VipProductCard({
    Key? key,
    required this.product,
    required this.isCurrentPlan,
    required this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRecommended = product.level == VipLevel.vipLevel2;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isRecommended 
              ? theme.colorScheme.primary 
              : theme.dividerColor,
          width: isRecommended ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: const Text(
                '推荐',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.level.displayName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.periodText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.priceText,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (product.period > 0)
                          Text(
                            '/${product.period}天',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Features
                _buildFeatureList(theme),
                
                const SizedBox(height: 20),
                
                // Purchase Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan ? null : onPurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan 
                          ? Colors.grey 
                          : theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isCurrentPlan ? '当前套餐' : '立即购买',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(ThemeData theme) {
    final features = <String>[];
    
    // OCR
    if (product.isUnlimited) {
      features.add('📷 无限制OCR识别');
    } else {
      features.add('📷 OCR识别 ${product.ocrLimit}次/天');
    }
    
    // Notes
    if (product.hasUnlimitedNotes) {
      features.add('📝 无限制创建笔记');
    } else {
      features.add('📝 创建笔记 ${product.noteCreateLimit}个/天');
    }
    
    // Speech
    if (product.hasUnlimitedSpeech) {
      features.add('🎤 无限制语音转文字');
    } else {
      features.add('🎤 语音转文字 ${product.speechLimit}次/天');
    }
    
    // AI (currently ignored in MD file)
    // Export
    features.add('📤 ${product.exportData.displayName}');
    
    // Templates (currently ignored in MD file)
    
    return Column(
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      feature,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}