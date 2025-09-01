import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/vip_config_entity.dart';
import '../../../domain/repositories/vip_repository.dart';
import '../../../core/services/vip_manager.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final VipRepository vipRepository;
  final VipManager vipManager;

  SubscriptionBloc({
    required this.vipRepository,
    required this.vipManager,
  }) : super(SubscriptionInitial()) {
    on<LoadSubscriptionConfig>(_onLoadSubscriptionConfig);
    on<PurchaseProduct>(_onPurchaseProduct);
    on<RestorePurchases>(_onRestorePurchases);
    on<UpdateVipStatus>(_onUpdateVipStatus);
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