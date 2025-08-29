import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/vip_config_entity.dart';
import '../../../core/services/vip_manager.dart';
import '../../bloc/subscription/subscription_bloc.dart';
import '../../widgets/vip_product_card.dart';
import '../../widgets/vip_features_list.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final VipManager _vipManager = VipManager();

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(LoadSubscriptionConfig());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('会员中心'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionPurchaseError) {
            // 显示内购失败弹窗
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    const Text('购买失败'),
                  ],
                ),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('确定'),
                  ),
                ],
              ),
            );
          }
        },
        child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is SubscriptionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '加载失败',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SubscriptionBloc>().add(LoadSubscriptionConfig());
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is SubscriptionLoaded || 
                state is SubscriptionPurchaseError ||
                state is SubscriptionPurchasing ||
                state is SubscriptionPurchaseSuccess) {
              VipConfigEntity config;
              if (state is SubscriptionLoaded) {
                config = state.config;
              } else if (state is SubscriptionPurchaseError) {
                config = state.config;
              } else if (state is SubscriptionPurchasing) {
                config = state.config;
              } else if (state is SubscriptionPurchaseSuccess) {
                config = state.config;
              } else {
                return const SizedBox.shrink();
              }
              return _buildSubscriptionContent(config);
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSubscriptionContent(VipConfigEntity config) {
    final currentLevel = _vipManager.getCurrentVipLevel();
    final expireTime = _vipManager.getVipExpireTime();
    final isVipActive = _vipManager.isVipActive;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Status Card
          _buildCurrentStatusCard(currentLevel, expireTime, isVipActive),
          
          const SizedBox(height: 24),
          
          // Features Overview
          const VipFeaturesList(),
          
          const SizedBox(height: 24),
          
          // Subscription Plans
          Text(
            '选择会员套餐',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ...config.goods
              .where((product) => product.level != VipLevel.vipLevel0)
              .map((product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
                      builder: (context, state) {
                        final isPurchasing = state is SubscriptionPurchasing && 
                                           state.config.goods.any((p) => p.productId == product.productId);
                        return VipProductCard(
                          product: product,
                          isCurrentPlan: product.level == currentLevel && isVipActive,
                          isPurchasing: isPurchasing,
                          onPurchase: () => _onPurchaseProduct(product),
                        );
                      },
                    ),
                  )),
          
          const SizedBox(height: 24),
          
          // Restore Purchases Button
          if (isVipActive) ...[
            Center(
              child: TextButton(
                onPressed: _onRestorePurchases,
                child: const Text('恢复购买'),
              ),
            ),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard(
    VipLevel currentLevel,
    DateTime? expireTime,
    bool isVipActive,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isVipActive
              ? [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ]
              : [
                  Colors.grey.shade300,
                  Colors.grey.shade400,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isVipActive ? Icons.diamond : Icons.account_circle,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                currentLevel.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          if (isVipActive && expireTime != null) ...[
            Text(
              '到期时间: ${_formatDate(expireTime)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '剩余 ${expireTime.difference(DateTime.now()).inDays} 天',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else if (!isVipActive) ...[
            const Text(
              '升级会员享受更多功能',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onPurchaseProduct(VipProduct product) {
    context.read<SubscriptionBloc>().add(PurchaseProduct(product.productId));
  }

  void _onRestorePurchases() {
    context.read<SubscriptionBloc>().add(RestorePurchases());
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}