import 'package:flutter/foundation.dart';

enum LogLevel { info, warning, error, debug }

class AppLogger {
  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    String tag = 'RapidApp',
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    final logLine = '[$timestamp] [$levelStr] [$tag] $message';

    if (kDebugMode) {
      debugPrint(logLine);
      if (error != null) debugPrint('Error detail: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  static void info(String message, {String tag = 'RapidApp'}) =>
      log(message, level: LogLevel.info, tag: tag);

  static void warning(String message, {String tag = 'RapidApp'}) =>
      log(message, level: LogLevel.warning, tag: tag);

  static void error(
    String message, {
    String tag = 'RapidApp',
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(message, level: LogLevel.error, tag: tag, error: error, stackTrace: stackTrace);

  static void debug(String message, {String tag = 'RapidApp'}) =>
      log(message, level: LogLevel.debug, tag: tag);
}
