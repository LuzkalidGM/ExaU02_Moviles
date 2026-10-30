import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/consentimiento_viewmodel.dart';

class PrivacidadView extends StatefulWidget {
  final bool desdePerfil;
  const PrivacidadView({super.key, this.desdePerfil = false});

  @override
  State<PrivacidadView> createState() => _PrivacidadViewState();
}

class _PrivacidadViewState extends State<PrivacidadView> {
  late bool _analitica;
  late bool _promociones;

  @override
  void initState() {
    super.initState();
    final vm = context.read<ConsentimientoViewModel>();
    _analitica = vm.analitica;
    _promociones = vm.promociones;
  }

  Future<void> _guardar(bool aceptar) async {
    final guardado = await context.read<ConsentimientoViewModel>().guardar(
      analitica: aceptar && _analitica,
      promociones: aceptar && _promociones,
    );
    if (!mounted) return;
    if (guardado && widget.desdePerfil) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConsentimientoViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidad')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Tú decides cómo usamos tus datos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'Estos usos son opcionales. Puedes rechazarlos y seguir '
              'usando GameOn. Cambia tu decisión desde Perfil > Privacidad.',
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Analítica de uso'),
              subtitle: const Text(
                'Permitir eventos de uso para mejorar GameOn.',
              ),
              value: _analitica,
              onChanged: vm.guardando
                  ? null
                  : (valor) => setState(() => _analitica = valor),
            ),
            SwitchListTile(
              title: const Text('Notificaciones promocionales'),
              subtitle: const Text(
                'Permitir avisos de promociones. Esta elección '
                'es independiente de los avisos de reservas y mensajes.',
              ),
              value: _promociones,
              onChanged: vm.guardando
                  ? null
                  : (valor) => setState(() => _promociones = valor),
            ),
            const SizedBox(height: 24),
            // Ambos botones usan el mismo widget, tamaño y estilo.
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: vm.guardando ? null : () => _guardar(true),
                    child: const Text('Aceptar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: vm.guardando ? null : () => _guardar(false),
                    child: const Text('Rechazar'),
                  ),
                ),
              ],
            ),
            if (vm.guardando) const LinearProgressIndicator(),
            if (vm.error != null) Text(vm.error!),
            const SizedBox(height: 16),
            const Text('Versión de la política: 1.0'),
            if (vm.decision != null)
              Text(
                'Última decisión: ${vm.decision!.fecha.toUtc().toIso8601String()}',
              ),
          ],
        ),
      ),
    );
  }
}
