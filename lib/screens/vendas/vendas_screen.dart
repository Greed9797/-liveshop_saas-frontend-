import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../models/cliente.dart';
import '../../providers/clientes_provider.dart';
import '../../routes/app_routes.dart';
import '../../design_system/design_system.dart';
import '../../services/api_service.dart';
import '../../widgets/client_avatar.dart';
import '../../widgets/kpi_strip.dart';

class VendasScreen extends ConsumerStatefulWidget {
  const VendasScreen({super.key});

  @override
  ConsumerState<VendasScreen> createState() => _VendasScreenState();
}

enum _VendasView { lista, mapa }

class _VendasScreenState extends ConsumerState<VendasScreen> {
  _VendasView _view = _VendasView.lista;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(clientesProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesProvider);

    final allClientes = clientesAsync.valueOrNull ?? [];
    final openPipeline = allClientes
        .where((c) => c.status == 'negociacao' || c.status == 'enviado')
        .length;
    final pipelineValue = allClientes
        .where((c) => c.status == 'negociacao' || c.status == 'enviado')
        .fold(0.0, (sum, c) => sum + (c.horasContratadas ?? 0) * 100);
    final activeContracts =
        allClientes.where((c) => c.status == 'ativo').length;
    final conversionRate = allClientes.isNotEmpty
        ? ((activeContracts / allClientes.length) * 100).toStringAsFixed(1)
        : '0';

