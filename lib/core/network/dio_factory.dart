import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl.isEmpty ? 'https://localhost.invalid' : apiBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
  return dio;
}
