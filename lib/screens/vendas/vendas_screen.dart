import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/client_pin.dart';
import '../../mock/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Tela de vendas com mapa do Brasil e pins de clientes
class VendasScreen extends StatelessWidget {
  const VendasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.vendas,
      child: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(-15.0, -55.0),
              initialZoom: 4.5,
              minZoom: 3.5,
              maxZoom: 10,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.liveshop.saas',
              ),
              MarkerLayer(
                markers: mockClientes.map((c) => Marker(
                  width: 120,
                  height: 60,
                  point: LatLng(c['lat'] as double, c['lng'] as double),
                  child: ClientPin(
                    status: c['status'] as String,
                    nome:   c['nome'] as String,
                  ),
                )).toList(),
              ),
            ],
          ),
          Positioned(
            top: 16, right: 16,
            child: _MapLegend(),
          ),
          Positioned(
            bottom: 24, right: 24,
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.cadastroCliente),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      ('Negociação',       AppColors.info),
      ('Contrato Enviado', AppColors.warning),
      ('Ativo',            AppColors.success),
      ('Inadimplente',     AppColors.danger),
      ('Recomendação',     AppColors.lilac),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: item.$2, size: 12),
                const SizedBox(width: 6),
                Text(item.$1, style: const TextStyle(fontSize: 12)),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}
