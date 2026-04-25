import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../design_system/design_system.dart';
import '../../models/cliente.dart';
import '../../providers/clientes_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../widgets/responsive_grid.dart';

class ClientesLeadsScreen extends ConsumerWidget {
  const ClientesLeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientesAsync = ref.watch(clientesProvider);

    return AppScreenScaffold(
      currentRoute: AppRoutes.clientes,
      eyebrow: 'Carteira convertida',
      titleSerif: true,
      title: 'Clientes',
      subtitle:
          'Apenas clientes convertidos: ativos, inadimplentes e cancelados.',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          color: context.colors.textSecondary,
          onPressed: () => ref.read(clientesProvider.notifier).refresh(),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: clientesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(ApiService.extractErrorMessage(error)),
                const SizedBox(height: AppSpacing.x3),
                AppSecondaryButton(
                  label: 'Tentar novamente',
                  onPressed: () =>
                      ref.read(clientesProvider.notifier).refresh(),
                ),
              ],
            ),
          ),
          data: (clientes) => _ClientesContent(clientes: clientes),
        ),
      ),
    );
  }
}

// ── Kanban phase definition ───────────────────────────────────────────────────

class _KanbanPhase {
  final String id;
  final String label;
  final Color color;
  final List<Cliente> clients;

  const _KanbanPhase({
    required this.id,
    required this.label,
    required this.color,
    required this.clients,
  });
}

List<_KanbanPhase> _buildPhases(List<Cliente> all) {
  return [
    _KanbanPhase(
      id: 'onboarding',
      label: 'Onboarding',
      color: AppColors.info,
      clients: all.where((c) => c.status == 'onboarding').toList(),
    ),
    _KanbanPhase(
      id: 'satisfeito',
      label: 'Ativo: Satisfeito',
      color: AppColors.success,
      clients: all
          .where((c) => c.status == 'ativo' && c.score >= 70)
          .toList(),
    ),
    _KanbanPhase(
      id: 'alerta',
      label: 'Ativo: Alerta',
      color: AppColors.warning,
      clients: all
          .where((c) => c.status == 'ativo' && c.score >= 30 && c.score < 70)
          .toList(),
    ),
    _KanbanPhase(
      id: 'churn',
      label: 'Risco de Churn',
      color: AppColors.danger,
      clients: all
          .where((c) => c.status == 'ativo' && c.score < 30)
          .toList(),
    ),
    _KanbanPhase(
      id: 'inativo',
      label: 'Inadimplente / Cancelado',
      color: AppColors.textMuted,
      clients: all
          .where((c) =>
              c.status == 'inadimplente' || c.status == 'cancelado')
          .toList(),
    ),
  ];
}

// ── Content widget ────────────────────────────────────────────────────────────

class _ClientesContent extends StatefulWidget {
  final List<Cliente> clientes;

  const _ClientesContent({required this.clientes});

  @override
  State<_ClientesContent> createState() => _ClientesContentState();
}

class _ClientesContentState extends State<_ClientesContent> {
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Cliente> get _allClientes => widget.clientes;

