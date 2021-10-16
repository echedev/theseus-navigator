// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';

class Log {
  static int _logLevel = 0;

  static set logLevel(LogLevel value) =>
      _logLevel = LogLevel.values.indexOf(value);

  static void d(Object tag, [String? message]) {
    if (kDebugMode || _logLevel == LogLevel.values.indexOf(LogLevel.d)) {
      _write(LogLevel.d, tag, message);
    }
  }

  static void e(Object tag, [String? message]) {
    if (_logLevel <= LogLevel.values.indexOf(LogLevel.e)) {
      _write(LogLevel.e, tag, message);
    }
  }

  static void w(Object tag, [String? message]) {
    if (_logLevel <= LogLevel.values.indexOf(LogLevel.w)) {
      _write(LogLevel.w, tag, message);
    }
  }

  static void i(Object tag, [String? message]) {
    if (_logLevel <= LogLevel.values.indexOf(LogLevel.i)) {
      _write(LogLevel.i, tag, message);
    }
  }

  static void _write(LogLevel type, Object tag, String? message) {
    // ignore: avoid_print
    print('''${type.toStringFormatted()}, 
      ${DateTime.now()}, ${_tagToString(tag)}: ${message ?? ""}''');
  }

  static String _tagToString(Object tag) =>
      tag is String ? tag : tag.toString();
}

enum LogLevel { d, e, w, i }

extension _LogTypeExtension on LogLevel {
  String toStringFormatted() => '[${toString().split('.').last.toUpperCase()}]';
}
