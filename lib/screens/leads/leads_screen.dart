import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/lead_card.dart';
import '../../providers/leads_provider.dart';
import '../../routes/app_routes.dart';
import '../../design_system/design_system.dart';

/// Painel de leads disponíveis da franqueadora
class LeadsScreen extends ConsumerWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadsProvider);

    return AppScaffold(
      currentRoute: AppRoutes.leads,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x6),
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
            const SizedBox(height: AppSpacing.x1),
            leadsAsync.when(
              loading: () => Text('Carregando...',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              error: (e, __) => Text(
                e.toString(),
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              data: (leads) => Text(
                  '${leads.length} leads disponíveis para você',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: AppSpacing.x4),
            Expanded(
              child: leadsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('Erro: $e'),
                    const SizedBox(height: AppSpacing.x3),
                    AppPrimaryButton(
                      onPressed: () =>
                          ref.read(leadsProvider.notifier).refresh(),
                      label: 'Tentar novamente',
                    ),
                  ]),
                ),
                data: (leads) => leads.isEmpty
                    ? Center(
                        child: Text('Nenhum lead disponível no momento.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)))
                    : ListView.separated(
                        itemCount: leads.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.x2),
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
