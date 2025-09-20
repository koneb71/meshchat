import 'package:logger/logger.dart';

class AppLog {
  static final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  static Logger get l => _logger;
}
