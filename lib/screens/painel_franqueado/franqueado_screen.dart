import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/metric_card.dart';
import '../../providers/franqueado_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Painel master do franqueador — visão de todas as unidades
class FranqueadoScreen extends ConsumerWidget {
  const FranqueadoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unidadesAsync = ref.watch(franqueadoProvider);

    return AppScaffold(
      currentRoute: AppRoutes.franqueado,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Painel do Franqueador',
                        style: AppTypography.h2.copyWith(fontWeight: FontWeight.w500)),
                    Text('Visão geral de todas as unidades',
                        style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(franqueadoProvider.notifier).refresh(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: unidadesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('Erro: $e'),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () => ref.read(franqueadoProvider.notifier).refresh(),
                      child: const Text('Tentar novamente'),
                    ),
                  ]),
                ),
                data: (unidades) => _UnidadesContent(unidades: unidades),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnidadesContent extends StatelessWidget {
  final List<Unidade> unidades;
  const _UnidadesContent({required this.unidades});

  @override
  Widget build(BuildContext context) {
    final ativas     = unidades.where((u) => u.status == 'ativo').length;
    final fatTotal   = unidades.fold(0.0, (sum, u) => sum + u.fatMes);
    final pendentes  = unidades.fold(0,   (sum, u) => sum + u.contratosPendentes);
    final currency   = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Column(
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'UNIDADES ATIVAS',
                  value: '$ativas',
                  icon: Icons.store_outlined,
                  iconColor: context.colors.success,
                ),
              ),
              SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'FAT. CONSOLIDADO',
                  value: currency.format(fatTotal),
                  icon: Icons.attach_money,
                  iconColor: context.colors.primary,
                ),
              ),
              SizedBox(
                width: 220,
                child: MetricCard(
                  label: 'CONTRATOS PENDENTES',
                  value: '$pendentes',
                  icon: Icons.pending_outlined,
                  iconColor: context.colors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Unidades Franqueadas',
                style: AppTypography.bodyMedium),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: unidades.isEmpty
                ? Center(
                    child: Text('Nenhuma unidade encontrada.',
                        style: TextStyle(color: context.colors.textSecondary)))
                : ListView.separated(
                    itemCount: unidades.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final u = unidades[i];
                      return ListTile(
                        title: Text(u.nome,
                            style: TextStyle(fontWeight: FontWeight.w500, color: context.colors.textPrimary)),
                        subtitle: Text(
                            'Clientes: ${u.clientesCount} • Fat: ${currency.format(u.fatMes)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (u.contratosPendentes > 0)
                              Chip(
                                label: Text('${u.contratosPendentes} pendentes',
                                    style: AppTypography.caption.copyWith(fontSize: 11)),
                                backgroundColor: context.colors.warning.withValues(alpha: 0.15),
                                labelStyle: TextStyle(color: context.colors.warning),
                              ),
                            const SizedBox(width: AppSpacing.sm),
                            StatusBadge(status: u.status),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
    );
  }
}