    final brl = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return AppScreenScaffold(
      currentRoute: AppRoutes.comercial,
      title: 'Comercial',
      eyebrow: 'Pipeline comercial',
      titleSerif: true,
      subtitle: 'Gerencie oportunidades, contratos e clientes em negociação.',
      child: Column(
        children: [
          // KPI strip
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.x4, AppSpacing.x4, AppSpacing.x4, 0),
            child: KpiStrip(
              items: [
                KpiStripItem(
                  label: 'Pipeline aberto',
                  value: '$openPipeline',
                  sub: 'negociações',
                  accentTop: true,
                ),
                KpiStripItem(
                  label: 'Valor pipeline',
                  value: brl.format(pipelineValue),
                  sub: 'em potencial',
                  valueColor: AppColors.success,
                ),
                KpiStripItem(
                  label: 'Contratos ativos',
                  value: '$activeContracts',
                  sub: 'clientes',
                ),
                KpiStripItem(
                  label: 'Taxa conversão',
                  value: '$conversionRate%',
                  sub: 'closed won',
                ),
              ],
              accentIndex: 0,
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          // Switcher Lista / Mapa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4),
            child: Row(
              children: [
                _ViewToggle(
                  value: _view,
                  onChanged: (v) => setState(() => _view = v),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          // Conteúdo dinâmico
          Expanded(
            child: _view == _VendasView.lista
                ? _VendasListTab(
                    onAddCliente: () =>
                        Navigator.pushNamed(context, AppRoutes.cadastroCliente),
                  )
                : _VendasMapaTab(
                    clientes: allClientes,
                    onAddCliente: () =>
                        Navigator.pushNamed(context, AppRoutes.cadastroCliente),
                  ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Toggle Lista ↔ Mapa
// ──────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  final _VendasView value;
  final ValueChanged<_VendasView> onChanged;

  const _ViewToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.bgMuted,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: Icons.view_list_rounded,
            label: 'Lista',
            active: value == _VendasView.lista,
            onTap: () => onChanged(_VendasView.lista),
          ),
          _ToggleButton(
            icon: Icons.map_rounded,
            label: 'Mapa',
            active: value == _VendasView.mapa,
            onTap: () => onChanged(_VendasView.mapa),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.bgCard : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.full),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: active ? AppColors.textPrimary : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Lista de clientes/contratos
// ──────────────────────────────────────────────

class _VendasListTab extends ConsumerStatefulWidget {
  final VoidCallback onAddCliente;

  const _VendasListTab({required this.onAddCliente});

  @override
  ConsumerState<_VendasListTab> createState() => _VendasListTabState();
}

class _VendasListTabState extends ConsumerState<_VendasListTab> {
  final Set<String> _activeFilters = {};

  static const _statusOptions = [
    ('negociacao', 'Negociação', AppColors.warning),
    ('enviado', 'Enviado', AppColors.info),
    ('em_analise', 'Em Análise', AppColors.warning),
    ('ativo', 'Ativo', AppColors.success),
    ('inadimplente', 'Inadimplente', AppColors.danger),
    ('recomendacao', 'Recomendação', AppColors.primary),
  ];

  static const _statusLabel = {
    'negociacao': 'Negociação',
    'enviado': 'Enviado',
    'em_analise': 'Em Análise',
    'ativo': 'Ativo',
    'inadimplente': 'Inadimplente',
    'recomendacao': 'Recomendação',
  };

  static const _statusBadge = {
    'ativo': AppBadgeType.success,
    'inadimplente': AppBadgeType.danger,
    'negociacao': AppBadgeType.warning,
    'enviado': AppBadgeType.neutral,
    'em_analise': AppBadgeType.warning,
    'recomendacao': AppBadgeType.neutral,
  };

  bool _clientePassaFiltro(String status) {
    if (_activeFilters.isEmpty) return true;
    return _activeFilters.contains(status);
  }

  void _toggleFilter(String value) {
    setState(() {
      if (_activeFilters.contains(value)) {
        _activeFilters.remove(value);
      } else {
        _activeFilters.add(value);
      }
    });
  }

  void _clearFilters() {
    setState(() => _activeFilters.clear());
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesProvider);
    final hasFilter = _activeFilters.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Stack(
          children: [
            Column(
              children: [
                // Inline filter chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.x4, AppSpacing.x4, AppSpacing.x4, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (hasFilter) ...[
                          GestureDetector(
                            onTap: _clearFilters,
                            child: Container(
                              height: 32,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.dangerBg,
                                border: Border.all(
                                    color: AppColors.danger
                                        .withValues(alpha: 0.3)),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.clear,
                                      size: 14, color: AppColors.danger),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Limpar',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.x2),
                        ],
                        ..._statusOptions.map((opt) {
                          final (value, label, color) = opt;
                          final isActive = _activeFilters.contains(value);
                          return Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.x2),
                            child: AppChip(
                              label: label,
                              active: isActive,
                              onTap: () => _toggleFilter(value),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                // Client list / table
                Expanded(
                  child: clientesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ApiService.extractErrorMessage(e),
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.x3),
                          AppSecondaryButton(
                            onPressed: () => ref.invalidate(clientesProvider),
                            label: 'Tentar novamente',
                          ),
                        ],
                      ),
                    ),
                    data: (clientes) {
                      final filtrados = clientes
                          .where((c) => _clientePassaFiltro(c.status))
                          .toList();

                      if (filtrados.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.people_outline_rounded,
                                  size: 48, color: AppColors.textMuted),
                              const SizedBox(height: AppSpacing.x3),
                              Text('Nenhum cliente neste filtro',
                                  style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        );
                      }

                      if (isDesktop) {
                        return _buildDesktopTable(filtrados);
                      }
                      return _buildMobileCards(filtrados);
                    },
                  ),
                ),
              ],
            ),
            // FAB — only on mobile
            if (!isDesktop)
              Positioned(
                bottom: AppSpacing.x6,
                right: AppSpacing.x4,
                child: FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  onPressed: widget.onAddCliente,
                  child: const Icon(Icons.add, color: AppColors.textOnPrimary),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopTable(List<Cliente> clientes) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: AppTable(
        columns: const [
          AppTableColumn(label: 'CLIENTE', align: 'left'),
          AppTableColumn(label: 'CIDADE', align: 'left'),
          AppTableColumn(label: 'ESTÁGIO', align: 'left'),
          AppTableColumn(label: 'VALOR', align: 'right'),
          AppTableColumn(label: 'STATUS', align: 'right'),
        ],
        rows: clientes.map((c) {
          final tone = c.status == 'ativo'
              ? ClientAvatarTone.success
              : ClientAvatarTone.neutral;
          return AppTableRow(
            cells: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClientAvatar(
                    initials: c.nome.isNotEmpty ? c.nome[0] : '?',
                    tone: tone,
                    size: 32,
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c.nome,
                          style: AppTypography.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                      if (c.celular.isNotEmpty)
                        Text(c.celular,
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
              Text(c.cidade ?? '—', style: AppTypography.bodySmall),
              Text(_statusLabel[c.status] ?? c.status,
                  style: AppTypography.bodySmall),
              Text('${(c.horasContratadas ?? 0).toStringAsFixed(0)}h',
                  style: AppTypography.bodySmall),
              AppBadge(
                label: _statusLabel[c.status] ?? c.status,
                type: _statusBadge[c.status] ?? AppBadgeType.neutral,
                showDot: false,
              ),
            ],
            onTap: () => Navigator.pushNamed(context, AppRoutes.clienteCabines,
                arguments: {'clienteId': c.id}),
          );
        }).toList(),
        hoverHighlight: true,
      ),
    );
  }

  // ... mobile cards começam abaixo
  Widget _buildMobileCards(List<Cliente> clientes) {
    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.x4, AppSpacing.x4, AppSpacing.x4, 80),
          itemCount: clientes.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.x3),
          itemBuilder: (ctx, i) {
            final c = clientes[i];
            final tone = c.status == 'ativo'
                ? ClientAvatarTone.success
                : ClientAvatarTone.neutral;
            return AppCard(
              padding: const EdgeInsets.all(AppSpacing.x4),
              onTap: () => Navigator.pushNamed(ctx, AppRoutes.clienteCabines,
                  arguments: {'clienteId': c.id}),
              child: Row(
                children: [
                  ClientAvatar(
                    initials: c.nome.isNotEmpty ? c.nome[0].toUpperCase() : '?',
                    tone: tone,
                    size: 44,
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.nome,
                            style: AppTypography.bodyMedium
                                .copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        if (c.cidade != null && c.cidade!.isNotEmpty)
                          Text(c.cidade!,
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppBadge(
                        label: _statusLabel[c.status] ?? c.status,
                        type: _statusBadge[c.status] ?? AppBadgeType.neutral,
                      ),
                      if (c.horasRestantes != null &&
                          (c.horasContratadas ?? 0) > 0) ...[
                        const SizedBox(height: AppSpacing.x1),
                        Text(
                          '${c.horasRestantes!.toStringAsFixed(1)} h restantes',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        // FAB
        Positioned(
          bottom: AppSpacing.x6,
          right: AppSpacing.x4,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: widget.onAddCliente,
            child: const Icon(Icons.add, color: AppColors.textOnPrimary),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// MAPA REAL (OpenStreetMap) — pins coloridos por status do cliente
// ════════════════════════════════════════════════════════════════════════════

class _VendasMapaTab extends StatefulWidget {
  final List<Cliente> clientes;
  final VoidCallback onAddCliente;

  const _VendasMapaTab({
    required this.clientes,
    required this.onAddCliente,
  });

  @override
  State<_VendasMapaTab> createState() => _VendasMapaTabState();
}

class _VendasMapaTabState extends State<_VendasMapaTab> {
  // Conjunto vazio = todos os status; caso contrário, só os selecionados
  final Set<String> _filterStatus = {};

  static Color _statusColor(String status) => switch (status) {
        'ativo' => AppColors.success,
        'recomendacao' => AppColors.primary,
        'enviado' => AppColors.info,
        'em_analise' => AppColors.warning,
        'negociacao' => AppColors.warning,
        'inadimplente' => AppColors.danger,
        _ => AppColors.textMuted,
      };

  static const _statusPriority = {
    'ativo': 0,
    'recomendacao': 1,
    'enviado': 2,
    'em_analise': 3,
    'negociacao': 4,
    'inadimplente': 5,
  };

  static const _statusLabel = {
    'negociacao': 'Negociação',
    'enviado': 'Enviado',
    'em_analise': 'Em Análise',
    'ativo': 'Ativo',
    'inadimplente': 'Inadimplente',
    'recomendacao': 'Recomendação',
  };

  /// Agrupa clientes por coordenada arredondada (4 casas = ~11m precisão).
  /// Clientes no mesmo ponto viram 1 marker com contagem. Clica → lista.
  List<Marker> _buildMarkers(BuildContext context, List<Cliente> clientes) {
    final Map<String, List<Cliente>> groups = {};
    for (final c in clientes) {
      final key = '${c.lat!.toStringAsFixed(4)},${c.lng!.toStringAsFixed(4)}';
      groups.putIfAbsent(key, () => []).add(c);
    }

    return groups.entries.map((e) {
      final cluster = e.value;
      // Cor = status mais crítico
      final worstIdx = cluster
          .map((c) => _statusPriority[c.status] ?? 0)
          .reduce((a, b) => a > b ? a : b);
      final worstStatus =
          _statusPriority.entries.firstWhere((x) => x.value == worstIdx).key;
      final color = _statusColor(worstStatus);
      final first = cluster.first;

      return Marker(
        point: LatLng(first.lat!, first.lng!),
        width: 70,
        height: 80,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => _showClusterDialog(context, cluster),
          child: _MapPin(
            color: color,
            label: first.estado ?? '',
            count: cluster.length,
            tooltip: cluster.length == 1
                ? '${first.nome}\n${first.cidade ?? ""} · ${first.estado ?? ""}'
                : '${cluster.length} clientes em ${first.cidade ?? "—"}/${first.estado ?? ""}',
          ),
        ),
      );
    }).toList();
  }

  void _showClusterDialog(BuildContext context, List<Cliente> clientes) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
                child: Row(
                  children: [
                    Icon(Icons.place_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${clientes.length} clientes neste local',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${clientes.first.cidade ?? "—"}/${clientes.first.estado ?? ""}',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.hairline),
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shrinkWrap: true,
                  itemCount: clientes.length,
                  separatorBuilder: (_, __) => const Divider(
                      height: 1, color: AppColors.hairline, indent: 60),
                  itemBuilder: (_, i) {
                    final c = clientes[i];
                    return ListTile(
                      leading: ClientAvatar(
                        initials:
                            c.nome.isNotEmpty ? c.nome[0].toUpperCase() : '?',
                        size: 36,
                        tone: c.status == 'ativo'
                            ? ClientAvatarTone.success
                            : ClientAvatarTone.neutral,
                      ),
                      title: Text(
                        c.nome,
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _statusLabel[c.status] ?? c.status,
                        style: AppTypography.caption.copyWith(
                          color: _statusColor(c.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right,
                          color: AppColors.textMuted, size: 18),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.clienteCabines,
                          arguments: {'clienteId': c.id},
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtra clientes com coordenadas válidas E que passam pelo filtro de status
    final geoClientes = widget.clientes
        .where((c) => c.lat != null && c.lng != null)
        .where((c) => _filterStatus.isEmpty || _filterStatus.contains(c.status))
        .toList();

    // Centro inicial: se houver clientes, primeiro da lista; senão Brasil
    final center = geoClientes.isNotEmpty
        ? LatLng(geoClientes.first.lat!, geoClientes.first.lng!)
        : const LatLng(-14.2350, -51.9253); // Centro geográfico do Brasil

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: SizedBox(
              height: 560,
              width: double.infinity,
              child: Stack(
                children: [
                  // Mapa OpenStreetMap — Positioned.fill garante constraints finitas
                  Positioned.fill(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: geoClientes.isNotEmpty ? 4.5 : 4,
                        minZoom: 2,
                        maxZoom: 18,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.livelab.saas',
                          maxZoom: 19,
                        ),
                        MarkerLayer(
                          markers: _buildMarkers(context, geoClientes),
                        ),
                      ],
                    ),
                  ),
                  // Filtro "Status do contrato" — MouseRegion + Listener garantem
                  // que o hit-test chegue ao botão antes do FlutterMap ganhar a arena.
                  Positioned(
                    top: 16,
                    left: 16,
                    child: MouseRegion(
                      opaque: true,
                      cursor: SystemMouseCursors.click,
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (_) {},
                        child: _StatusFilterButton(
                          selected: _filterStatus,
                          onChanged: (v) => setState(() {
                            _filterStatus
                              ..clear()
                              ..addAll(v);
                          }),
                        ),
                      ),
                    ),
                  ),
                  // Badge contador de clientes — canto superior direito
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.place_rounded,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            '${geoClientes.length} no mapa',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Legenda canto inferior direito
                  const Positioned(
                    right: 16,
                    bottom: 16,
                    child: _MapLegend(),
                  ),
                  // FAB add cliente — canto inferior direito (acima da legenda)
                  Positioned(
                    right: 20,
                    bottom: 210,
                    child: Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                      child: InkWell(
                        onTap: widget.onAddCliente,
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.add,
                              color: AppColors.textOnPrimary, size: 22),
                        ),
                      ),
                    ),
                  ),
                  // Atribuição OSM (obrigatório)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '© OpenStreetMap',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  // Empty state quando não há clientes geolocalizados
                  if (geoClientes.isEmpty)
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_off_rounded,
                                  size: 32, color: AppColors.textMuted),
                              const SizedBox(height: 8),
                              Text(
                                'Nenhum cliente com coordenadas',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Adicione CEP/endereço no cadastro para aparecer no mapa.',
                                textAlign: TextAlign.center,
                                style: AppTypography.caption
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final String? tooltip;

  const _MapPin({
    required this.color,
    required this.label,
    required this.count,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '$label — $count cliente${count == 1 ? "" : "s"}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gota: círculo com pontinha inferior (rotacionado 45º)
          Transform.rotate(
            angle: -0.785398, // -45 deg em radianos
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(999),
                  topRight: Radius.circular(999),
                  bottomRight: Radius.circular(999),
                  bottomLeft: Radius.circular(3),
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: 0.785398,
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Label do estado abaixo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.3,
              ),
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
      ('Negociação', AppColors.warning),
      ('Enviado', AppColors.info),
      ('Ativo', AppColors.success),
      ('Inadimplente', AppColors.danger),
      ('Recomendação', AppColors.primary),
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'LEGENDA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          for (final (label, color) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Filtro de status do contrato (menu popup multi-select)
// ════════════════════════════════════════════════════════════════════════════

class _StatusFilterButton extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  const _StatusFilterButton({
    required this.selected,
    required this.onChanged,
  });

  static const _options = [
    ('negociacao', 'Negociação', AppColors.warning),
    ('enviado', 'Enviado', AppColors.info),
    ('em_analise', 'Em Análise', AppColors.warning),
    ('ativo', 'Ativo', AppColors.success),
    ('inadimplente', 'Inadimplente', AppColors.danger),
    ('recomendacao', 'Recomendação', AppColors.primary),
  ];

  @override
  Widget build(BuildContext context) {
    final isAll = selected.isEmpty;
    final label = isAll
        ? 'Todos os status'
        : selected.length == 1
            ? _options.firstWhere((o) => o.$1 == selected.first).$2
            : '${selected.length} selecionados';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: PopupMenuButton<String>(
          tooltip: 'Filtrar por status',
          position: PopupMenuPosition.under,
          offset: const Offset(0, 4),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: const BorderSide(color: AppColors.border),
          ),
          color: Colors.white,
          itemBuilder: (ctx) => [
            // Item "Todos"
            PopupMenuItem<String>(
              value: '__all__',
              child: Row(
                children: [
                  Icon(
                    isAll
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: 18,
                    color: isAll ? AppColors.primary : AppColors.textMuted,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Todos os status',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(height: 6),
            for (final opt in _options)
              PopupMenuItem<String>(
                value: opt.$1,
                child: Row(
                  children: [
                    Icon(
                      selected.contains(opt.$1)
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 18,
                      color: selected.contains(opt.$1)
                          ? opt.$3
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: opt.$3,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      opt.$2,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          onSelected: (value) {
            if (value == '__all__') {
              onChanged(<String>{});
            } else {
              final next = Set<String>.from(selected);
              if (next.contains(value)) {
                next.remove(value);
              } else {
                next.add(value);
              }
              onChanged(next);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 16,
                  color: isAll ? AppColors.textMuted : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down,
                    size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
