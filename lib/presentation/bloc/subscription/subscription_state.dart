part of 'subscription_bloc.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final VipConfigEntity config;

  const SubscriptionLoaded(this.config);

  @override
  List<Object> get props => [config];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object> get props => [message];
}

class SubscriptionPurchasing extends SubscriptionState {
  final VipConfigEntity config;

  const SubscriptionPurchasing(this.config);

  @override
  List<Object> get props => [config];
}

class SubscriptionPurchaseSuccess extends SubscriptionState {
  final VipConfigEntity config;

  const SubscriptionPurchaseSuccess(this.config);

  @override
  List<Object> get props => [config];
}

class SubscriptionPurchaseError extends SubscriptionState {
  final VipConfigEntity config;
  final String message;

  const SubscriptionPurchaseError(this.config, this.message);

  @override
  List<Object> get props => [config, message];
}

class SubscriptionRestoring extends SubscriptionState {
  final VipConfigEntity config;

  const SubscriptionRestoring(this.config);

  @override
  List<Object> get props => [config];
}

class SubscriptionRestoreSuccess extends SubscriptionState {
  final VipConfigEntity config;

  const SubscriptionRestoreSuccess(this.config);

  @override
  List<Object> get props => [config];
}