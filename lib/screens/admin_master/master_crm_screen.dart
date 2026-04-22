import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/admin_master.dart';
import '../../providers/admin_master_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_card.dart';
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
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
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
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Placeholder pronto para a expansão comercial da franqueadora.',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.gray500,
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
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  backgroundColor: AppColors.primaryOrangeLight,
                  borderColor: AppColors.orange100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.construction_rounded,
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          crm.message,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.gray700,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth >= 1100
                        ? (constraints.maxWidth - (AppSpacing.md * 3)) / 4
                        : constraints.maxWidth >= 700
                        ? (constraints.maxWidth - AppSpacing.md) / 2
                        : constraints.maxWidth;

                    return Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
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
                            iconColor: AppColors.primaryOrange,
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
                const SizedBox(height: AppSpacing.xl),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth >= 1100
                        ? (constraints.maxWidth - AppSpacing.md) / 2
                        : constraints.maxWidth;

                    return Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
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
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leitura atual do placeholder',
                        style: AppTypography.h3,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.xl,
                        runSpacing: AppSpacing.md,
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
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Estrutura visual pronta para receber os dados reais depois.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...stages.map(
            (stage) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gray200),
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
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${stage.count}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.gray700,
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
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Modelagem mínima para plugar o backend real sem retrabalho.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...fields.map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      field,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.gray900,
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
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.gray900),
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
            const SizedBox(height: AppSpacing.md),
            Text(
              'Não foi possível carregar o CRM placeholder.',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
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
