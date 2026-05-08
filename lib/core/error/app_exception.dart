sealed class AppException implements Exception {
  AppException({
    required this.code,
    this.technical,
    this.cause,
    this.stack,
  });

  final String code;
  final String? technical;
  final Object? cause;
  final StackTrace? stack;

  @override
  // ignore: no_runtimetype_tostring
  String toString() => '$runtimeType($code)';
}

final class NetworkException extends AppException {
  NetworkException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class AuthException extends AppException {
  AuthException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class EntitlementException extends AppException {
  EntitlementException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class SyncException extends AppException {
  SyncException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class StorageException extends AppException {
  StorageException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class ContentException extends AppException {
  ContentException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class ValidationException extends AppException {
  ValidationException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}

final class IntegrityException extends AppException {
  IntegrityException({
    required super.code,
    super.technical,
    super.cause,
    super.stack,
  });
}
