import 'package:flutter/foundation.dart';
import '../models/consentimiento.dart';
import '../repositories/consentimiento_repository.dart';

class ConsentimientoViewModel extends ChangeNotifier {
  final ConsentimientoRepository repository;
  Consentimiento? _decision;
  bool guardando = false;
  String? error;

  ConsentimientoViewModel(this.repository);

  Consentimiento? get decision => _decision;
  bool get tieneDecision => _decision != null;
  bool get analitica => _decision?.analitica ?? false;
  bool get promociones => _decision?.promociones ?? false;

  Future<void> cargar() async {
    try {
      _decision = await repository.leer();
    } catch (_) {
      // Si el almacenamiento no se puede leer, no asumimos autorización.
      _decision = null;
    }
    notifyListeners();
  }

  Future<bool> guardar({
    required bool analitica,
    required bool promociones,
  }) async {
    if (guardando) return false;
    guardando = true;
    error = null;
    notifyListeners();
    try {
      final nueva = Consentimiento(
        analitica: analitica,
        promociones: promociones,
        versionPolitica: Consentimiento.versionActual,
        fecha: DateTime.now().toUtc(),
      );
      await repository.guardar(nueva);
      // Solo cambiamos el estado después de confirmar la persistencia.
      _decision = nueva;
      return true;
    } catch (_) {
      error = 'No se pudo guardar tu decisión. Inténtalo nuevamente.';
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }
}
