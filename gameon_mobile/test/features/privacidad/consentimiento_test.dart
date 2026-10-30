import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gameon/features/privacidad/models/consentimiento.dart';
import 'package:gameon/features/privacidad/repositories/consentimiento_repository.dart';
import 'package:gameon/features/privacidad/viewmodels/consentimiento_viewmodel.dart';
import 'package:gameon/features/privacidad/views/privacidad_view.dart';

class FakeConsentimientoRepository implements ConsentimientoRepository {
  Consentimiento? valor;
  bool falla = false;

  @override
  Future<Consentimiento?> leer() async => valor;

  @override
  Future<void> guardar(Consentimiento consentimiento) async {
    if (falla) throw StateError('Almacenamiento no disponible');
    valor = consentimiento;
  }
}

void main() {
  test(
    'Fallo de escritura no convierte la selección en consentimiento',
    () async {
      final repository = FakeConsentimientoRepository()..falla = true;
      final vm = ConsentimientoViewModel(repository);
      expect(await vm.guardar(analitica: true, promociones: true), isFalse);
      expect(vm.tieneDecision, isFalse);
      expect(vm.analitica, isFalse);
      expect(vm.guardando, isFalse);
      expect(vm.error, isNotNull);
    },
  );

  test(
    'Preferencias conserva también el rechazo y la fecha ISO 8601',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = PreferenciasConsentimientoRepository(prefs);
      final decision = Consentimiento(
        analitica: false,
        promociones: false,
        versionPolitica: '1.0',
        fecha: DateTime.utc(2026, 10, 30),
      );
      await repository.guardar(decision);
      final leido = await repository.leer();
      expect(leido!.analitica, isFalse);
      expect(leido.promociones, isFalse);
      expect(leido.versionPolitica, '1.0');
      expect(leido.fecha, decision.fecha);
      expect(
        prefs.getString(PreferenciasConsentimientoRepository.clave),
        contains('2026-10-30T00:00:00.000Z'),
      );
    },
  );

  testWidgets('Reabre la decisión y Rechazar desactiva ambos usos', (
    tester,
  ) async {
    final repository = FakeConsentimientoRepository();
    final vm = ConsentimientoViewModel(repository);
    await vm.guardar(analitica: true, promociones: true);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: const MaterialApp(home: PrivacidadView()),
      ),
    );
    final switches = tester.widgetList<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(switches.every((item) => item.value), isTrue);
    final aceptar = find.widgetWithText(OutlinedButton, 'Aceptar');
    final rechazar = find.widgetWithText(OutlinedButton, 'Rechazar');
    expect(tester.getSize(aceptar), tester.getSize(rechazar));
    await tester.tap(rechazar);
    await tester.pumpAndSettle();
    expect(repository.valor!.analitica, isFalse);
    expect(repository.valor!.promociones, isFalse);
  });
}
