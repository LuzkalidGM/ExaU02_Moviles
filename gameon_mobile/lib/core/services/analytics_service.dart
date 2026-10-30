import '../../features/privacidad/viewmodels/consentimiento_viewmodel.dart';
import '../logging/app_logger.dart';

abstract interface class AnalyticsService {
  Future<void> track(String evento);
}

/// Implementación local: no envía eventos a proveedores externos.
class LoggingAnalyticsService implements AnalyticsService {
  @override
  Future<void> track(String evento) async {
    AppLogger.log('evento=$evento', name: 'Analytics');
  }
}

/// Consulta el consentimiento actual en cada evento, incluso tras retirarlo.
class ConsentAwareAnalyticsService implements AnalyticsService {
  final ConsentimientoViewModel consentimiento;
  final AnalyticsService destino;

  ConsentAwareAnalyticsService(this.consentimiento, this.destino);

  @override
  Future<void> track(String evento) async {
    if (!consentimiento.analitica) return;
    await destino.track(evento);
  }
}
