import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../design_system/design_system.dart';
import '../../providers/cliente_dashboard_provider.dart'
    show
        ClienteDashboard,
        ClientePeriod,
        HorarioVenda,
        SerieMensal,
        clienteDashboardProvider,
        clientePeriodProvider;
import '../../providers/cliente_lives_provider.dart'
    show ClienteLive, ClienteLivesResponse, clienteLivesProvider;
import '../../routes/app_routes.dart';
import '../../widgets/metric_card.dart';

class ClienteDashboardScreen extends ConsumerWidget {
  const ClienteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(clientePeriodProvider);
    final dashAsync = ref.watch(clienteDashboardProvider);
    final livesAsync = ref.watch(clienteLivesProvider);

    return AppScreenScaffold(
      currentRoute: AppRoutes.clienteDashboard,
      eyebrow: 'DASHBOARD',
      title: 'Dashboard do Parceiro',
      subtitle: 'KPIs detalhados e desempenho por live',
      actions: [_DashboardPeriodSelector(period: period)],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: dashAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.x10),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => _DashboardErrorState(error: error),
          data: (dashboard) => _DashboardContent(
            dashboard: dashboard,
            livesAsync: livesAsync,
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final ClienteDashboard dashboard;
  final AsyncValue<ClienteLivesResponse> livesAsync;

  const _DashboardContent({
    required this.dashboard,
    required this.livesAsync,
  });

  @override
  Widget build(BuildContext context) {
    final invested = dashboard.valorInvestidoMes > 0
        ? dashboard.valorInvestidoMes
        : dashboard.valorInvestidoLives;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dashboard.liveAtiva != null) ...[
          _ActiveLiveCard(dashboard: dashboard),
          const SizedBox(height: AppSpacing.x6),
        ],
        Wrap(
          spacing: AppSpacing.x4,
          runSpacing: AppSpacing.x4,
          children: [
            _MetricBox(
              child: MetricCard(
                label: 'GMV',
                value: _Formatters.currency.format(dashboard.faturamentoMes),
                icon: Icons.payments_rounded,
                iconColor: AppColors.primary,
                subtitle: '${dashboard.totalLives} lives no período',
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'ITENS VENDIDOS',
                value: '${dashboard.volumeVendas}',
                icon: Icons.inventory_2_rounded,
                iconColor: AppColors.info,
                subtitle: '${dashboard.pedidos} pedidos',
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'LIVES',
                value: '${dashboard.totalLives}',
                icon: Icons.live_tv_rounded,
                iconColor: AppColors.primaryLight,
                subtitle: '${dashboard.horasLive.toStringAsFixed(1)} horas',
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'ROAS',
                value: dashboard.roas.toStringAsFixed(2),
                icon: Icons.show_chart_rounded,
                iconColor: AppColors.success,
                subtitle: 'GMV por valor investido',
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'VALOR INVESTIDO',
                value: _Formatters.currency.format(invested),
                icon: Icons.savings_rounded,
                iconColor: AppColors.warning,
                subtitle: 'Custo proporcional do período',
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'VIEWERS',
                value: '${dashboard.viewers}',
                icon: Icons.visibility_rounded,
                iconColor: AppColors.info,
                subtitle: 'Audiência acumulada',
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'COMENTÁRIOS',
                value: '${dashboard.comentarios}',
                icon: Icons.forum_rounded,
                iconColor: AppColors.primaryLight,
                subtitle: '${dashboard.likes} likes no período',
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'SHARES',
                value: '${dashboard.shares}',
                icon: Icons.share_rounded,
                iconColor: AppColors.lilac,
                subtitle: 'Pedidos: ${dashboard.pedidos}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x8),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1160;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SalesWindowsCard(
                      horarios: dashboard.melhoresHorariosVenda,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x4),
                  Expanded(
                    child: _MonthlySeriesCard(series: dashboard.seriesMensais),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _SalesWindowsCard(horarios: dashboard.melhoresHorariosVenda),
                const SizedBox(height: AppSpacing.x4),
                _MonthlySeriesCard(series: dashboard.seriesMensais),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.x8),
        _InsightGrid(dashboard: dashboard),
        const SizedBox(height: AppSpacing.x8),
        livesAsync.when(
          loading: () => const _SectionLoading(
            title: 'Lives detalhadas',
            subtitle: 'Carregando métricas por live',
          ),
          error: (error, _) => _SectionError(
            title: 'Lives detalhadas',
            message: 'Não foi possível carregar as lives: $error',
          ),
          data: (response) => _DetailedLivesSection(response: response),
        ),
      ],
    );
  }
}

class _DashboardPeriodSelector extends ConsumerWidget {
  static final DateFormat _periodFormat = DateFormat.yMMMM('pt_BR');

