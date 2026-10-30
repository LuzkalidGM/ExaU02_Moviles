import 'package:flutter/foundation.dart';
import 'pii_masker.dart';

class AppLogger {
  AppLogger._();

  static void log(
    Object? message, {
    String name = 'GameOn',
    Object? error,
    StackTrace? stackTrace,
    int level = 0,
  }) {
    final contenido = StringBuffer('[$name] $message');
    if (error != null) contenido.write(' | $error');
    if (stackTrace != null) contenido.write('\n$stackTrace');
    // Se enmascara también el nombre, el error y la traza, no solo el mensaje.
    debugPrint('[GameOn] ${PiiMasker.mask(contenido.toString())}');
  }
}
