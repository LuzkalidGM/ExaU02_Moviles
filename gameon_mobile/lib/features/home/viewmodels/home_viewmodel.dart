import 'package:gameon/core/logging/app_logger.dart';
import 'package:gameon/features/home/models/institucion_deportiva.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ViewModel encargado de la lógica para obtener instalaciones deportivas
class HomeViewModel {
  // Obtiene la lista de instalaciones deportivas activas desde Supabase
  Future<List<InstitucionDeportiva>> fetchInstituciones() async {
    final client = Supabase.instance.client;

    // Log de sesión / autenticación
    final session = client.auth.currentSession;
    AppLogger.log(
      'fetchInstituciones: iniciando. Authenticated=${session != null} userId=${session?.user.id}',
      name: 'HomeViewModel',
    );

    try {
      AppLogger.log(
        'fetchInstituciones: ejecutando query instituciones_deportivas (estado=1)...',
        name: 'HomeViewModel',
      );

      // Realiza la consulta a la tabla 'instituciones_deportivas' filtrando por estado = 1
      final data = await client
          .from('instituciones_deportivas')
          .select()
          .eq('estado', 1);

      AppLogger.log(
        'fetchInstituciones: respuesta raw tipo=${data.runtimeType} tamaño=${data.length}',
        name: 'HomeViewModel',
      );

      // Convierte la respuesta en una lista de objetos InstitucionDeportiva
      final lista = (data as List)
          .map((json) => InstitucionDeportiva.fromJson(json))
          .toList();

      AppLogger.log(
        'fetchInstituciones: mapeo completado. Registros=${lista.length}',
        name: 'HomeViewModel',
      );

      return lista;
    } on PostgrestException catch (e, st) {
      // Logs detallados de la excepción de Postgrest (RLS / permisos / sintaxis)
      AppLogger.log(
        'PostgrestException al consultar instituciones. code=${e.code} message=${e.message} details=${e.details} hint=${e.hint}',
        name: 'HomeViewModel',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow; // Permite que la UI lo capture y muestre
    } catch (e, st) {
      AppLogger.log(
        'Error inesperado al consultar instituciones: $e',
        name: 'HomeViewModel',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      rethrow;
    } finally {
      AppLogger.log('fetchInstituciones: finalizado', name: 'HomeViewModel');
    }
  }
}
