import 'package:dio/dio.dart';
import 'failure.dart';

Failure mapDioException(DioException exception) => switch (exception.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout ||
  DioExceptionType.transformTimeout => const TimeoutFailure(),
  DioExceptionType.connectionError => const NetworkFailure(),
  DioExceptionType.badResponse => ServerFailure(
    exception.response?.statusCode == 401
        ? 'Authorization required'
        : 'Service temporarily unavailable',
  ),
  DioExceptionType.cancel => const NetworkFailure('Request cancelled'),
  DioExceptionType.badCertificate ||
  DioExceptionType.unknown => const UnknownFailure(),
};
