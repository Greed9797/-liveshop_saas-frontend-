import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../design_system/design_system.dart';
import '../../widgets/lead_card.dart';
import '../../widgets/client_avatar.dart';
import '../../providers/clientes_provider.dart';
import '../../providers/leads_provider.dart';
import '../../models/cliente.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../widgets/responsive_grid.dart';

class ClientesLeadsScreen extends ConsumerStatefulWidget {
  const ClientesLeadsScreen({super.key});
  @override
  ConsumerState<ClientesLeadsScreen> createState() => _ClientesLeadsState();
}

class _ClientesLeadsState extends ConsumerState<ClientesLeadsScreen> {
  bool _showLeads = false; // false = Clientes, true = Leads

  @override
  Widget build(BuildContext context) {
    return AppScreenScaffold(
      currentRoute: AppRoutes.clientesLeads,
      eyebrow: 'Carteira comercial',
      titleSerif: true,
      title: 'Clientes & Leads',
      subtitle: 'Gerencie sua carteira de clientes e leads.',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          color: AppColors.textSecondary,
          onPressed: () {
            if (_showLeads) {
              ref.read(leadsProvider.notifier).refresh();
            } else {
              ref.read(clientesProvider.notifier).refresh();
            }
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI strip
            Consumer(
              builder: (context, ref, _) {
                final clientesAsync = ref.watch(clientesProvider);
                final leadsAsync = ref.watch(leadsProvider);
                final totalClientes = clientesAsync.valueOrNull?.length ?? 0;
                final totalLeads = leadsAsync.valueOrNull?.length ?? 0;
                final conversionRate = totalLeads > 0
                    ? ((totalClientes / (totalClientes + totalLeads)) * 100).toStringAsFixed(0)
                    : '0';
                return ResponsiveGrid(
                  mobileColumns: 1,
                  tabletColumns: 3,
                  desktopColumns: 3,
                  spacing: AppSpacing.x3,
                  runSpacing: AppSpacing.x3,
                  children: [
                    KpiAccentCard(
                      label: 'Clientes',
                      value: '$totalClientes',
                      sub: 'ativos',
                      accentTop: true,
                    ),
                    KpiAccentCard(
                      label: 'Leads',
                      value: '$totalLeads',
                      sub: 'em qualificação',
                      valueColor: AppColors.warning,
                    ),
                    KpiAccentCard(
                      label: 'Conversão',
                      value: '$conversionRate%',
                      sub: 'lead → cliente',
                      valueColor: AppColors.success,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.x5),
            // Tab selector row
            Row(
              children: [
                _TabChip(
                  label: 'Clientes',
                  icon: Icons.people_outline,
                  selected: !_showLeads,
                  count: ref.watch(clientesProvider).valueOrNull?.length,
                  onTap: () => setState(() => _showLeads = false),
                ),
                const SizedBox(width: AppSpacing.x2),
                _TabChip(
                  label: 'Leads',
                  icon: Icons.trending_up,
                  selected: _showLeads,
                  count: ref.watch(leadsProvider).valueOrNull?.length,
                  onTap: () => setState(() => _showLeads = true),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x4),
            // Content
            Expanded(
              child: _showLeads ? _LeadsTab() : _ClientesTab(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Clientes ────────────────────────────────────────────────────────────

class _ClientesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientesAsync = ref.watch(clientesProvider);

    return clientesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            ApiService.extractErrorMessage(e),
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.x3),
          AppSecondaryButton(
            onPressed: () => ref.read(clientesProvider.notifier).refresh(),
            label: 'Tentar novamente',
          ),
        ]),
      ),
      data: (clientes) => clientes.isEmpty
          ? Center(
              child: Text('Nenhum cliente cadastrado.',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary)))
          : ListView.separated(
              itemCount: clientes.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.x2),
              itemBuilder: (_, i) => _ClienteCard(
                cliente: clientes[i],
                onTap: () => _showClienteDetail(context, ref, clientes[i]),
              ),
            ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback? onTap;
  const _ClienteCard({required this.cliente, this.onTap});

  static final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.x3),
      onTap: onTap,
      child: Row(
        children: [
          ClientAvatar(
            initials: cliente.nome.isNotEmpty ? cliente.nome[0].toUpperCase() : '?',
            tone: _tone,
            size: 40,
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cliente.nome,
                    style: AppTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: AppSpacing.x1),
                Text(
                  [
                    if (cliente.nicho != null) cliente.nicho!,
                    if (cliente.cidade != null)
                      '${cliente.cidade}${cliente.estado != null ? '/${cliente.estado}' : ''}',
                  ].join(' • '),
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (cliente.fatAnual > 0)
                  Text(
                    'Fat. anual: ${_currencyFmt.format(cliente.fatAnual)}',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          AppBadge(
            label: _statusLabel,
            type: _statusBadgeType,
          ),
        ],
      ),
    );
  }

  AppBadgeType get _statusBadgeType => switch (cliente.status) {
        'negociacao' => AppBadgeType.warning,
        'enviado' => AppBadgeType.neutral,
        'ativo' => AppBadgeType.success,
        'inadimplente' => AppBadgeType.danger,
        _ => AppBadgeType.neutral,
      };

  ClientAvatarTone get _tone => switch (cliente.status) {
        'negociacao' => ClientAvatarTone.warning,
        'enviado' => ClientAvatarTone.neutral,
        'ativo' => ClientAvatarTone.success,
        'inadimplente' => ClientAvatarTone.warning,
        _ => ClientAvatarTone.neutral,
      };

  String get _statusLabel => switch (cliente.status) {
        'negociacao' => 'NEGOCIAÇÃO',
        'enviado' => 'ENVIADO',
        'ativo' => 'ATIVO',
        'inadimplente' => 'INADIMPLENTE',
        _ => cliente.status.toUpperCase(),
      };
}

// ─── Tab Leads ───────────────────────────────────────────────────────────────

class _LeadsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadsProvider);

    return leadsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            ApiService.extractErrorMessage(e),
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.x3),
          AppSecondaryButton(
            onPressed: () => ref.read(leadsProvider.notifier).refresh(),
            label: 'Tentar novamente',
          ),
        ]),
      ),
      data: (leads) => leads.isEmpty
          ? Center(
              child: Text('Nenhum lead disponível no momento.',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary)))
          : ListView.separated(
              itemCount: leads.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.x2),
              itemBuilder: (_, i) {
                final lead = leads[i];
                return LeadCard(
                  lead: {
                    'id': lead.id,
                    'nome': lead.nome,
                    'nicho': lead.nicho ?? '',
                    'cidade': lead.cidade ?? '',
                    'fat_estimado': lead.fatEstimado,
                    'status': lead.status,
                    'novo': lead.isNovo,
                    'expira_em': lead.expiraEm?.toIso8601String(),
                  },
                  onPegar: lead.status == 'disponivel'
                      ? () => ref.read(leadsProvider.notifier).pegar(lead.id)
                      : null,
                );
              },
            ),
    );
  }
}

