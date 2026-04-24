import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

class _VendasScreenState extends ConsumerState<VendasScreen> {
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
          Expanded(
            child: _VendasListTab(
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
