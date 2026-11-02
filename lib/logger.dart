import "dart:io";

import "package:logger/logger.dart";

final Logger logger = Logger(
  level: Platform.environment.containsKey("FLUTTER_TEST") ? Level.off : null,
  printer: PrettyPrinter(
    colors: true,
    printEmojis: false,
    lineLength: 80,

    methodCount: 0,
    errorMethodCount: 5,
    noBoxingByDefault: true,
  ),
);
