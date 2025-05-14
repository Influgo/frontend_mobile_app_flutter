import 'package:logger/logger.dart';

class AppLoggerHelper {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
    level: Level.debug,
  );

  static void debug(String message) {
    _logger.d(message);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // _logger.e(message, err: error,  stackTrace: StackTrace.current);
    _logger.e(message, error, stackTrace);
  }
}
