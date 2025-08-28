import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(String message, [this.statusCode]) : super(message);

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure(String message, [this.errors]) : super(message);

  @override
  List<Object> get props => [message, errors ?? {}];
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}

class EncryptionFailure extends Failure {
  const EncryptionFailure(String message) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unknown error occurred']) : super(message);
}

class PurchaseFailure extends Failure {
  const PurchaseFailure(String message) : super(message);
}