import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/consentimiento.dart';

abstract interface class ConsentimientoRepository {
  Future<Consentimiento?> leer();
  Future<void> guardar(Consentimiento consentimiento);
}

class PreferenciasConsentimientoRepository implements ConsentimientoRepository {
  static const clave = 'gameon_consentimiento';
  final SharedPreferences preferencias;

  PreferenciasConsentimientoRepository(this.preferencias);

  @override
  Future<Consentimiento?> leer() async {
    final valor = preferencias.getString(clave);
    if (valor == null) return null;
    return Consentimiento.fromJson(jsonDecode(valor) as Map<String, dynamic>);
  }

  @override
  Future<void> guardar(Consentimiento consentimiento) async {
    // Una sola entrada mantiene juntas la decisión, la versión y la fecha.
    final guardado = await preferencias.setString(
      clave,
      jsonEncode(consentimiento.toJson()),
    );
    if (!guardado) throw StateError('No se pudo guardar el consentimiento');
  }
}
