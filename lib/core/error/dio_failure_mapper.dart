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
        ? 'Требуется авторизация'
        : 'Сервис временно недоступен',
  ),
  DioExceptionType.cancel => const NetworkFailure('Запрос отменён'),
  DioExceptionType.badCertificate ||
  DioExceptionType.unknown => const UnknownFailure(),
};
