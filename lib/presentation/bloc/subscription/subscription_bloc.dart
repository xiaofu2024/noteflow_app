import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../domain/entities/vip_config_entity.dart';
import '../../../domain/repositories/vip_repository.dart';
import '../../../core/services/vip_manager.dart';
import '../../../core/services/iap_service.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final VipRepository vipRepository;
  final VipManager vipManager;
  final IAPService iapService;

  SubscriptionBloc({
    required this.vipRepository,
    required this.vipManager,
    required this.iapService,
  }) : super(SubscriptionInitial()) {
    on<LoadSubscriptionConfig>(_onLoadSubscriptionConfig);
    on<PurchaseProduct>(_onPurchaseProduct);
    on<RestorePurchases>(_onRestorePurchases);
    on<UpdateVipStatus>(_onUpdateVipStatus);
    
    // 设置IAP回调
    _setupIAPCallbacks();
  }

  void _setupIAPCallbacks() {
    // 设置购买成功回调
    iapService.onPurchaseSuccess = (PurchaseDetails purchase) {
      _handlePurchaseSuccess(purchase);
    };
    
    // 设置恢复成功回调
    iapService.onPurchaseRestored = (PurchaseDetails purchase) {
      _handlePurchaseSuccess(purchase); // 恢复也按成功处理
    };
    
    // 设置购买错误回调
    iapService.onPurchaseError = (PurchaseDetails purchase, String error) {
      // 可以在这里处理错误，暂时不需要特殊处理
    };
  }

  void _handlePurchaseSuccess(PurchaseDetails purchase) {
    // 根据产品ID获取VIP等级
    final vipLevel = iapService.getVipLevelByProductId(purchase.productID);
    if (vipLevel != null) {
      // 获取产品配置以确定有效期
      final product = iapService.getProductById(purchase.productID);
      if (product != null) {
        // 根据产品ID设置相应的VIP等级和有效期
        int durationDays;
        switch (purchase.productID) {
          case 'com.shenghua.note.vip1': // VIP 1 - 假设30天
            durationDays = 30;
            break;
          case 'com.shenghua.note.vip2': // VIP 2 - 假设90天
            durationDays = 30;
            break;
          case 'com.shenghua.note.vip3': // VIP 3 - 假设365天
            durationDays = 16;
            break;
          default:
            durationDays = 30; // 默认30天
        }
        
        // 更新VIP状态
        vipManager.setVipLevel(vipLevel, durationDays: durationDays);
        
        // 发送状态更新事件以刷新UI
        add(UpdateVipStatus(vipLevel: vipLevel, expireTime: DateTime.now().add(Duration(days: durationDays))));
      }
    }
  }

  Future<void> _onLoadSubscriptionConfig(
    LoadSubscriptionConfig event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    final result = await vipRepository.getIapConfig();
    
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (config) {
        vipManager.updateVipConfig(config);
        emit(SubscriptionLoaded(config));
      },
    );
  }

  Future<void> _onPurchaseProduct(
    PurchaseProduct event,
    Emitter<SubscriptionState> emit,
  ) async {
    // 检查是否有配置可用
    late VipConfigEntity config;
    if (state is SubscriptionLoaded) {
      config = (state as SubscriptionLoaded).config;
    } else if (state is SubscriptionPurchaseError) {
      config = (state as SubscriptionPurchaseError).config;
    } else if (state is SubscriptionPurchaseSuccess) {
      config = (state as SubscriptionPurchaseSuccess).config;
    } else {
      return;
    }
    
    emit(SubscriptionPurchasing(config));

    final result = await vipRepository.purchaseProduct(event.productId);
    
    result.fold(
      (failure) => emit(SubscriptionPurchaseError(
        config,
        failure.message,
      )),
      (success) {
        if (success) {
          emit(SubscriptionPurchaseSuccess(config));
        } else {
          emit(SubscriptionPurchaseError(
            config,
            'Purchase failed ${event.productId}',
          ));
        }
      },
    );
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<SubscriptionState> emit,
  ) async {
    // 获取当前配置，支持更多状态类型
    VipConfigEntity? config;
    
    if (state is SubscriptionLoaded) {
      config = (state as SubscriptionLoaded).config;
    } else if (state is SubscriptionPurchaseError) {
      config = (state as SubscriptionPurchaseError).config;
    } else if (state is SubscriptionPurchaseSuccess) {
      config = (state as SubscriptionPurchaseSuccess).config;
    } else if (state is SubscriptionRestoreSuccess) {
      config = (state as SubscriptionRestoreSuccess).config;
    } else if (state is SubscriptionPurchasing) {
      config = (state as SubscriptionPurchasing).config;
    } else {
      // 如果没有配置，直接返回错误
      emit(const SubscriptionError('无法获取配置信息，请重新加载'));
      return;
    }
    
    emit(SubscriptionRestoring(config!));

    final result = await vipRepository.restorePurchases();
    
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (_) => emit(SubscriptionRestoreSuccess(config!)),
    );
  }

  void _onUpdateVipStatus(
    UpdateVipStatus event,
    Emitter<SubscriptionState> emit,
  ) {
    if (state is SubscriptionLoaded) {
      final currentState = state as SubscriptionLoaded;
      emit(SubscriptionLoaded(currentState.config));
    }
  }
}