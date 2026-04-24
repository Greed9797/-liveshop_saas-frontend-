import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/admin_master.dart';
import '../../providers/admin_master_provider.dart';
import '../../design_system/design_system.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/metric_card.dart';

String _crmMoney(double value) {
  return NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  ).format(value);
}

class MasterCrmScreen extends ConsumerWidget {
  const MasterCrmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crmAsync = ref.watch(masterCrmProvider);

    return AppScaffold(
      currentRoute: AppRoutes.masterCrm,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: crmAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _CrmErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(masterCrmProvider),
          ),
          data: (crm) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CRM', style: AppTypography.h1),
                          const SizedBox(height: AppSpacing.x1),
                          Text(
                            'Placeholder pronto para a expansão comercial da franqueadora.',
                            style: AppTypography.bodyLarge.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(masterCrmProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Atualizar'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x5),
                AppCard(
                  color: AppColors.primaryLight,
                  borderColor: AppColors.primarySoft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.construction_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.x3),
                      Expanded(
                        child: Text(
                          crm.message,
                          style: AppTypography.bodyLarge.copyWith(
                            color: context.colors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.x5),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth >= 1100
                        ? (constraints.maxWidth - (AppSpacing.x3 * 3)) / 4
                        : constraints.maxWidth >= 700
                        ? (constraints.maxWidth - AppSpacing.x3) / 2
                        : constraints.maxWidth;

                    return Wrap(
                      spacing: AppSpacing.x3,
                      runSpacing: AppSpacing.x3,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: MetricCard(
                            label: 'LEAD POOL',
                            value: '${crm.summary.leadPool}',
                            icon: Icons.hub_rounded,
                            iconColor: AppColors.info,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: MetricCard(
                            label: 'LEADS TOTAIS',
                            value: '${crm.summary.totalLeads}',
                            icon: Icons.groups_rounded,
                            iconColor: AppColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: MetricCard(
                            label: 'VALOR POTENCIAL',
                            value: _crmMoney(crm.summary.estimatedValue),
                            icon: Icons.payments_rounded,
                            iconColor: AppColors.success,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: MetricCard(
                            label: 'CONTRATOS PENDENTES',
                            value: '${crm.summary.pendingContracts}',
                            icon: Icons.assignment_late_rounded,
                            iconColor: AppColors.warning,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.x5),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth >= 1100
                        ? (constraints.maxWidth - AppSpacing.x3) / 2
                        : constraints.maxWidth;

                    return Wrap(
                      spacing: AppSpacing.x3,
                      runSpacing: AppSpacing.x3,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _PipelinePlaceholderCard(stages: crm.pipeline),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _RecommendedFieldsCard(
                            fields: crm.recommendedFields,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.x5),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leitura atual do placeholder',
                        style: AppTypography.h3,
                      ),
                      const SizedBox(height: AppSpacing.x3),
                      Wrap(
                        spacing: AppSpacing.x5,
                        runSpacing: AppSpacing.x3,
                        children: [
                          _SummaryLine(
                            label: 'Leads engajados',
                            value: '${crm.summary.engagedLeads}',
                          ),
                          _SummaryLine(
                            label: 'Leads expirados',
                            value: '${crm.summary.expiredLeads}',
                          ),
                          _SummaryLine(
                            label: 'Modo',
                            value: crm.isPlaceholder
                                ? 'Placeholder ativo'
                                : 'Integrado',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PipelinePlaceholderCard extends StatelessWidget {
  final List<MasterPipelineStage> stages;

  const _PipelinePlaceholderCard({required this.stages});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pipeline sugerida', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.x1),
          Text(
            'Estrutura visual pronta para receber os dados reais depois.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.x4),
          ...stages.map(
            (stage) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.x2),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3,
                vertical: AppSpacing.x3,
              ),
              decoration: BoxDecoration(
                color: context.colors.bgPage,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(stage.stage, style: AppTypography.bodyMedium),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${stage.count}',
                      style: AppTypography.caption.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedFieldsCard extends StatelessWidget {
  final List<String> fields;

  const _RecommendedFieldsCard({required this.fields});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Campos básicos do CRM', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.x1),
          Text(
            'Modelagem mínima para plugar o backend real sem retrabalho.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.x4),
          ...fields.map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.x2),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  Expanded(
                    child: Text(
                      field,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.x1),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(color: context.colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _CrmErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CrmErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.x3),
            Text(
              'Não foi possível carregar o CRM placeholder.',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              message,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x4),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
