import 'package:gameon/core/logging/app_logger.dart';
import '../models/usuario_deportista.dart';
import '../models/guardar_perfil_request.dart';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditPerfilViewModel extends ChangeNotifier {
  List<String> deportesDisponibles = [];
  bool loadingDeportes = false;
  String? deportesError;

  final List<String> _fallbackDeportes = const [
    'Fútbol',
    'Basketball',
    'Tenis',
    'Volleyball',
    'Natación',
    'Ciclismo',
    'Running',
    'Gym',
  ];

  Future<void> loadDeportes() async {
    loadingDeportes = true;
    deportesError = null;
    notifyListeners();
    try {
      final supabase = Supabase.instance.client;
      final List<dynamic> rows = await supabase
          .from('deportes')
          .select('nombre')
          .order('nombre');

      final nombres = rows
          .map((e) => (e['nombre'] as String?)?.trim() ?? '')
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList();

      deportesDisponibles = nombres.isNotEmpty
          ? nombres
          : List<String>.from(_fallbackDeportes);
    } catch (e) {
      deportesError = 'No se pudo cargar deportes';
      deportesDisponibles = List<String>.from(_fallbackDeportes);
    } finally {
      loadingDeportes = false;
      notifyListeners();
    }
  }

  /// Crea o actualiza el registro del usuario deportista y devuelve su `id`.
  Future<SavePerfilResult> upsertUsuarioDeportista(
    UsuarioDeportista usuario,
  ) async {
    final supabase = Supabase.instance.client;
    final authUser = supabase.auth.currentUser;
    if (authUser == null) {
      return SavePerfilResult.error('Inicia sesión para guardar tu perfil.');
    }
    final id = int.tryParse(usuario.id);
    final request = GuardarPerfilRequest.fromUsuario(usuario);
    final payload = request.toJson();
    try {
      final exists = await supabase
          .from('usuarios_deportistas')
          .select('id')
          .eq('username', request.username)
          .maybeSingle();
      if (exists != null) {
        final existingId = exists['id'] as int?;
        if (existingId != null && existingId != id) {
          return SavePerfilResult.error(
            'El nombre de usuario ya existe. Elige otro.',
          );
        }
      }
      if (id != null && id > 0) {
        final res = await supabase
            .from('usuarios_deportistas')
            .update(payload)
            .eq('id', id)
            .select('id')
            .single();
        return SavePerfilResult.success(res['id'] as int);
      } else {
        final res = await supabase
            .from('usuarios_deportistas')
            .upsert({...payload, 'auth_id': authUser.id}, onConflict: 'auth_id')
            .select('id')
            .single();
        return SavePerfilResult.success(res['id'] as int);
      }
    } on PostgrestException catch (e) {
      final m = e.message.toLowerCase();
      if (e.code == '23505' ||
          m.contains('duplicate key') ||
          m.contains('unique') ||
          m.contains('usuarios_deportistas_username')) {
        return SavePerfilResult.error(
          'El nombre de usuario ya existe. Elige otro.',
        );
      }
      return SavePerfilResult.error('Error BD: ${e.message}');
    } catch (e) {
      return SavePerfilResult.error('Error al guardar perfil: $e');
    }
  }

  /// Sube bytes de imagen a Firebase Storage en la carpeta `profile_images/`.
  /// Devuelve la URL pública (download URL) o `null` si falla.
  Future<String?> uploadProfileImage(Uint8List data, String filename) async {
    try {
      AppLogger.log(
        '📤 Iniciando subida de imagen: $filename (${data.length} bytes)',
      );
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(filename);

      final meta = SettableMetadata(contentType: 'image/jpeg');
      AppLogger.log('📤 Subiendo datos a Storage...');
      await ref.putData(data, meta);
      AppLogger.log('✅ Imagen subida, obteniendo URL...');
      // Obtener la URL de descarga
      final url = await ref.getDownloadURL();
      AppLogger.log('✅ URL obtenida: $url');
      return url;
    } catch (e, stackTrace) {
      AppLogger.log('❌ Error al subir imagen: $e');
      AppLogger.log('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> saveDeportesFavoritos(
    int usuarioId,
    List<String> deportesSeleccionados,
  ) async {
    try {
      final supabase = Supabase.instance.client;

      // Eliminar deportes existentes
      await supabase
          .from('usuarios_deportes')
          .delete()
          .eq('usuario_id', usuarioId);

      // Obtener IDs de los deportes seleccionados
      final seleccion = deportesSeleccionados
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (seleccion.isEmpty) {
        return;
      }

      // Construir filtro IN correcto con valores entre comillas
      final inValues = '(${seleccion.map((e) => '"$e"').join(',')})';

      final deportesIds = await supabase
          .from('deportes')
          .select('id, nombre')
          .filter('nombre', 'in', inValues);

      final inserts = deportesIds
          .map(
            (deporte) => {'usuario_id': usuarioId, 'deporte_id': deporte['id']},
          )
          .toList();

      // Insertar nuevos deportes
      if (inserts.isNotEmpty) {
        await supabase.from('usuarios_deportes').insert(inserts);
      }
    } catch (e) {
      throw Exception('Error al guardar deportes favoritos: $e');
    }
  }
}

class SavePerfilResult {
  final bool ok;
  final int? usuarioId;
  final String? message;
  SavePerfilResult._(this.ok, this.usuarioId, this.message);
  factory SavePerfilResult.success(int id) =>
      SavePerfilResult._(true, id, null);
  factory SavePerfilResult.error(String msg) =>
      SavePerfilResult._(false, null, msg);
}
