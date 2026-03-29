import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/app_scaffold.dart';
import '../../routes/app_routes.dart';

class CarteiraClientesScreen extends StatelessWidget {
  const CarteiraClientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.carteiraClientes,
      child: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(-23.5505, -46.6333),
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.liveshop',
              ),
              const MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(-23.5505, -46.6333),
                    width: 40,
                    height: 40,
                    child:
                        Icon(Icons.location_on, color: Colors.green, size: 40),
                  ),
                ],
              ),
            ],
          ),
          const Positioned(
            top: 20,
            left: 20,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Carteira de Clientes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
