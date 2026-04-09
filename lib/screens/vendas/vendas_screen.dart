import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/client_pin.dart';
import '../../providers/clientes_provider.dart';
import '../../providers/recomendacoes_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

class VendasScreen extends ConsumerStatefulWidget {
  const VendasScreen({super.key});

  @override
  ConsumerState<VendasScreen> createState() => _VendasScreenState();
}

class _VendasScreenState extends ConsumerState<VendasScreen> {
  final Set<String> _activeFilters = {};

  static const _statusOptions = [
    ('negociacao', 'Negociação', AppColors.info),
    ('enviado', 'Enviado', AppColors.warning),
    ('em_analise', 'Em Análise', AppColors.warning),
    ('ativo', 'Ativo', AppColors.success),
    ('inadimplente', 'Inadimplente', AppColors.danger),
    ('recomendacao', 'Recomendação', AppColors.lilac),
  ];

  bool _clientePassaFiltro(String status) {
    if (_activeFilters.isEmpty) return true;
    return _activeFilters.contains(status);
  }

  void _abrirFiltros() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Filtrar por Status',
                      style:
                          AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setModalState(() {});
                      setState(() => _activeFilters.clear());
                    },
                    child: const Text('Limpar tudo'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._statusOptions.map((opt) {
                final (value, label, color) = opt;
                return CheckboxListTile(
                  value: _activeFilters.contains(value),
                  title: Row(
                    children: [
                      Icon(Icons.circle, color: color, size: 12),
                      const SizedBox(width: AppSpacing.sm),
                      Text(label, style: AppTypography.bodySmall),
                    ],
                  ),
                  onChanged: (checked) {
                    setModalState(() {
                      checked == true
                          ? _activeFilters.add(value)
                          : _activeFilters.remove(value);
                    });
                    setState(() {});
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                );
              }),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesProvider);
    final recsAsync = ref.watch(recomendacoesProvider);
    final hasFilter = _activeFilters.isNotEmpty;

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
                  ...clientesAsync.valueOrNull
                          ?.where((c) =>
                              c.lat != null &&
                              c.lng != null &&
                              _clientePassaFiltro(c.status))
                          .map((c) => Marker(
                                width: 120,
                                height: 60,
                                point: LatLng(c.lat!, c.lng!),
                                child: ClientPin(
                                  status: c.status,
                                  nome: c.nome,
                                  onTap: () => Navigator.pushNamed(
                                      context, AppRoutes.cliente,
                                      arguments: {'clienteId': c.id}),
                                ),
                              ))
                          .toList() ??
                      [],
                  if (_activeFilters.isEmpty ||
                      _activeFilters.contains('recomendacao'))
                    ...recsAsync.valueOrNull
                            ?.where((r) =>
                                r.lat != null &&
                                r.lng != null &&
                                r.status == 'pendente')
                            .map((r) => Marker(
                                  width: 120,
                                  height: 60,
                                  point: LatLng(r.lat!, r.lng!),
                                  child: ClientPin(
                                    status: 'recomendacao',
                                    nome: r.nomeIndicado,
                                    onTap: () => Navigator.pushNamed(
                                        context, AppRoutes.contrato,
                                        arguments: {'clienteId': r.id}),
                                  ),
                                ))
                            .toList() ??
                        [],
                ],
              ),
            ],
          ),
          // Botão flutuante de filtros
          Positioned(
            top: 16,
            left: 16,
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: hasFilter ? AppColors.primary : AppColors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: _abrirFiltros,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune,
                          size: 16,
                          color:
                              hasFilter ? AppColors.white : AppColors.textPrimary),
                      const SizedBox(width: 6),
                      Text(
                        hasFilter
                            ? 'Filtros (${_activeFilters.length})'
                            : '⚙️ Filtros',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              hasFilter ? AppColors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 80,
            right: 16,
            child: _MapLegend(),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.cadastroCliente),
              child: const Icon(Icons.add, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Negociação', AppColors.info),
      ('Contrato Enviado', AppColors.warning),
      ('Ativo', AppColors.success),
      ('Inadimplente', AppColors.danger),
      ('Recomendação', AppColors.lilac),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: item.$2, size: 12),
                        const SizedBox(width: 6),
                        Text(item.$1, style: AppTypography.caption),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
