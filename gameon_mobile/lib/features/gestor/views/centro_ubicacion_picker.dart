import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Usa el mismo Google Maps configurado para el mapa del deportista.
/// La coordenada se obtiene del pin; el usuario nunca necesita escribirla.
class CentroUbicacionPicker extends StatefulWidget {
  final LatLng? initialPosition;
  final String initialAddress;

  const CentroUbicacionPicker({
    super.key,
    this.initialPosition,
    required this.initialAddress,
  });

  @override
  State<CentroUbicacionPicker> createState() => _CentroUbicacionPickerState();
}

class _CentroUbicacionPickerState extends State<CentroUbicacionPicker> {
  static const tacna = LatLng(-18.0146, -70.2538);
  final address = TextEditingController();
  GoogleMapController? map;
  LatLng? selected;
  bool searching = false;
  String? message;

  @override
  void initState() {
    super.initState();
    selected = widget.initialPosition;
    address.text = widget.initialAddress;
  }

  @override
  void dispose() {
    address.dispose();
    map?.dispose();
    super.dispose();
  }

  Future<void> searchAddress() async {
    final query = address.text.trim();
    if (query.isEmpty) {
      setState(() => message = 'Escribe la dirección del centro.');
      return;
    }
    setState(() { searching = true; message = null; });
    try {
      final matches = await locationFromAddress('$query, Perú');
      if (!mounted) return;
      if (matches.isEmpty) {
        setState(() => message = 'No se encontró la dirección. Mueve el mapa y toca el lugar exacto.');
        return;
      }
      final point = LatLng(matches.first.latitude, matches.first.longitude);
      setState(() => selected = point);
      await map?.animateCamera(CameraUpdate.newLatLngZoom(point, 16));
    } catch (_) {
      if (mounted) setState(() => message = 'No se encontró la dirección. Puedes tocar el lugar directamente en el mapa.');
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  Future<void> useCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => message = 'Activa la ubicación del teléfono para usar esta opción.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => message = 'Puedes buscar la dirección o marcarla tocando el mapa.');
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      setState(() { selected = point; message = null; });
      await map?.animateCamera(CameraUpdate.newLatLngZoom(point, 17));
    } catch (_) {
      if (mounted) setState(() => message = 'No se pudo obtener tu ubicación. Marca el lugar en el mapa.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ubicación del centro')),
    body: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          Expanded(child: TextField(
            controller: address,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => searchAddress(),
            decoration: const InputDecoration(
              labelText: 'Dirección o lugar',
              hintText: 'Ej. Av. Bolognesi 123, Tacna',
              prefixIcon: Icon(Icons.search),
            ),
          )),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: searching ? null : searchAddress,
            tooltip: 'Buscar dirección',
            icon: const Icon(Icons.arrow_forward),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Expanded(child: Text(
            message ?? (selected == null
                ? 'Busca la dirección o toca el mapa para poner el pin.'
                : 'Pin seleccionado. Puedes tocar otro punto para ajustarlo.'),
            style: Theme.of(context).textTheme.bodySmall,
          )),
          TextButton.icon(
            onPressed: useCurrentLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('Estoy aquí'),
          ),
        ]),
      ),
      const SizedBox(height: 8),
      Expanded(child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition ?? tacna,
          zoom: widget.initialPosition == null ? 13 : 16,
        ),
        onMapCreated: (controller) => map = controller,
        onTap: (point) => setState(() { selected = point; message = null; }),
        markers: selected == null ? {} : {
          Marker(markerId: const MarkerId('centro'), position: selected!),
        },
        myLocationButtonEnabled: false,
      )),
      SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: selected == null ? null : () => Navigator.pop(context, selected),
          icon: const Icon(Icons.check),
          label: const Text('Confirmar ubicación'),
        )),
      )),
    ]),
  );
}
