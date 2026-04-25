import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _ClientesContent extends StatelessWidget {
  final List<Cliente> clientes;

  const _ClientesContent({required this.clientes});

  @override
  Widget build(BuildContext context) {
    final ativos = clientes.where((c) => c.status == 'ativo').length;
    final inadimplentes =
        clientes.where((c) => c.status == 'inadimplente').length;
    final cancelados = clientes.where((c) => c.status == 'cancelado').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Expanded(
          child: clientes.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum cliente convertido encontrado.',
                    style: AppTypography.bodyMedium
                        .copyWith(color: context.colors.textSecondary),
                  ),
                )
              : ListView.separated(
                  itemCount: clientes.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.x3),
                  itemBuilder: (context, index) =>
                      _ClienteCard(cliente: clientes[index]),
                ),
        ),
      ],
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final Cliente cliente;

  const _ClienteCard({required this.cliente});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.x4),
      borderColor: context.colors.borderSubtle,
      child: Row(
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
                Text(
                  cliente.nome,
                  style: AppTypography.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.x1),
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
              ],
            ),
          ),
          AppBadge(label: _statusLabel, type: _badgeType),
        ],
      ),
    );
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
