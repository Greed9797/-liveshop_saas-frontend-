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

class _ClientesContent extends StatefulWidget {
  final List<Cliente> clientes;

  const _ClientesContent({required this.clientes});

  @override
  State<_ClientesContent> createState() => _ClientesContentState();
}

class _ClientesContentState extends State<_ClientesContent> {
  String _statusFilter = 'todos';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Cliente> get _allClientes => widget.clientes;

  List<Cliente> get _filtered {
    return _allClientes.where((c) {
      final matchesStatus =
          _statusFilter == 'todos' || c.status == _statusFilter;
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          c.nome.toLowerCase().contains(q) ||
          c.celular.toLowerCase().contains(q);
      return matchesStatus && matchesSearch;
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

    final filtered = _filtered;

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
        const SizedBox(height: AppSpacing.x3),

        // ── Status filter chips ───────────────────────────────────────
        Wrap(
          spacing: AppSpacing.x2,
          runSpacing: AppSpacing.x2,
          children: [
            _StatusChip(
              label: 'Todos',
              count: _allClientes.length,
              selected: _statusFilter == 'todos',
              onTap: () => setState(() => _statusFilter = 'todos'),
            ),
            _StatusChip(
              label: 'Ativos',
              count: ativos,
              selected: _statusFilter == 'ativo',
              onTap: () => setState(() => _statusFilter = 'ativo'),
            ),
            _StatusChip(
              label: 'Inadimplentes',
              count: inadimplentes,
              selected: _statusFilter == 'inadimplente',
              onTap: () => setState(() => _statusFilter = 'inadimplente'),
            ),
            _StatusChip(
              label: 'Cancelados',
              count: cancelados,
              selected: _statusFilter == 'cancelado',
              onTap: () => setState(() => _statusFilter = 'cancelado'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x4),

        // ── List ──────────────────────────────────────────────────────
        Expanded(
          child: _allClientes.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum cliente convertido encontrado.',
                    style: AppTypography.bodyMedium
                        .copyWith(color: context.colors.textSecondary),
                  ),
                )
              : filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum resultado para os filtros aplicados.',
                        style: AppTypography.bodyMedium
                            .copyWith(color: context.colors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.x3),
                      itemBuilder: (context, index) =>
                          _ClienteCard(cliente: filtered[index]),
                    ),
        ),
      ],
    );
  }
}

// ── Status pill chip ──────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x1 + 2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : context.colors.bgMuted,
          border: Border.all(
            color: selected ? AppColors.primary : context.colors.borderSubtle,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          '$label ($count)',
          style: AppTypography.caption.copyWith(
            color: selected ? AppColors.primary : context.colors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Cliente card ──────────────────────────────────────────────────────────────

class _ClienteCard extends StatelessWidget {
  final Cliente cliente;

  const _ClienteCard({required this.cliente});

  static final _currencyFmt = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final hasHoras = cliente.horasContratadas != null;
    final hasFat = cliente.fatAnual > 0;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.x4),
      borderColor: context.colors.borderSubtle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _statusColor.withValues(alpha: 0.12),
            child: Text(
              cliente.nome.isEmpty ? '?' : cliente.nome[0].toUpperCase(),
              style: AppTypography.bodyMedium.copyWith(
                color: _statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row
                Text(
                  cliente.nome,
                  style: AppTypography.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.x1),
                // Contact/location row
                Text(
                  [
                    if ((cliente.email ?? '').isNotEmpty) cliente.email!,
                    cliente.celular,
                    if ((cliente.cidade ?? '').isNotEmpty)
                      '${cliente.cidade}${cliente.estado != null ? '/${cliente.estado}' : ''}',
                  ].join(' • '),
                  style: AppTypography.caption
                      .copyWith(color: context.colors.textSecondary),
                ),
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
                // Horas
                if (hasHoras) ...[
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    '${_horasLabel(cliente.horasContratadas!)} contratadas'
                    ' • ${_horasLabel(cliente.horasRestantes ?? 0)} restantes',
                    style: AppTypography.caption.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          AppBadge(label: _statusLabel, type: _badgeType),
        ],
      ),
    );
  }

  String _horasLabel(double h) {
    final intH = h.truncate();
    final mins = ((h - intH) * 60).round();
    if (mins == 0) return '${intH}h';
    return '${intH}h ${mins}min';
  }

  Color get _statusColor => switch (cliente.status) {
        'ativo' => AppColors.success,
        'inadimplente' => AppColors.danger,
        'cancelado' => AppColors.textMuted,
        _ => AppColors.textMuted,
      };

  AppBadgeType get _badgeType => switch (cliente.status) {
        'ativo' => AppBadgeType.success,
        'inadimplente' => AppBadgeType.danger,
        _ => AppBadgeType.neutral,
      };

  String get _statusLabel => switch (cliente.status) {
        'ativo' => 'ATIVO',
        'inadimplente' => 'INADIMPLENTE',
        'cancelado' => 'CANCELADO',
        _ => cliente.status.toUpperCase(),
      };
}
