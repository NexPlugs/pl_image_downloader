import 'package:flutter/foundation.dart';

/// LogLevel is an enum that represents the level of the log
enum LogLevel { info, debug, error }

/// Logger is a singleton class that provides a method to log messages
final class Logger {
  Logger._();

  static void log(
    Object tag,
    String message, {
    LogLevel level = LogLevel.info,
  }) {
    if (kReleaseMode || kProfileMode) return;

    final String tagStr = switch (tag) {
      final String s => s,
      final Type t => t.toString(),
      _ => tag.runtimeType.toString(),
    };
    debugPrint('${level.name.toUpperCase()} $tagStr: $message');
  }

  static void i(Object tag, String message) =>
      log(tag, message, level: LogLevel.info);

  static void d(Object tag, String message) =>
      log(tag, message, level: LogLevel.debug);

  static void e(Object tag, String message) =>
      log(tag, message, level: LogLevel.error);
}
