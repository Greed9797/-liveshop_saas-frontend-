import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/analytics_dashboard_provider.dart';
import '../../providers/clientes_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/analytics_ranking_list.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/charts/gmv_mensal_chart.dart';
import '../../widgets/charts/horas_live_chart.dart';
import '../../widgets/charts/vendas_mensal_chart.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  final _mesAnoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filtros = ref.read(dashboardFiltrosProvider);
    _mesAnoCtrl.text = filtros.mesAno;
  }

  @override
  void dispose() {
    _mesAnoCtrl.dispose();
    super.dispose();
  }

  void _onClienteChanged(String? clienteId) {
    ref.read(dashboardFiltrosProvider.notifier).setClienteId(clienteId);
  }

  void _onMesAnoSubmitted(String value) {
    // Validação de formato YYYY-MM
    final regex = RegExp(r'^\d{4}-\d{2}$');
    if (!regex.hasMatch(value)) return;
    ref.read(dashboardFiltrosProvider.notifier).setMesAno(value);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.analyticsDashboard,
      child: _AnalyticsDashboardBody(
        mesAnoCtrl: _mesAnoCtrl,
        onClienteChanged: _onClienteChanged,
        onMesAnoSubmitted: _onMesAnoSubmitted,
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Body — separado para isolar rebuilds
// ──────────────────────────────────────────────

class _AnalyticsDashboardBody extends ConsumerWidget {
  final TextEditingController mesAnoCtrl;
  final void Function(String?) onClienteChanged;
  final void Function(String) onMesAnoSubmitted;

  const _AnalyticsDashboardBody({
    required this.mesAnoCtrl,
    required this.onClienteChanged,
    required this.onMesAnoSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtros = ref.watch(dashboardFiltrosProvider);
    final dashAsync = ref.watch(analyticsDashboardProvider);
    final clientesAsync = ref.watch(clientesProvider);

    return Column(
      children: [
        // ── Header com filtros ──
        _buildHeader(context, ref, filtros, clientesAsync),

        // ── Conteúdo ──
        Expanded(
          child: dashAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.dangerRed),
                    const SizedBox(height: AppSpacing.md),
                    Text('Erro ao carregar dados', style: AppTypography.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text('$e', style: AppTypography.caption.copyWith(color: AppColors.gray500), textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => ref.read(analyticsDashboardProvider.notifier).refresh(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
            data: (data) => LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= AppBreakpoints.tablet;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KPI Cards
                      _KpiCardsRow(data: data),
                      const SizedBox(height: AppSpacing.x2l),

                      // Bar charts (side-by-side no desktop, empilhados no mobile)
                      if (isDesktop)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: GmvMensalChart(dados: data.faturamentoMensal)),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: VendasMensalChart(dados: data.vendasMensal)),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: [
                            GmvMensalChart(dados: data.faturamentoMensal),
                            const SizedBox(height: AppSpacing.md),
                            VendasMensalChart(dados: data.vendasMensal),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.x2l),

                      // Horas de live (full width, scroll horizontal interno)
                      HorasLiveChart(dados: data.horasLivePorDia),
                      const SizedBox(height: AppSpacing.x2l),

                      // Ranking (full width)
                      AnalyticsRankingList(items: data.rankingApresentadores),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    dynamic filtros,
    AsyncValue clientesAsync,
  ) {
    final clientes = clientesAsync.valueOrNull ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.sidebarBorder)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;

          final clienteDropdown = DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: filtros.clienteId,
              hint: const Text('Todos os clientes'),
              isDense: true,
              borderRadius: BorderRadius.circular(AppRadius.md),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todos os clientes'),
                ),
                ...clientes.map((c) => DropdownMenuItem<String?>(
                      value: c.id,
                      child: Text(c.nome, overflow: TextOverflow.ellipsis),
                    )),
              ],
              onChanged: ref.read(dashboardFiltrosProvider.notifier).setClienteId,
            ),
          );

          final mesField = SizedBox(
            width: 120,
            child: TextField(
              controller: mesAnoCtrl,
              decoration: InputDecoration(
                labelText: 'Mês',
                hintText: 'YYYY-MM',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              ),
              style: AppTypography.bodySmall,
              onSubmitted: onMesAnoSubmitted,
              textInputAction: TextInputAction.done,
            ),
          );

          final refreshBtn = IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Atualizar',
            onPressed: () => ref.read(analyticsDashboardProvider.notifier).refresh(),
          );

          if (isWide) {
            return Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Painel de Analytics', style: AppTypography.h2.copyWith(fontSize: 18)),
                    Text('Análise avançada de faturamento e performance',
                        style: AppTypography.caption.copyWith(color: AppColors.gray500)),
                  ],
                ),
                const Spacer(),
                mesField,
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.sidebarBorder),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: clienteDropdown,
                ),
                refreshBtn,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analytics', style: AppTypography.h2.copyWith(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.sidebarBorder),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: clienteDropdown,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  mesField,
                  refreshBtn,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────
// KPI Cards
// ──────────────────────────────────────────────

class _KpiCardsRow extends StatelessWidget {
  final dynamic data;

  const _KpiCardsRow({required this.data});

  static final _currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _KpiCard(
          icon: Icons.attach_money_rounded,
          label: 'Faturamento Total',
          value: _currency.format(data.kpis.faturamentoTotal),
          color: AppColors.successGreen,
        ),
        _KpiCard(
          icon: Icons.confirmation_number_rounded,
          label: 'Total de Vendas',
          value: '${data.kpis.totalVendas}',
          color: AppColors.infoBlue,
        ),
        _KpiCard(
          icon: Icons.trending_up_rounded,
          label: 'Ticket Médio',
          value: _currency.format(data.kpis.ticketMedio),
          color: AppColors.primaryOrange,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(color: AppColors.gray500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
