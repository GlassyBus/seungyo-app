import 'dart:developer' as developer;

/// 로그 레벨
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 앱 로거
class AppLogger {
  AppLogger._();

  static const String _name = 'BaseballApp';
  
  /// 디버그 로그
  static void debug(String message) {
    developer.log(message, name: 'DEBUG');
  }
  
  /// 정보 로그
  static void info(String message) {
    developer.log(message, name: 'INFO');
  }
  
  /// 경고 로그
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [WARNING] $message';
    
    developer.log(
      logMessage,
      name: _name,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// 에러 로그
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
