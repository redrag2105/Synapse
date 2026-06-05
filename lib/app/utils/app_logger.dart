import 'package:logger/logger.dart';

class AppLogger {
  // 1. PRETTY LOGGER: For Info & Debug (No stack trace, clean UI)
  static final Logger _prettyLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // No stack trace for simple logs
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      levelColors: {
        Level.info: AnsiColor.fg(10),
        Level.debug: AnsiColor.fg(205),
      },
    ),
  );

  // 2. STRICT LOGGER: For Errors & Warnings (With stack trace & file info)
  static final Logger _strictLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Shows the last 2 methods in stack (Who called this?)
      errorMethodCount: 8, // Shows more stack for crashes
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // ===========================================================================
  // METHODS
  // ===========================================================================

  /// 🔵 [DEBUG] Use for variable checks, flow tracing
  /// React Equivalent: console.debug("Val:", val)
  static void d(String message) {
    _prettyLogger.d(message);
  }

  /// 🟢 [INFO] Use for successful events (API success, Screen loaded)
  /// React Equivalent: console.info("Navigated to Home")
  static void i(String message) {
    _prettyLogger.i(message);
  }

  /// 🟡 [WARNING] Use for handled errors (Validation failed, No internet)
  /// React Equivalent: console.warn("User input invalid")
  static void w(String message, [dynamic error]) {
    _strictLogger.w(message, error: error);
  }

  /// 🔴 [ERROR] Use for crashes, API failures, Exceptions
  /// React Equivalent: console.error("API 500", error)
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _strictLogger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 🟣 [FATAL] Use for "This should never happen" scenarios
  static void f(String message, [dynamic error, StackTrace? stackTrace]) {
    _strictLogger.f(message, error: error, stackTrace: stackTrace);
  }
}
