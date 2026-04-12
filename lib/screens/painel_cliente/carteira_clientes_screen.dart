import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/client_pin.dart';
import '../../routes/app_routes.dart';
import '../../providers/clientes_provider.dart';
import '../../models/cliente.dart';
import '../../theme/theme.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class CarteiraClientesScreen extends ConsumerWidget {
  const CarteiraClientesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientesAsync = ref.watch(clientesProvider);

    return AppScaffold(
      currentRoute: AppRoutes.carteiraClientes,
      child: clientesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Erro ao carregar clientes: $e'),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.read(clientesProvider.notifier).refresh(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (clientes) => _CarteiraMap(clientes: clientes),
      ),
    );
  }
}

class _CarteiraMap extends StatefulWidget {
  final List<Cliente> clientes;
  const _CarteiraMap({required this.clientes});

  @override
  State<_CarteiraMap> createState() => _CarteiraMapState();
}

class _CarteiraMapState extends State<_CarteiraMap> {
  String _filtroStatus = 'Todos';

  static const _statusOptions = [
    'Todos',
    'Negociação',
    'Enviado',
    'Ativo',
    'Inadimplente',
  ];

  static const _statusMap = {
    'Negociação': 'negociacao',
    'Enviado': 'enviado',
    'Ativo': 'ativo',
    'Inadimplente': 'inadimplente',
  };

  List<Cliente> get _todosClientesFiltrados {
    if (_filtroStatus == 'Todos') return widget.clientes;
    final apiStatus = _statusMap[_filtroStatus];
    return widget.clientes.where((c) => c.status == apiStatus).toList();
  }

  List<Cliente> get _clientesNoMapa {
    return _todosClientesFiltrados.where((c) => c.lat != null && c.lng != null).toList();
  }

  List<Cliente> get _clientesSemCoordenadas {
    return _todosClientesFiltrados.where((c) => c.lat == null || c.lng == null).toList();
  }

  @override
  Widget build(BuildContext context) {
    final noMapa = _clientesNoMapa;
    final semCoord = _clientesSemCoordenadas;
    final total = _todosClientesFiltrados.length;

    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(-15.7801, -47.9292),
            initialZoom: 4.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.liveshop.app',
            ),
            MarkerLayer(
              markers: noMapa
                  .map((c) => Marker(
                        point: LatLng(c.lat!, c.lng!),
                        width: 80,
                        height: 60,
                        child: ClientPin(status: c.status, nome: c.nome),
                      ))
                  .toList(),
            ),
          ],
        ),
        // Header com filtro
        Positioned(
          top: AppSpacing.lg,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          child: Row(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_alt_rounded,
                          size: 18, color: context.colors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Carteira de Clientes',
                        style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.colors.primaryLightBg,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Text(
                          '$total',
                          style: AppTypography.caption.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filtroStatus,
                      items: _statusOptions
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s,
                                    style: AppTypography.bodySmall),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _filtroStatus = v ?? 'Todos'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Lista de clientes sem coordenadas
        if (semCoord.isNotEmpty)
          Positioned(
            bottom: AppSpacing.x2l,
            left: AppSpacing.lg,
            child: Card(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280, maxHeight: 200),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sem localização (${semCoord.length})',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: semCoord.length,
                          itemBuilder: (_, i) {
                            final c = semCoord[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Icon(Icons.person_outline,
                                      size: 14, color: _statusColor(c.status, context)),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      c.nome,
                                      style: AppTypography.caption,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    c.status.toUpperCase(),
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 9,
                                      color: _statusColor(c.status, context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // Legenda
        Positioned(
          bottom: AppSpacing.x2l,
          right: AppSpacing.lg,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendItem(color: context.colors.info, label: 'Negociação'),
                  const SizedBox(height: AppSpacing.xs),
                  _LegendItem(color: context.colors.warning, label: 'Enviado'),
                  const SizedBox(height: AppSpacing.xs),
                  _LegendItem(color: context.colors.success, label: 'Ativo'),
                  const SizedBox(height: AppSpacing.xs),
                  _LegendItem(color: context.colors.error, label: 'Inadimplente'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status, BuildContext context) => switch (status) {
    'negociacao' => context.colors.info,
    'enviado' => context.colors.warning,
    'ativo' => context.colors.success,
    'inadimplente' => context.colors.error,
    _ => context.colors.textTertiary,
  };
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: color, size: 16),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }
}