  List<Cliente> _applySearch(List<Cliente> source) {
    final q = _searchQuery.toLowerCase();
    if (q.isEmpty) return source;
    return source.where((c) {
      return c.nome.toLowerCase().contains(q) ||
          c.celular.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ativos =
        _allClientes.where((c) => c.status == 'ativo').length;
    final inadimplentes =
        _allClientes.where((c) => c.status == 'inadimplente').length;
    final cancelados =
        _allClientes.where((c) => c.status == 'cancelado').length;

    // Build phases from the full list, then apply search to each
    final phases = _buildPhases(_allClientes).map((phase) {
      return _KanbanPhase(
        id: phase.id,
        label: phase.label,
        color: phase.color,
        clients: _applySearch(phase.clients),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── KPI cards (always full list) ──────────────────────────────
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 3,
          desktopColumns: 3,
          spacing: AppSpacing.x3,
          runSpacing: AppSpacing.x3,
          children: [
            KpiAccentCard(
              label: 'Ativos',
              value: '$ativos',
              sub: 'com contrato em operação',
              accentTop: true,
              valueColor: AppColors.success,
            ),
            KpiAccentCard(
              label: 'Inadimplentes',
              value: '$inadimplentes',
              sub: 'continuam na carteira',
              valueColor: AppColors.danger,
            ),
            KpiAccentCard(
              label: 'Cancelados',
              value: '$cancelados',
              sub: 'histórico mantido',
              valueColor: context.colors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x5),

        // ── Search field ──────────────────────────────────────────────
        AppTextField(
          controller: _searchCtrl,
          hint: 'Buscar por nome ou telefone',
          prefixIcon: Icons.search,
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: AppSpacing.x4),

        // ── Kanban board ──────────────────────────────────────────────
        if (_allClientes.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Nenhum cliente convertido encontrado.',
                style: AppTypography.bodyMedium
                    .copyWith(color: context.colors.textSecondary),
              ),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: phases.map((phase) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.x4),
                    child: _KanbanColumn(phase: phase),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Kanban column ─────────────────────────────────────────────────────────────

class _KanbanColumn extends StatelessWidget {
  final _KanbanPhase phase;

  const _KanbanColumn({required this.phase});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x3,
              vertical: AppSpacing.x2,
            ),
            decoration: BoxDecoration(
              color: phase.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: phase.color.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    phase.label,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: phase.color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: phase.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${phase.clients.length}',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: phase.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x3),

          // Cards list (scrollable vertically within the column)
          Flexible(
            child: phase.clients.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.x4),
                    decoration: BoxDecoration(
                      color: context.colors.bgMuted,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: context.colors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      'Nenhum cliente',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: phase.clients.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.x3),
                    itemBuilder: (context, index) =>
                        _KanbanCard(cliente: phase.clients[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Kanban card ───────────────────────────────────────────────────────────────

class _KanbanCard extends StatelessWidget {
  final Cliente cliente;

  const _KanbanCard({required this.cliente});

  static final _currencyFmt = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final hasFat = cliente.fatAnual > 0;

    final locationNicho = [
      if ((cliente.cidade ?? '').isNotEmpty)
        '${cliente.cidade}${cliente.estado != null ? '/${cliente.estado}' : ''}',
      if ((cliente.nicho ?? '').isNotEmpty) cliente.nicho!,
    ].join(' · ');

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.x3),
      borderColor: context.colors.borderSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + status badge
          Row(
            children: [
              Expanded(
                child: Text(
                  cliente.nome,
                  style: AppTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              AppBadge(label: _statusLabel, type: _badgeType),
            ],
          ),

          // City + nicho
          if (locationNicho.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.x1),
            Text(
              locationNicho,
              style: AppTypography.caption
                  .copyWith(color: context.colors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Fat. anual
          if (hasFat) ...[
            const SizedBox(height: AppSpacing.x1),
            Text(
              'Fat. anual: ${_currencyFmt.format(cliente.fatAnual)}',
              style: AppTypography.caption.copyWith(
                color: context.colors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.x2),

          // Score chip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x2,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: _scoreColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: _scoreColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'Score: ${cliente.score}',
              style: AppTypography.caption.copyWith(
                color: _scoreColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color get _scoreColor {
    if (cliente.score >= 70) return AppColors.success;
    if (cliente.score >= 30) return AppColors.warning;
    return AppColors.danger;
  }

  AppBadgeType get _badgeType => switch (cliente.status) {
        'ativo' => AppBadgeType.success,
        'inadimplente' => AppBadgeType.danger,
        _ => AppBadgeType.neutral,
      };

  String get _statusLabel => switch (cliente.status) {
        'ativo' => 'ATIVO',
        'inadimplente' => 'INADIMP.',
        'cancelado' => 'CANCELADO',
        'onboarding' => 'ONBOARDING',
        _ => cliente.status.toUpperCase(),
      };
}
