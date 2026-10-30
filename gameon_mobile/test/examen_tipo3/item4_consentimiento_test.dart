import 'package:flutter_test/flutter_test.dart';
import 'package:gameon/core/services/analytics_service.dart';
import 'package:gameon/features/privacidad/models/consentimiento.dart';
import 'package:gameon/features/privacidad/repositories/consentimiento_repository.dart';
import 'package:gameon/features/privacidad/viewmodels/consentimiento_viewmodel.dart';

// Solo memoria: estas pruebas no usan preferencias, emulador ni red.
class FakeConsentimientoRepository implements ConsentimientoRepository {
  Consentimiento? decision;
  @override
  Future<Consentimiento?> leer() async => decision;
  @override
  Future<void> guardar(Consentimiento valor) async => decision = valor;
}

class FakeAnalytics implements AnalyticsService {
  final eventos = <String>[];
  @override
  Future<void> track(String evento) async => eventos.add(evento);
}

void main() {
  late FakeConsentimientoRepository almacenamiento;
  late FakeAnalytics destino;
  late ConsentimientoViewModel vm;
  late AnalyticsService analytics;

  setUp(() {
    almacenamiento = FakeConsentimientoRepository();
    destino = FakeAnalytics();
    vm = ConsentimientoViewModel(almacenamiento);
    analytics = ConsentAwareAnalyticsService(vm, destino);
    addTearDown(vm.dispose);
  });

  test('ITEM 4(a) Sin decision: ambos usos apagados', () async {
    await vm.cargar();
    expect(vm.tieneDecision, isFalse);
    expect(vm.analitica, isFalse);
    expect(vm.promociones, isFalse);
    await analytics.track('perfil_guardado');
    expect(destino.eventos, isEmpty);
  });

  test('ITEM 4(b) Solo analitica: guarda seleccion y version 1.0', () async {
    await vm.cargar();
    expect(await vm.guardar(analitica: true, promociones: false), isTrue);
    expect(vm.analitica, isTrue);
    expect(vm.promociones, isFalse);
    expect(almacenamiento.decision!.analitica, isTrue);
    expect(almacenamiento.decision!.promociones, isFalse);
    expect(almacenamiento.decision!.versionPolitica, '1.0');
    final reabierto = ConsentimientoViewModel(almacenamiento);
    addTearDown(reabierto.dispose);
    await reabierto.cargar();
    expect(reabierto.analitica, isTrue);
    expect(reabierto.promociones, isFalse);
    expect(reabierto.decision!.versionPolitica, '1.0');
  });

  test('ITEM 4(c) Retirar analitica bloquea el siguiente evento', () async {
    await vm.guardar(analitica: true, promociones: false);
    await analytics.track('perfil_guardado');
    expect(destino.eventos, ['perfil_guardado']);
    expect(await vm.guardar(analitica: false, promociones: false), isTrue);
    expect(almacenamiento.decision!.analitica, isFalse);
    // Se conserva el mismo servicio para detectar decisiones cacheadas.
    await analytics.track('perfil_guardado');
    expect(destino.eventos, ['perfil_guardado']);
  });
}
