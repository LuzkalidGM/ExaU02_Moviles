/// Reglas compartidas por todos los logs propios de GameOn.
class PiiMasker {
  PiiMasker._();

  static final _email = RegExp(
    r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
    caseSensitive: false,
  );
  // Los límites impiden tratar nueve dígitos como un DNI de ocho.
  static final _celular = RegExp(r'\b\d{9}\b');
  static final _dni = RegExp(r'\b\d{8}\b');
  static final _url = RegExp(r'https?://[^\s]+');

  static String mask(String texto) {
    return texto
        .replaceAll(_email, '[CORREO]')
        .replaceAll(_celular, '[CELULAR]')
        .replaceAll(_dni, '[DNI]')
        // Las URLs de fotos y pagos pueden incluir tokens de acceso.
        .replaceAll(_url, '[URL]');
  }
}
