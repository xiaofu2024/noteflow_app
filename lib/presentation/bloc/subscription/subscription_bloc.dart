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
    if (state is! SubscriptionLoaded) return;
    
    final currentState = state as SubscriptionLoaded;
    emit(SubscriptionPurchasing(currentState.config));

    final result = await vipRepository.purchaseProduct(event.productId);
    
    result.fold(
      (failure) => emit(SubscriptionPurchaseError(
        currentState.config,
        failure.message,
      )),
      (success) {
        if (success) {
          emit(SubscriptionPurchaseSuccess(currentState.config));
        } else {
          emit(SubscriptionPurchaseError(
            currentState.config,
            'Purchase failed',
          ));
        }
      },
    );
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state is! SubscriptionLoaded) return;
    
    final currentState = state as SubscriptionLoaded;
    emit(SubscriptionRestoring(currentState.config));

    final result = await vipRepository.restorePurchases();
    
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (_) => emit(SubscriptionRestoreSuccess(currentState.config)),
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