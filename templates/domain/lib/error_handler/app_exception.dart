 class AppException implements Exception {
  final String message;

  AppException(
    this.message,
  );

  @override
  String toString() => message;

  factory AppException.unknown() => AppException('Unknown Error!');
}
