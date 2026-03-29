import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/client_pin.dart';
import '../../providers/clientes_provider.dart';
import '../../providers/recomendacoes_provider.dart';
import '../../models/cliente.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Tela de vendas com mapa do Brasil e pins de clientes
class VendasScreen extends ConsumerStatefulWidget {
  const VendasScreen({super.key});

  @override
  ConsumerState<VendasScreen> createState() => _VendasScreenState();
}

class _VendasScreenState extends ConsumerState<VendasScreen> {
  String? _filtroStatus; // null = todos

  static const _statusOptions = [
    (null, 'Todos'),
    ('negociacao', 'Negociação'),
    ('enviado', 'Enviado'),
    ('em_analise', 'Em Análise'),
    ('ativo', 'Ativo'),
    ('inadimplente', 'Inadimplente'),
  ];

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesProvider);
    final recsAsync = ref.watch(recomendacoesProvider);

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
                markers: [
                  // Pins de clientes
                  ...clientesAsync.valueOrNull
                      ?.where((c) =>
                          c.lat != null &&
                          c.lng != null &&
                          (_filtroStatus == null || c.status == _filtroStatus))
                      .map((c) => Marker(
                            width: 120,
                            height: 60,
                            point: LatLng(c.lat!, c.lng!),
                            child: ClientPin(
                              status: c.status,
                              nome: c.nome,
                            ),
                          ))
                      .toList() ?? [],
                  // Pins de recomendações (se filtro null ou 'recomendacao')
                  if (_filtroStatus == null)
                    ...recsAsync.valueOrNull
                        ?.where((r) => r.lat != null && r.lng != null && r.status == 'pendente')
                        .map((r) => Marker(
                              width: 120,
                              height: 60,
                              point: LatLng(r.lat!, r.lng!),
                              child: ClientPin(
                                status: 'recomendacao',
                                nome: r.nomeIndicado,
                              ),
                            ))
                        .toList() ?? [],
                ],
              ),
            ],
          ),
          // Filtros de status
          Positioned(
            top: 16, left: 16,
            child: _StatusFilter(
              selected: _filtroStatus,
              options: _statusOptions,
              onChanged: (s) => setState(() => _filtroStatus = s),
            ),
          ),
          Positioned(
            top: 16, right: 16,
            child: const _MapLegend(),
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

class _StatusFilter extends StatelessWidget {
  final String? selected;
  final List<(String?, String)> options;
  final ValueChanged<String?> onChanged;
  const _StatusFilter({required this.selected, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: DropdownButton<String?>(
          value: selected,
          underline: const SizedBox.shrink(),
          isDense: true,
          items: options
              .map((o) => DropdownMenuItem<String?>(
                    value: o.$1,
                    child: Text(o.$2, style: const TextStyle(fontSize: 13)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

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
