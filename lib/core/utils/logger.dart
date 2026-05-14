import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[MediCare] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[MediCare ERROR] $message');
      if (error != null) debugPrint(error.toString());
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[MediCare DEBUG] $message');
    }
  }
}
