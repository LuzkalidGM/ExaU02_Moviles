import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameon/core/logging/pii_masker.dart';
import 'package:gameon/core/logging/app_logger.dart';

void main() {
  test('Un celular no se confunde con DNI y se respetan límites', () {
    expect(PiiMasker.mask('(987654321), 45678912.'), '([CELULAR]), [DNI].');
    expect(
      PiiMasker.mask('1234567890 abc45678912xyz'),
      '1234567890 abc45678912xyz',
    );
    expect(PiiMasker.mask('https://example.com/foto?token=secreto'), '[URL]');
  });

  test('Logger enmascara mensaje, nombre, error y traza', () {
    final original = debugPrint;
    final lineas = <String>[];
    debugPrint = (String? text, {int? wrapWidth}) {
      lineas.add(text ?? '');
    };
    addTearDown(() => debugPrint = original);
    AppLogger.log(
      'ana@correo.com',
      name: '987654321',
      error: StateError('45678912'),
      stackTrace: StackTrace.fromString('ana@correo.com'),
    );
    final salida = lineas.join();
    expect(salida, contains('[CORREO]'));
    expect(salida, contains('[CELULAR]'));
    expect(salida, contains('[DNI]'));
    expect(salida, isNot(contains('ana@correo.com')));
    expect(salida, isNot(contains('987654321')));
    expect(salida, isNot(contains('45678912')));
  });
}
