import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // Limit the number of methods displayed
    errorMethodCount: 8, // Limit the number of methods displayed for error logs
    lineLength: 120, // Set the maximum line length
    colors: true, // Enable ANSI color codes in logs (useful for terminals)
  ),
);

final loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);