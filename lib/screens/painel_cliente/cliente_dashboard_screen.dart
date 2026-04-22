import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/cliente_dashboard_provider.dart';
import '../../providers/cliente_lives_provider.dart';
import '../../routes/app_routes.dart';
import '../../design_system/design_system.dart';
import '../../widgets/charts/gmv_mensal_chart.dart';
import '../../widgets/charts/heatmap_horarios_chart.dart';
import '../../widgets/prime_time_chart.dart';

class ClienteDashboardScreen extends ConsumerStatefulWidget {
  const ClienteDashboardScreen({super.key});

  @override
  ConsumerState<ClienteDashboardScreen> createState() =>
      _ClienteDashboardScreenState();
}

class _ClienteDashboardScreenState
    extends ConsumerState<ClienteDashboardScreen> {
  late int _mes;
  late int _ano;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _mes = now.month;
    _ano = now.year;
  }

  void _prevMonth() {
    setState(() {
      if (_mes == 1) {
        _mes = 12;
        _ano--;
      } else {
        _mes--;
      }
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_ano < now.year || (_ano == now.year && _mes < now.month)) {
      setState(() {
        if (_mes == 12) {
          _mes = 1;
          _ano++;
        } else {
          _mes++;
        }
      });
    }
  }

  String get _periodLabel {
    final date = DateTime(_ano, _mes);
    return DateFormat('MMMM yyyy', 'pt_BR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(clienteDashboardProvider);
    final livesAsync =
        ref.watch(clienteLivesProvider((mes: _mes, ano: _ano)));

    return AppScreenScaffold(
      currentRoute: AppRoutes.clienteDashboard,
      eyebrow: 'ANALYTICS',
      title: 'Seu Dashboard',
      titleSerif: true,
      actions: [
        _PeriodSelector(
          label: _periodLabel,
          onPrev: _prevMonth,
          onNext: _nextMonth,
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── KPI Strip ──
            dashAsync.when(
              loading: () => const _KpiSkeleton(),
              error: (_, __) => const SizedBox.shrink(),
              data: (d) => _KpiStrip(dashboard: d),
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Evolução de Faturamento ──
            dashAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (d) => d.faturamentoPorMes.isEmpty
                  ? const SizedBox.shrink()
                  : ChartCard(
                      title: 'Evolução de Faturamento',
                      sub: 'GMV mensal dos últimos 12 meses',
                      child: GmvMensalChart(dados: d.faturamentoPorMes),
                    ),
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Top Horários ──
            dashAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (d) => d.topHorarios.isEmpty
                  ? const SizedBox.shrink()
                  : ChartCard(
                      title: 'Melhores Horários',
                      sub: 'GMV por hora do dia — últimos 90 dias',
                      child: HeatmapHorariosChart(dados: d.topHorarios),
                    ),
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Top Dias da Semana ──
            dashAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (d) {
                if (d.topDiasSemana.isEmpty) return const SizedBox.shrink();
                final maxGmv = d.topDiasSemana
                    .map((t) => t.gmvTotal)
                    .reduce((a, b) => a > b ? a : b);
                final avgGmv = d.topDiasSemana
                        .map((t) => t.gmvTotal)
                        .reduce((a, b) => a + b) /
                    d.topDiasSemana.length;
                const dayLabels = [
                  'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'
                ];
                final bars = d.topDiasSemana
                    .map((t) => PrimeTimeBar(
                          label: dayLabels[t.diaSemana],
                          value: t.gmvTotal,
                          isActive: maxGmv > 0 && t.gmvTotal >= avgGmv,
                        ))
                    .toList();
                return ChartCard(
                  title: 'Melhores Dias da Semana',
                  sub: 'GMV por dia — últimos 90 dias',
                  child: PrimeTimeChart(bars: bars, height: 160),
                );
              },
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Lives Detalhadas ──
            AppSectionHeader(
              title: 'Lives Detalhadas',
              subtitle: 'Dados de engajamento e resultado por live.',
            ),
            const SizedBox(height: AppSpacing.x3),
            livesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(
                'Erro ao carregar lives: $e',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              data: (lives) {
                if (lives.isEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.x8),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.videocam_off_rounded,
                              size: 40,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.3)),
                          const SizedBox(height: AppSpacing.x3),
                          Text(
                            'Nenhuma live encontrada neste período.',
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // Compute custo_pacote from dashboard (needed for per-live ROAS)
                final custoPacote =
                    ref.read(clienteDashboardProvider).valueOrNull?.pacote?.valor ?? 0.0;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lives.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.x3),
                  itemBuilder: (context, i) => _LiveDetalheCard(
                    live: lives[i],
                    custoPacote: custoPacote,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.x8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Period Selector
// ─────────────────────────────────────────────
class _PeriodSelector extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PeriodSelector({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppGhostButton(onPressed: onPrev, label: '', icon: Icons.chevron_left_rounded),
        const SizedBox(width: AppSpacing.x1),
        Text(label,
            style:
                AppTypography.label.copyWith(color: AppColors.textSecondary)),
        const SizedBox(width: AppSpacing.x1),
        AppGhostButton(onPressed: onNext, label: '', icon: Icons.chevron_right_rounded),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// KPI Strip
// ─────────────────────────────────────────────
class _KpiStrip extends StatelessWidget {
  static final _currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
  final ClienteDashboard dashboard;

  const _KpiStrip({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final roasStr = dashboard.roasMes != null
        ? '${dashboard.roasMes!.toStringAsFixed(1)}x'
        : '—';

    return Wrap(
      spacing: AppSpacing.x3,
      runSpacing: AppSpacing.x3,
      children: [
        _kpiBox(
          icon: Icons.monetization_on_rounded,
          label: 'Faturamento GMV',
          value: _currency.format(dashboard.faturamentoMes),
          delta: '${dashboard.crescimentoPct >= 0 ? '+' : ''}${dashboard.crescimentoPct}% vs mês anterior',
          deltaTone: dashboard.crescimentoPct >= 0 ? DeltaTone.up : DeltaTone.down,
        ),
        _kpiBox(
          icon: Icons.bar_chart_rounded,
          label: 'ROAS Acumulado',
          value: roasStr,
          delta: dashboard.roasMes != null
              ? 'Retorno sobre investimento'
              : 'Configure um pacote para ver ROAS',
          deltaTone: DeltaTone.neutral,
        ),
        _kpiBox(
          icon: Icons.schedule_rounded,
          label: 'Horas de Live',
          value: '${dashboard.horasMes.toStringAsFixed(1)}h',
          delta: dashboard.pacote != null && dashboard.pacote!.valor > 0
              ? '${_currency.format(dashboard.pacote!.valor)} investidos'
              : null,
          deltaTone: DeltaTone.neutral,
        ),
      ],
    );
  }

  Widget _kpiBox({
    required IconData icon,
    required String label,
    required String value,
    String? delta,
    DeltaTone deltaTone = DeltaTone.neutral,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 280),
      child: BigKpi(
        icon: icon,
        label: label,
        value: value,
        delta: delta,
        deltaTone: deltaTone,
      ),
    );
  }
}

class _KpiSkeleton extends StatelessWidget {
  const _KpiSkeleton();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.x3,
      runSpacing: AppSpacing.x3,
      children: List.generate(
          3,
          (_) => Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.bgBase,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
              )),
    );
  }
}

// ─────────────────────────────────────────────
// Live Detalhe Card
// ─────────────────────────────────────────────
class _LiveDetalheCard extends StatelessWidget {
  static final _currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
  static final _dateFormat = DateFormat('dd/MM/yy HH:mm', 'pt_BR');

  final ClienteLiveDetalhe live;
  final double custoPacote;

  const _LiveDetalheCard({required this.live, required this.custoPacote});

  @override
  Widget build(BuildContext context) {
    final dateStr = live.iniciadoEm.isNotEmpty
        ? _dateFormat.format(DateTime.tryParse(live.iniciadoEm)?.toLocal() ??
            DateTime.now())
        : '—';

    final roasStr = custoPacote > 0 && live.fatGerado > 0
        ? '${(live.fatGerado / custoPacote).toStringAsFixed(1)}x'
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.live_tv_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.x2),
              Text('Cabine ${live.cabineNumero.toString().padLeft(2, '0')}',
                  style: AppTypography.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(dateStr,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: AppSpacing.x2),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x2, vertical: 2),
                decoration: BoxDecoration(
                  color: live.encerradoEm != null
                      ? AppColors.successBg
                      : AppColors.primarySofter,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  live.encerradoEm != null ? 'encerrada' : 'em andamento',
                  style: AppTypography.badge.copyWith(
                    color: live.encerradoEm != null
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x3),

          // Metrics grid
          Wrap(
            spacing: AppSpacing.x4,
            runSpacing: AppSpacing.x3,
            children: [
              _Metric(
                  icon: Icons.schedule_rounded,
                  label: 'Duração',
                  value: '${live.duracaoMin} min'),
              _Metric(
                  icon: Icons.visibility_rounded,
                  label: 'Viewers',
                  value: '${live.viewerCount}'),
              _Metric(
                  icon: Icons.chat_bubble_rounded,
                  label: 'Comentários',
                  value: live.commentsCount > 0 ? '${live.commentsCount}' : '—'),
              _Metric(
                  icon: Icons.favorite_rounded,
                  label: 'Likes',
                  value: live.likesCount > 0 ? '${live.likesCount}' : '—'),
              _Metric(
                  icon: Icons.share_rounded,
                  label: 'Shares',
                  value: live.sharesCount > 0 ? '${live.sharesCount}' : '—'),
              _Metric(
                  icon: Icons.shopping_bag_rounded,
                  label: 'Pedidos',
                  value: '${live.totalOrders}'),
              _Metric(
                  icon: Icons.monetization_on_rounded,
                  label: 'GMV',
                  value: _currency.format(live.fatGerado),
                  highlight: true),
              _Metric(
                  icon: Icons.bar_chart_rounded,
                  label: 'ROAS',
                  value: roasStr,
                  highlight: roasStr != '—'),
            ],
          ),
          if (live.topProduto != null) ...[
            const SizedBox(height: AppSpacing.x3),
            Row(
              children: [
                Icon(Icons.star_rounded,
                    size: 14, color: AppColors.warning),
                const SizedBox(width: AppSpacing.x2),
                Text('Top produto: ',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary)),
                Flexible(
                  child: Text(live.topProduto!,
                      style: AppTypography.caption
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.primary : AppColors.textMuted;
    return SizedBox(
      width: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: highlight ? AppColors.primary : AppColors.textPrimary,
              )),
        ],
      ),
    );
  }
}
