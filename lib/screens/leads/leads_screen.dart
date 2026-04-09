import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/lead_card.dart';
import '../../providers/leads_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';

/// Painel de leads disponíveis da franqueadora
class LeadsScreen extends ConsumerWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadsProvider);

    return AppScaffold(
      currentRoute: AppRoutes.leads,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Leads Disponíveis',
                    style: AppTypography.h2.copyWith(fontSize: 20, fontWeight: FontWeight.w500)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(leadsProvider.notifier).refresh(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            leadsAsync.when(
              loading: () => Text('Carregando...',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.gray500)),
              error: (e, __) => Text(
                e.toString(),
                style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
              ),
              data: (leads) => Text(
                  '${leads.length} leads disponíveis para você',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.gray500)),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: leadsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('Erro: $e'),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(leadsProvider.notifier).refresh(),
                      child: const Text('Tentar novamente'),
                    ),
                  ]),
                ),
                data: (leads) => leads.isEmpty
                    ? Center(
                        child: Text('Nenhum lead disponível no momento.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.gray500)))
                    : ListView.separated(
                        itemCount: leads.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
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
                                ? () => ref
                                    .read(leadsProvider.notifier)
                                    .pegar(lead.id)
                                : null,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
