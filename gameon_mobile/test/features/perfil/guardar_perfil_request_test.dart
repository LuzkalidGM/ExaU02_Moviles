import 'package:flutter_test/flutter_test.dart';
import 'package:gameon/features/perfil/models/usuario_deportista.dart';
import 'package:gameon/features/perfil/models/guardar_perfil_request.dart';

void main() {
  UsuarioDeportista usuario({String? imagen}) => UsuarioDeportista(
    id: '123',
    authId: 'identificador-auth-no-enviar',
    username: ' ana ',
    nombre: ' Ana ',
    apellidos: ' Perez ',
    telefono: ' 987654321 ',
    fechaNacimiento: DateTime(2000, 5, 10),
    genero: ' femenino ',
    nivelHabilidad: ' principiante ',
    estado: 1,
    imagenPerfil: imagen,
    createdAt: DateTime(2020),
    deportesFavoritos: ['Tenis'],
  );

  test('Solo incluye imagen cuando hay una URL no vacía', () {
    expect(
      GuardarPerfilRequest.fromUsuario(
        usuario(imagen: '   '),
      ).toJson().containsKey('imagen_perfil'),
      isFalse,
    );
    expect(
      GuardarPerfilRequest.fromUsuario(
        usuario(imagen: ' https://example.com/foto.jpg '),
      ).toJson()['imagen_perfil'],
      'https://example.com/foto.jpg',
    );
  });
}
