import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, success, warning, error, log }

// AppLogger.debug("LoginScreen", "UserAction", "User clicked login button");
// AppLogger.success("LoginScreen", "LoginStatus", "User logged in successfully");

class AppLogger {
  static const String _tag = "AppLogger";

  /// Log function with manual caller name
  static void log(
    String caller,
    String key,
    dynamic value, {
    LogLevel level = LogLevel.info,
  }) {
    if (kDebugMode) {
      final logPrefix = _getLogPrefix(level);
      final logPrefixIcon = _getLogPrefixIcons(level);
      debugPrint("[$_tag-$logPrefix] $logPrefixIcon [$caller] $key = $value");
    }
  }

  static void debug(String caller, String key, [dynamic value]) {
    log(caller, key, value, level: LogLevel.debug);
  }

  static void info(String caller, String key, [dynamic value]) {
    log(caller, key, value, level: LogLevel.info);
  }

  static void success(String caller, String key, [dynamic value]) {
    log(caller, key, value, level: LogLevel.success);
  }

  static void warning(String caller, String key, [dynamic value]) {
    log(caller, key, value, level: LogLevel.warning);
  }

  static void error(String caller, String key, [dynamic value]) {
    log(caller, key, value, level: LogLevel.error);
  }

  /// Returns an icon prefix based on log level
  static String _getLogPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return "DEBUG";
      case LogLevel.info:
        return "INFO";
      case LogLevel.success:
        return "SUCCESS";
      case LogLevel.warning:
        return "WARNING";
      case LogLevel.error:
        return "ERROR";
      default:
        return "LOG"; // Default log icon
    }
  }

  /// Returns an icon prefix based on log level
  static String _getLogPrefixIcons(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return "💻";
      case LogLevel.info:
        return "ℹ️";
      case LogLevel.success:
        return "✅";
      case LogLevel.warning:
        return "⚠️";
      case LogLevel.error:
        return "❌";
      default:
        return "📝"; // Default log icon
    }
  }
}
