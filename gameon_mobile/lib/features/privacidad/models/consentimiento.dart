class Consentimiento {
  static const versionActual = '1.0';

  final bool analitica;
  final bool promociones;
  final String versionPolitica;
  final DateTime fecha;

  const Consentimiento({
    required this.analitica,
    required this.promociones,
    required this.versionPolitica,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
    'analitica': analitica,
    'promociones': promociones,
    'version_politica': versionPolitica,
    'fecha': fecha.toUtc().toIso8601String(),
  };

  factory Consentimiento.fromJson(Map<String, dynamic> json) => Consentimiento(
    analitica: json['analitica'] as bool,
    promociones: json['promociones'] as bool,
    versionPolitica: json['version_politica'] as String,
    fecha: DateTime.parse(json['fecha'] as String),
  );
}
