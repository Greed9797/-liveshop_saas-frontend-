import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/analytics_dashboard_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/clientes_provider.dart';
import '../../routes/app_routes.dart';
import '../../design_system/design_system.dart';
import '../../widgets/analytics_ranking_list.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/charts/gmv_mensal_chart.dart';
import '../../widgets/charts/horas_live_chart.dart';
import '../../widgets/charts/vendas_mensal_chart.dart';
import '../../widgets/heatmap_widget.dart';
import '../../widgets/prime_time_chart.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  final _mesAnoCtrl = TextEditingController();
  bool _isAno = true;

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

  void _onMesAnoSubmitted(String value) {
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
        onMesAnoSubmitted: _onMesAnoSubmitted,
        isAno: _isAno,
        onIsAnoChanged: (v) => setState(() => _isAno = v),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Body
// ──────────────────────────────────────────────

class _AnalyticsDashboardBody extends ConsumerWidget {
  final TextEditingController mesAnoCtrl;
  final void Function(String) onMesAnoSubmitted;
  final bool isAno;
  final ValueChanged<bool> onIsAnoChanged;

  const _AnalyticsDashboardBody({
    required this.mesAnoCtrl,
    required this.onMesAnoSubmitted,
    required this.isAno,
    required this.onIsAnoChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtros = ref.watch(dashboardFiltrosProvider);
    final dashAsync = ref.watch(analyticsDashboardProvider);
    final clientesAsync = ref.watch(clientesProvider);

    return Column(
      children: [
        _buildHeader(context, ref, filtros, clientesAsync, isAno, onIsAnoChanged),
        Expanded(
          child: AppGradientBackground(
            child: dashAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.x6),
                  child: AppCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                        const SizedBox(height: AppSpacing.x3),
                        Text('Erro ao carregar dados', style: AppTypography.bodyMedium),
                        const SizedBox(height: AppSpacing.x1),
                        Text(
                          '$e',
                          style: AppTypography.caption.copyWith(color: context.colors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        AppSecondaryButton(
                          onPressed: () => ref.read(analyticsDashboardProvider.notifier).refresh(),
                          label: 'Tentar novamente',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              data: (data) => LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= AppBreakpoints.tablet;
                  final hPad = constraints.maxWidth >= AppBreakpoints.desktop
                      ? AppSpacing.x8
                      : AppSpacing.x4;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(hPad, AppSpacing.x6, hPad, AppSpacing.x8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── KPI Cards ──
                        _KpiCardsRow(data: data),
                        const SizedBox(height: AppSpacing.x6),

                        // ── Gráficos de faturamento e vendas ──
                        _SectionHeader(
                          title: 'Desempenho Mensal',
                          subtitle: 'GMV e volume de lives nos últimos 12 meses.',
                        ),
                        const SizedBox(height: AppSpacing.x3),
                        if (isDesktop)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ChartCard(
                                    title: 'Faturamento Mensal',
                                    sub: 'Últimos 12 meses',
                                    child: GmvMensalChart(dados: data.faturamentoMensal),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.x3),
                                Expanded(
                                  child: ChartCard(
                                    title: 'Vendas Mensais',
                                    sub: 'Últimos 12 meses',
                                    child: VendasMensalChart(dados: data.vendasMensal),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: [
                              ChartCard(
                                title: 'Faturamento Mensal',
                                sub: 'Últimos 12 meses',
                                child: GmvMensalChart(dados: data.faturamentoMensal),
                              ),
                              const SizedBox(height: AppSpacing.x3),
                              ChartCard(
                                title: 'Vendas Mensais',
                                sub: 'Últimos 12 meses',
                                child: VendasMensalChart(dados: data.vendasMensal),
                              ),
                            ],
                          ),
                        const SizedBox(height: AppSpacing.x6),

                        // ── Horas de live ──
                        _SectionHeader(
                          title: 'Horas de Live por Dia',
                          subtitle: 'Distribuição de horas nos últimos 30 dias.',
                        ),
                        const SizedBox(height: AppSpacing.x3),
                        ChartCard(
                          title: 'Horas de Live',
                          sub: 'Últimos 30 dias',
                          child: HorasLiveChart(dados: data.horasLivePorDia),
                        ),
                        const SizedBox(height: AppSpacing.x6),

                        // ── Ranking ──
                        _SectionHeader(
                          title: 'Top Apresentadores',
                          subtitle: 'Ranking por GMV no período selecionado.',
                        ),
                        const SizedBox(height: AppSpacing.x3),
                        AnalyticsRankingList(items: data.rankingApresentadores),
                        const SizedBox(height: AppSpacing.x6),

                        // ── Inteligência Comercial ──
                        _SectionHeader(
                          title: 'Inteligência Comercial',
                          subtitle: 'Prime time e heatmap de conversão por horário.',
                        ),
                        const SizedBox(height: AppSpacing.x3),
                        const _IntelComercialSection(),
                      ],
                    ),
                  );
                },
              ),
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
    bool isAno,
    ValueChanged<bool> onIsAnoChanged,
  ) {
    final clienteOptions = clientesAsync.valueOrNull ?? [];
    void showClienteDropdown(BuildContext context) {
      if (clienteOptions.isEmpty) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Selecionar Cliente'),
          content: SizedBox(
            width: 200,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: clienteOptions.length,
              itemBuilder: (ctx, i) {
                final c = clienteOptions[i];
                return ListTile(
                  title: Text(c.nome as String),
                  onTap: () {
                    ref.read(dashboardFiltrosProvider.notifier).setClienteId(c.id as String);
                    Navigator.of(ctx).pop();
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.x6, AppSpacing.x4, AppSpacing.x6, AppSpacing.x4),
      decoration: BoxDecoration(
        color: context.colors.bgCard,
        border: Border(bottom: BorderSide(color: context.colors.borderSubtle)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 750;

          // Eyebrow row
          final eyebrowRow = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 18, height: 1, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'PERFORMANCE COMERCIAL',
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  letterSpacing: 0.16,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textMuted,
                ),
              ),
            ],
          );

          // Title row
          final titleRow = Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Painel de ',
                  style: AppTypography.h1.copyWith(
                    fontSize: isWide ? 26 : 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'Analytics',
                  style: AppTypography.h1.copyWith(
                    fontSize: isWide ? 28 : 26,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );

          // Filter controls row
          final filterRow = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppGhostButton(
                label: isAno ? 'Ano' : 'Mês',
                onPressed: () => onIsAnoChanged(!isAno),
              ),
              const SizedBox(width: AppSpacing.x2),
              AppGhostButton(
                label: 'Cliente',
                icon: Icons.keyboard_arrow_down,
                onPressed: () => showClienteDropdown(context),
              ),
              const SizedBox(width: AppSpacing.x2),
              IconButton(
                icon: Icon(Icons.refresh, color: context.colors.textSecondary),
                tooltip: 'Atualizar',
                onPressed: () => ref.read(analyticsDashboardProvider.notifier).refresh(),
              ),
            ],
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      eyebrowRow,
                      const SizedBox(height: 6),
                      titleRow,
                      const SizedBox(height: 2),
                      Text('Análise de faturamento e performance',
                          style: AppTypography.caption.copyWith(color: context.colors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.x4),
                filterRow,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              eyebrowRow,
              const SizedBox(height: 6),
              titleRow,
              const SizedBox(height: AppSpacing.x3),
              filterRow,
            ],
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Section header
// ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h3.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(subtitle,
            style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary)),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// KPI Cards
// ──────────────────────────────────────────────

class _KpiCardsRow extends StatelessWidget {
  final dynamic data;

  const _KpiCardsRow({required this.data});

  static final _currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final cards = [
          BigKpi(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Faturamento Total',
            value: _currencyFmt.format(data.kpis.faturamentoTotal),
            delta: '+12% vs mês anterior',
            deltaTone: DeltaTone.up,
          ),
          BigKpi(
            icon: Icons.shopping_cart_outlined,
            label: 'Total de Vendas',
            value: '${data.kpis.totalVendas} vendas',
            delta: '+8% vs mês anterior',
            deltaTone: DeltaTone.up,
          ),
          BigKpi(
            icon: Icons.trending_up,
            label: 'Ticket Médio',
            value: _currencyFmt.format(data.kpis.ticketMedio),
            delta: '-3% vs mês anterior',
            deltaTone: DeltaTone.down,
          ),
        ];

        if (isMobile) {
          return Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(child: cards[1]),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x3),
              cards[2],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: AppSpacing.x3),
              Expanded(child: cards[1]),
              const SizedBox(width: AppSpacing.x3),
              Expanded(child: cards[2]),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
// Inteligência Comercial — PrimeTime + Heatmap
// ──────────────────────────────────────────────

class _IntelComercialSection extends ConsumerWidget {
  const _IntelComercialSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(franqueadoAnalyticsResumoProvider);

    return analyticsAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppCard(
        child: Center(
          child: Text(
            'Erro ao carregar dados',
            style: AppTypography.caption.copyWith(color: context.colors.textSecondary),
          ),
        ),
      ),
      data: (analytics) {
        // Build PrimeTimeChart bars from heatmapHorarios (hora 6–21)
        final horarios = analytics.heatmapHorarios;
        final maxGmv = horarios.isEmpty
            ? 0.0
            : horarios.map((h) => h.gmvTotal).reduce((a, b) => a > b ? a : b);
        final avgGmv = horarios.isEmpty
            ? 0.0
            : horarios.map((h) => h.gmvTotal).reduce((a, b) => a + b) /
                horarios.length;

        double gmvForHora(List horarios, int hora) {
          for (final h in horarios) {
            if (h.hora == hora) return h.gmvTotal;
          }
          return 0.0;
        }

        final primeTimeBars = List.generate(16, (i) {
          final hora = i + 6; // 6h to 21h
          final gmv = gmvForHora(horarios, hora);
          return PrimeTimeBar(
            label: '${hora}h',
            value: gmv,
            isActive: maxGmv > 0 && gmv >= avgGmv,
          );
        });

        // Build HeatmapWidget matrix (7 days × 6 time slots)
        // Since API provides hourly aggregates without day-of-week, distribute evenly
        final heatmapMatrix = List.generate(7, (day) {
          return List.generate(6, (slot) {
            final hora = slot == 0 ? 6 : (slot == 1 ? 9 : (slot == 2 ? 12 : (slot == 3 ? 15 : (slot == 4 ? 18 : 21))));
            final gmv = gmvForHora(horarios, hora);
            return maxGmv > 0 ? (gmv / maxGmv) : 0.0;
          });
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= AppBreakpoints.tablet;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ChartCard(
                      title: 'Horários de Pico',
                      sub: 'GMV por horário do dia',
                      child: PrimeTimeChart(bars: primeTimeBars, height: 200),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(
                    child: ChartCard(
                      title: 'Conversão por Dia',
                      sub: 'Heatmap de performance',
                      child: HeatmapWidget(
                        matrix: heatmapMatrix,
                        rowLabels: const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
                        colLabels: const ['6h', '9h', '12h', '15h', '18h', '21h'],
                        height: 200,
                        cellSize: 20,
                      ),
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                ChartCard(
                  title: 'Horários de Pico',
                  sub: 'GMV por horário do dia',
                  child: PrimeTimeChart(bars: primeTimeBars, height: 200),
                ),
                const SizedBox(height: AppSpacing.x3),
                ChartCard(
                  title: 'Conversão por Dia',
                  sub: 'Heatmap de performance',
                  child: HeatmapWidget(
                    matrix: heatmapMatrix,
                    rowLabels: const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
                    colLabels: const ['6h', '9h', '12h', '15h', '18h', '21h'],
                    height: 200,
                    cellSize: 20,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
