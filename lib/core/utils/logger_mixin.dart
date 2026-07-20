import 'package:flutter/foundation.dart';

mixin LoggerMixin on Object {
  void logInfo(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[$runtimeType] INFO: $message');
    }
  }

  void logError(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[$runtimeType] ERROR: $message. Error: $error\n${stackTrace ?? ""}');
    }
  }
}
