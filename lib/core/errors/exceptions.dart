class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? errors;

  const ValidationException(this.message, [this.errors]);

  @override
  String toString() => 'ValidationException: $message';
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class PermissionException implements Exception {
  final String message;

  const PermissionException(this.message);

  @override
  String toString() => 'PermissionException: $message';
}

class EncryptionException implements Exception {
  final String message;

  const EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}