// ignore_for_file: avoid-banned-types

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger? _log = kDebugMode ? Logger(printer: PrettyPrinter(methodCount: 0)) : null;

  static final Logger? _simpleLog = kDebugMode
      ? Logger(printer: PrettyPrinter(noBoxingByDefault: true, methodCount: 0))
      : null;

  /// Log a message at level [Level.trace].
  static void verbose(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _simpleLog?.t(message, error: error, stackTrace: stackTrace);
  }

  /// Log a message at level [Level.debug].
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log?.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log a message at level [Level.info].
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log?.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a message at level [Level.warning].
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log?.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log a message at level [Level.error].
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _log?.e(message, error: error, stackTrace: stackTrace);
  }
}
