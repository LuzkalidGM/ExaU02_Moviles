import 'usuario_deportista.dart';

/// Lista explícita de campos editables; no serializa la entidad completa.
class GuardarPerfilRequest {
  final String username;
  final String nombre;
  final String apellidos;
  final String telefono;
  final DateTime? fechaNacimiento;
  final String genero;
  final String nivelHabilidad;
  final String? imagenPerfil;

  const GuardarPerfilRequest({
    required this.username,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    required this.fechaNacimiento,
    required this.genero,
    required this.nivelHabilidad,
    this.imagenPerfil,
  });

  factory GuardarPerfilRequest.fromUsuario(UsuarioDeportista usuario) =>
      GuardarPerfilRequest(
        username: usuario.username.trim(),
        nombre: usuario.nombre.trim(),
        apellidos: usuario.apellidos.trim(),
        telefono: usuario.telefono.trim(),
        fechaNacimiento: usuario.fechaNacimiento,
        genero: usuario.genero.trim(),
        nivelHabilidad: usuario.nivelHabilidad.trim(),
        imagenPerfil: usuario.imagenPerfil?.trim(),
      );

  Map<String, dynamic> toJson() => {
    'username': username,
    'nombre': nombre,
    'apellidos': apellidos,
    'telefono': telefono,
    'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
    'genero': genero,
    'nivel_habilidad': nivelHabilidad,
    // Omitir la imagen ausente conserva el comportamiento del formulario.
    if (imagenPerfil != null && imagenPerfil!.isNotEmpty)
      'imagen_perfil': imagenPerfil,
  };
}
