part of 'subscription_bloc.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class LoadSubscriptionConfig extends SubscriptionEvent {}

class PurchaseProduct extends SubscriptionEvent {
  final String productId;

  const PurchaseProduct(this.productId);

  @override
  List<Object> get props => [productId];
}

class RestorePurchases extends SubscriptionEvent {}

class UpdateVipStatus extends SubscriptionEvent {
  final VipLevel vipLevel;
  final DateTime? expireTime;

  const UpdateVipStatus({
    required this.vipLevel,
    this.expireTime,
  });

  @override
  List<Object> get props => [vipLevel, expireTime ?? DateTime.now()];
}