import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameon/core/logging/pii_masker.dart';
import 'package:gameon/features/perfil/models/usuario_deportista.dart';
import 'package:gameon/features/perfil/models/guardar_perfil_request.dart';

void main() {
  test('ITEM 5(a) Enmascara correo, celular y DNI sin dejar originales', () {
    final salida = PiiMasker.mask(
      'cliente ana@correo.com cel 987654321 dni 45678912',
    );
    expect(salida, 'cliente [CORREO] cel [CELULAR] dni [DNI]');
    for (final dato in ['ana@correo.com', '987654321', '45678912']) {
      expect(salida, isNot(contains(dato)));
    }
  });

  test(
    'ITEM 5(b) Entidad a peticion: excluye metadatos y no envia coordenadas',
    () {
      final entidad = UsuarioDeportista(
        id: '123',
        authId: 'auth-no-enviar',
        username: ' ana ',
        nombre: ' Ana ',
        apellidos: ' Perez ',
        telefono: ' 987654321 ',
        fechaNacimiento: DateTime(2000, 5, 10),
        genero: ' femenino ',
        nivelHabilidad: ' principiante ',
        estado: 1,
        createdAt: DateTime(2020),
        deportesFavoritos: ['Tenis'],
      );
      final payload = GuardarPerfilRequest.fromUsuario(entidad).toJson();
      // Verificamos también el JSON serializado que se utiliza como cuerpo.
      final cuerpo = jsonDecode(jsonEncode(payload)) as Map<String, dynamic>;
      expect(cuerpo.keys.toSet(), {
        'username',
        'nombre',
        'apellidos',
        'telefono',
        'fecha_nacimiento',
        'genero',
        'nivel_habilidad',
      });
      expect(cuerpo['username'], 'ana');
      expect(cuerpo['telefono'], '987654321');
      expect(cuerpo['fecha_nacimiento'], '2000-05-10T00:00:00.000');
      for (final excluido in [
        'id',
        'auth_id',
        'estado',
        'creado_en',
        'createdAt',
        'deportesFavoritos',
        'deportes_favoritos',
        'fcm_token',
        'latitud',
        'longitud',
      ]) {
        expect(cuerpo.containsKey(excluido), isFalse, reason: excluido);
      }
      // UsuarioDeportista no lleva coordenadas; no aplica el redondeo a 3 decimales.
    },
  );
}
