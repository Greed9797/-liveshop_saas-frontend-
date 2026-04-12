import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/lead_card.dart';
import '../../providers/clientes_provider.dart';
import '../../providers/leads_provider.dart';
import '../../models/cliente.dart';
import '../../providers/contratos_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme.dart';

class ClientesLeadsScreen extends ConsumerStatefulWidget {
  const ClientesLeadsScreen({super.key});
  @override
  ConsumerState<ClientesLeadsScreen> createState() => _ClientesLeadsState();
}

class _ClientesLeadsState extends ConsumerState<ClientesLeadsScreen> {
  bool _showLeads = false; // false = Clientes, true = Leads

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.clientesLeads,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  _showLeads ? 'Leads' : 'Clientes',
                  style: AppTypography.h2.copyWith(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    if (_showLeads) {
                      ref.read(leadsProvider.notifier).refresh();
                    } else {
                      ref.read(clientesProvider.notifier).refresh();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Seletores
            Row(
              children: [
                _TabChip(
                  label: 'Clientes',
                  icon: Icons.people_outlined,
                  selected: !_showLeads,
                  count: ref.watch(clientesProvider).valueOrNull?.length,
                  onTap: () => setState(() => _showLeads = false),
                ),
                const SizedBox(width: AppSpacing.sm),
                _TabChip(
                  label: 'Leads',
                  icon: Icons.bolt_rounded,
                  selected: _showLeads,
                  count: ref.watch(leadsProvider).valueOrNull?.length,
                  onTap: () => setState(() => _showLeads = true),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Conteúdo
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
          Text('Erro: $e'),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () => ref.read(clientesProvider.notifier).refresh(),
            child: const Text('Tentar novamente'),
          ),
        ]),
      ),
      data: (clientes) => clientes.isEmpty
          ? Center(
              child: Text('Nenhum cliente cadastrado.',
                  style: AppTypography.bodySmall
                      .copyWith(color: context.colors.textSecondary)))
          : ListView.separated(
              itemCount: clientes.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.compactPadding),
          child: Row(
          children: [
            // Avatar com inicial
            CircleAvatar(
              radius: 20,
              backgroundColor: _statusColor(context).withValues(alpha: 0.15),
              child: Text(
                cliente.nome.isNotEmpty ? cliente.nome[0].toUpperCase() : '?',
                style: TextStyle(
                    color: _statusColor(context), fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cliente.nome,
                      style: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (cliente.nicho != null) cliente.nicho!,
                      if (cliente.cidade != null)
                        '${cliente.cidade}${cliente.estado != null ? '/${cliente.estado}' : ''}',
                    ].join(' • '),
                    style: AppTypography.caption
                        .copyWith(color: context.colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cliente.fatAnual > 0)
                    Text(
                      'Fat. anual: R\$ ${cliente.fatAnual.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                      style: AppTypography.caption
                          .copyWith(color: context.colors.textTertiary),
                    ),
                ],
              ),
            ),
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor(context).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                _statusLabel,
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  color: _statusColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Color _statusColor(BuildContext context) => switch (cliente.status) {
        'negociacao' => context.colors.info,
        'enviado' => context.colors.warning,
        'ativo' => context.colors.success,
        'inadimplente' => context.colors.error,
        _ => context.colors.textTertiary,
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
          Text('Erro: $e'),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () => ref.read(leadsProvider.notifier).refresh(),
            child: const Text('Tentar novamente'),
          ),
        ]),
      ),
      data: (leads) => leads.isEmpty
          ? Center(
              child: Text('Nenhum lead disponível no momento.',
                  style: AppTypography.bodySmall
                      .copyWith(color: context.colors.textSecondary)))
          : ListView.separated(
              itemCount: leads.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
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
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: ctx.colors.textTertiary,
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
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: _colorForStatus(ctx, cliente.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    cliente.status.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      color: _colorForStatus(ctx, cliente.status),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

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

            const SizedBox(height: AppSpacing.x2l),

            // Ações
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: ctx.colors.primary),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.contrato,
                      arguments: {'clienteId': cliente.id});
                },
                icon: const Icon(Icons.description_outlined,
                    color: Colors.white, size: 18),
                label: Text('Gerar Contrato',
                    style: AppTypography.bodySmall
                        .copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.cadastroCliente);
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar / Completar Dados'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Color _colorForStatus(BuildContext context, String status) => switch (status) {
  'negociacao' => context.colors.info,
  'enviado' => context.colors.warning,
  'ativo' => context.colors.success,
  'inadimplente' => context.colors.error,
  _ => context.colors.textTertiary,
};

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  const _InfoRow({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.colors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Text('$label: ',
              style: AppTypography.labelSmall
                  .copyWith(color: context.colors.textSecondary, fontWeight: FontWeight.w600)),
          Expanded(
            child: value != null
                ? Text(value!, style: AppTypography.labelSmall.copyWith(color: context.colors.textPrimary))
                : Text('Não preenchido',
                    style: AppTypography.labelSmall.copyWith(
                        color: context.colors.error, fontStyle: FontStyle.italic)),
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
      color: selected ? context.colors.primary : context.colors.background,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? Colors.white : context.colors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : context.colors.textPrimary,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.25)
                        : context.colors.textTertiary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '$count',
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : context.colors.textSecondary,
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