  final ClientePeriod period;

  const _DashboardPeriodSelector({required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = _periodFormat.format(DateTime(period.ano, period.mes));

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: AppSpacing.x1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Mês anterior',
            onPressed: () => ref
                .read(clienteDashboardProvider.notifier)
                .setPeriodo(period.previous()),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          SizedBox(
            width: 140,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Próximo mês',
            onPressed: () => ref
                .read(clienteDashboardProvider.notifier)
                .setPeriodo(period.next()),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () =>
                ref.read(clienteDashboardProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _ActiveLiveCard extends StatelessWidget {
  final ClienteDashboard dashboard;

  const _ActiveLiveCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final live = dashboard.liveAtiva!;

    return AppCard(
      borderColor: AppColors.success,
      padding: const EdgeInsets.all(AppSpacing.x6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3,
                  vertical: AppSpacing.x1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'AO VIVO',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Text(
                'Cabine ${live.cabineNumero.toString().padLeft(2, '0')}',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${live.duracaoMin} min',
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x5),
          Wrap(
            spacing: AppSpacing.x6,
            runSpacing: AppSpacing.x4,
            children: [
              _LivePulseMetric(
                icon: Icons.payments_rounded,
                label: 'GMV atual',
                value: _Formatters.currency.format(live.gmvAtual),
              ),
              _LivePulseMetric(
                icon: Icons.visibility_rounded,
                label: 'Viewers',
                value: '${live.viewerCount}',
              ),
              _LivePulseMetric(
                icon: Icons.shopping_bag_rounded,
                label: 'Pedidos',
                value: '${live.pedidos}',
              ),
              _LivePulseMetric(
                icon: Icons.favorite_rounded,
                label: 'Likes',
                value: '${live.likes}',
              ),
              _LivePulseMetric(
                icon: Icons.chat_bubble_rounded,
                label: 'Comentários',
                value: '${live.comentarios}',
              ),
              _LivePulseMetric(
                icon: Icons.share_rounded,
                label: 'Shares',
                value: '${live.shares}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LivePulseMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LivePulseMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.primary),
              const SizedBox(width: AppSpacing.x2),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final Widget child;

  const _MetricBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 220, child: child);
  }
}

class _SalesWindowsCard extends StatelessWidget {
  final List<HorarioVenda> horarios;

  const _SalesWindowsCard({required this.horarios});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.access_time_filled_rounded,
            title: 'Melhores horários de venda',
            subtitle: 'Faixas com maior GMV por hora do dia',
          ),
          const SizedBox(height: AppSpacing.x4),
          if (horarios.isEmpty)
            const _EmptyHint(
              message:
                  'Sem vendas suficientes para montar o ranking do período.',
            )
          else
            ...horarios.map(
              (horario) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x3),
                child: _HorarioRow(
                  horario: horario,
                  maxGmv: horarios.fold<double>(
                    0,
                    (max, item) => item.gmvTotal > max ? item.gmvTotal : max,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HorarioRow extends StatelessWidget {
  final HorarioVenda horario;
  final double maxGmv;

  const _HorarioRow({
    required this.horario,
    required this.maxGmv,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxGmv <= 0 ? 0.0 : (horario.gmvTotal / maxGmv);

    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            horario.label,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.borderLight,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.x3),
        SizedBox(
          width: 96,
          child: Text(
            _Formatters.currency.format(horario.gmvTotal),
            textAlign: TextAlign.right,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthlySeriesCard extends StatelessWidget {
  final List<SerieMensal> series;

  const _MonthlySeriesCard({required this.series});

  @override
  Widget build(BuildContext context) {
    final ordered = [...series]..sort((a, b) {
        final aKey = a.ano * 100 + a.mes;
        final bKey = b.ano * 100 + b.mes;
        return aKey.compareTo(bKey);
      });
    final visible =
        ordered.length > 6 ? ordered.sublist(ordered.length - 6) : ordered;
    final maxGmv = visible.fold<double>(
      0,
      (max, item) => item.gmvTotal > max ? item.gmvTotal : max,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.timeline_rounded,
            title: 'Evolução mensal',
            subtitle: 'GMV e horas de live nos meses mais recentes',
          ),
          const SizedBox(height: AppSpacing.x4),
          if (visible.isEmpty)
            const _EmptyHint(
              message:
                  'Ainda não há série mensal disponível para este parceiro.',
            )
          else
            ...visible.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x4),
                child: _MonthlySeriesRow(
                  item: item,
                  maxGmv: maxGmv,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthlySeriesRow extends StatelessWidget {
  final SerieMensal item;
  final double maxGmv;

  const _MonthlySeriesRow({
    required this.item,
    required this.maxGmv,
  });

  @override
  Widget build(BuildContext context) {
    final label = '${item.mes.toString().padLeft(2, '0')}/${item.ano}';
    final progress = maxGmv <= 0 ? 0.0 : (item.gmvTotal / maxGmv);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              _Formatters.currency.format(item.gmvTotal),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: AppColors.borderLight,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        Text(
          '${item.totalLives} lives • ${item.horasLive.toStringAsFixed(1)}h • ROAS ${item.roas.toStringAsFixed(2)}',
          style: AppTypography.caption.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InsightGrid extends StatelessWidget {
  final ClienteDashboard dashboard;

  const _InsightGrid({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final bestMonth = dashboard.seriesMensais.fold<SerieMensal?>(
      null,
      (best, current) {
        if (best == null || current.gmvTotal > best.gmvTotal) {
          return current;
        }
        return best;
      },
    );
    final gmvPerLive = dashboard.totalLives == 0
        ? 0.0
        : dashboard.faturamentoMes / dashboard.totalLives;
    final ordersPerLive = dashboard.totalLives == 0
        ? 0.0
        : dashboard.pedidos / dashboard.totalLives;
    final engagementTotal =
        dashboard.comentarios + dashboard.likes + dashboard.shares;

    return Wrap(
      spacing: AppSpacing.x4,
      runSpacing: AppSpacing.x4,
      children: [
        _InsightCard(
          icon: Icons.rocket_launch_rounded,
          title: 'Pico do período',
          value: bestMonth == null
              ? _Formatters.currency.format(0)
              : _Formatters.currency.format(bestMonth.gmvTotal),
          description: bestMonth == null
              ? 'Sem pico identificado na série mensal.'
              : 'Melhor mês: ${bestMonth.mes.toString().padLeft(2, '0')}/${bestMonth.ano}.',
        ),
        _InsightCard(
          icon: Icons.bar_chart_rounded,
          title: 'GMV por live',
          value: _Formatters.currency.format(gmvPerLive),
          description:
              '${dashboard.totalLives} lives, média de ${ordersPerLive.toStringAsFixed(1)} pedidos por live.',
        ),
        _InsightCard(
          icon: Icons.groups_rounded,
          title: 'Engajamento',
          value: '$engagementTotal',
          description:
              '${dashboard.likes} likes, ${dashboard.shares} shares e ${dashboard.comentarios} comentários.',
        ),
        _InsightCard(
          icon: Icons.visibility_rounded,
          title: 'Audiência média',
          value: dashboard.totalLives == 0
              ? '0'
              : (dashboard.viewers / dashboard.totalLives).toStringAsFixed(0),
          description: '${dashboard.viewers} viewers acumulados no período.',
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String description;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(icon: icon, title: title, subtitle: null),
            const SizedBox(height: AppSpacing.x4),
            Text(
              value,
              style: AppTypography.h2.copyWith(fontSize: 28),
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              description,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailedLivesSection extends StatelessWidget {
  final ClienteLivesResponse response;

  const _DetailedLivesSection({required this.response});

  @override
  Widget build(BuildContext context) {
    final resumo = response.resumo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.live_tv_rounded,
          title: 'Lives detalhadas',
          subtitle: 'Desempenho individual de cada transmissão',
        ),
        const SizedBox(height: AppSpacing.x4),
        Wrap(
          spacing: AppSpacing.x4,
          runSpacing: AppSpacing.x4,
          children: [
            _MetricBox(
              child: MetricCard(
                label: 'LIVES',
                value: '${resumo.totalLives}',
                icon: Icons.video_library_rounded,
                iconColor: AppColors.primary,
                subtitle: '${resumo.horasLive.toStringAsFixed(1)}h',
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'VIEWERS',
                value: '${resumo.viewerCount}',
                icon: Icons.visibility_rounded,
                iconColor: AppColors.info,
                subtitle: '${resumo.totalOrders} pedidos',
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'COMENTÁRIOS',
                value: '${resumo.commentsCount}',
                icon: Icons.forum_rounded,
                iconColor: AppColors.primaryLight,
                subtitle: '${resumo.likesCount} likes',
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'INVESTIDO',
                value: _Formatters.currency.format(resumo.valorInvestidoLives),
                icon: Icons.savings_rounded,
                iconColor: AppColors.warning,
                subtitle: 'ROAS ${resumo.roas.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x6),
        if (response.lives.isEmpty)
          const _EmptyHint(
            message: 'Nenhuma live registrada neste período.',
          )
        else
          Column(
            children: response.lives
                .map(
                  (live) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.x4),
                    child: _LiveDetailCard(live: live),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _LiveDetailCard extends StatelessWidget {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  final ClienteLive live;

  const _LiveDetailCard({required this.live});

  @override
  Widget build(BuildContext context) {
    final startedAt = live.iniciadoEm == null
        ? 'Sem início'
        : _dateFormat.format(live.iniciadoEm!.toLocal());
    final statusLabel = live.encerradoEm == null ? 'em andamento' : 'encerrada';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  live.streamerNome?.isNotEmpty == true
                      ? live.streamerNome!
                      : 'Live ${live.id}',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3,
                  vertical: AppSpacing.x1,
                ),
                decoration: BoxDecoration(
                  color: live.encerradoEm == null
                      ? AppColors.primarySofter
                      : AppColors.successBg,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  statusLabel,
                  style: AppTypography.caption.copyWith(
                    color: live.encerradoEm == null
                        ? AppColors.primary
                        : AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            startedAt,
            style: AppTypography.caption.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.x4),
          Wrap(
            spacing: AppSpacing.x5,
            runSpacing: AppSpacing.x3,
            children: [
              _LiveMetric(label: 'Duração', value: '${live.duracaoMin} min'),
              _LiveMetric(
                label: 'GMV',
                value: _Formatters.currency.format(live.gmv),
                highlight: true,
              ),
              _LiveMetric(label: 'Itens', value: '${live.itensVendidos}'),
              _LiveMetric(label: 'Pedidos', value: '${live.totalOrders}'),
              _LiveMetric(label: 'Viewers', value: '${live.viewerCount}'),
              _LiveMetric(
                label: 'Comentários',
                value: '${live.commentsCount}',
              ),
              _LiveMetric(label: 'Likes', value: '${live.likesCount}'),
              _LiveMetric(label: 'Shares', value: '${live.sharesCount}'),
              _LiveMetric(label: 'ROAS', value: live.roas.toStringAsFixed(2)),
              _LiveMetric(
                label: 'Investido',
                value: _Formatters.currency.format(live.valorInvestido),
              ),
            ],
          ),
          if (live.topProduto?.isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.x4),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.x2),
                Expanded(
                  child: Text(
                    'Top produto: ${live.topProduto}',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LiveMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _LiveMetric({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.primary : context.colors.textPrimary;

    return SizedBox(
      width: 118,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: context.colors.bgMuted,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String message;

  const _EmptyHint({required this.message});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.flat,
      child: Text(
        message,
        style: AppTypography.bodySmall.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

class _SectionLoading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionLoading({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.pending_rounded,
            title: title,
            subtitle: subtitle,
          ),
          const SizedBox(height: AppSpacing.x6),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  final String title;
  final String message;

  const _SectionError({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.error_outline_rounded,
            title: title,
            subtitle: null,
          ),
          const SizedBox(height: AppSpacing.x3),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardErrorState extends ConsumerWidget {
  final Object error;

  const _DashboardErrorState({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Erro ao carregar dashboard',
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              '$error',
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x4),
            AppPrimaryButton(
              onPressed: () =>
                  ref.read(clienteDashboardProvider.notifier).refresh(),
              label: 'Tentar novamente',
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _Formatters {
  static final NumberFormat currency = NumberFormat.simpleCurrency(
    locale: 'pt_BR',
  );
}