// ─── Detalhe do cliente ──────────────────────────────────────────────────────

void _showClienteDetail(BuildContext context, WidgetRef ref, Cliente cliente) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      builder: (ctx, scrollCtrl) => SingleChildScrollView(
        controller: scrollCtrl,
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.x4),
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Nome + status
            Row(
              children: [
                Expanded(
                  child: Text(cliente.nome, style: AppTypography.h3),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x2, vertical: AppSpacing.x1),
                  decoration: BoxDecoration(
                    color: _colorForStatus(cliente.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: AppBadge(
                    label: cliente.status.toUpperCase(),
                    type: _badgeTypeForStatus(cliente.status),
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.x6),

            // Dados do cliente
            _InfoRow(icon: Icons.phone_outlined,
                label: 'Celular', value: cliente.celular.isEmpty ? null : cliente.celular),
            _InfoRow(icon: Icons.email_outlined,
                label: 'Email', value: cliente.email),
            _InfoRow(icon: Icons.business_outlined,
                label: 'Nicho', value: cliente.nicho),
            _InfoRow(icon: Icons.location_on_outlined,
                label: 'Cidade',
                value: cliente.cidade != null
                    ? '${cliente.cidade}${cliente.estado != null ? '/${cliente.estado}' : ''}'
                    : null),
            _InfoRow(icon: Icons.attach_money,
                label: 'Fat. Anual',
                value: cliente.fatAnual > 0
                    ? 'R\$ ${cliente.fatAnual.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'
                    : null),

            const SizedBox(height: AppSpacing.x6),

            // Ações
            AppPrimaryButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.contrato,
                    arguments: {'clienteId': cliente.id});
              },
              icon: Icons.description_outlined,
              label: 'Gerar Contrato',
            ),
            const SizedBox(height: AppSpacing.x2),
            AppSecondaryButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.cadastroCliente);
              },
              icon: Icons.edit_outlined,
              label: 'Editar / Completar Dados',
            ),
          ],
        ),
      ),
    ),
  );
}

Color _colorForStatus(String status) => switch (status) {
  'negociacao' => AppColors.warning,
  'enviado' => AppColors.info,
  'ativo' => AppColors.success,
  'inadimplente' => AppColors.danger,
  _ => AppColors.textMuted,
};

AppBadgeType _badgeTypeForStatus(String status) => switch (status) {
  'negociacao' => AppBadgeType.warning,
  'enviado' => AppBadgeType.neutral,
  'ativo' => AppBadgeType.success,
  'inadimplente' => AppBadgeType.danger,
  _ => AppBadgeType.neutral,
};

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  const _InfoRow({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x1),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.x2),
          Text('$label: ',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Expanded(
            child: value != null
                ? Text(value!, style: AppTypography.caption.copyWith(color: AppColors.textPrimary))
                : Text('Não preenchido',
                    style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }
}

// ─── Chip seletor ────────────────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final int? count;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.icon,
    required this.selected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.bgBase,
      borderRadius: BorderRadius.circular(AppRadius.full),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4, vertical: AppSpacing.x2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? AppColors.textOnPrimary : AppColors.textSecondary),
              const SizedBox(width: AppSpacing.x1),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.textOnPrimary : AppColors.textPrimary,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: AppSpacing.x1),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.x2, vertical: AppSpacing.x1),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.textOnPrimary.withValues(alpha: 0.25)
                        : AppColors.textMuted,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '$count',
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
