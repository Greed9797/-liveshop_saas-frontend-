import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/cabines/cabine_detail_provider.dart';
import '../../providers/live_stream_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class CabineDetailScreen extends ConsumerStatefulWidget {
  final String cabineId;
  final int cabineNumero;

  const CabineDetailScreen({
    super.key,
    required this.cabineId,
    required this.cabineNumero,
  });

  @override
  ConsumerState<CabineDetailScreen> createState() => _CabineDetailScreenState();
}

class _CabineDetailScreenState extends ConsumerState<CabineDetailScreen>
    with SingleTickerProviderStateMixin {
  static final NumberFormat _currency =
      NumberFormat.simpleCurrency(locale: 'pt_BR');

  late final TabController _tabController;
  Timer? _livePollingTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_syncLivePolling);
  }

  @override
  void dispose() {
    _livePollingTimer?.cancel();
    _tabController
      ..removeListener(_syncLivePolling)
      ..dispose();
    super.dispose();
  }

  void _syncLivePolling() {
    final detail = ref.read(cabineDetailProvider(widget.cabineId)).valueOrNull;
    final shouldPoll = _tabController.index == 0 &&
        detail?.liveAtual != null &&
        !_tabController.indexIsChanging;

    if (shouldPoll) {
      _livePollingTimer ??= Timer.periodic(const Duration(seconds: 30), (_) {
        ref
            .read(cabineDetailProvider(widget.cabineId).notifier)
            .refreshLiveOnly();
      });
      return;
    }

    _livePollingTimer?.cancel();
    _livePollingTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CabineDetailState>>(
        cabineDetailProvider(widget.cabineId), (_, __) {
      _syncLivePolling();
    });

    final detailState = ref.watch(cabineDetailProvider(widget.cabineId));

    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: Text(
          'Cabine ${widget.cabineNumero.toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(cabineDetailProvider(widget.cabineId).notifier)
                .refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Live', icon: Icon(Icons.live_tv_outlined)),
            Tab(text: 'Insights', icon: Icon(Icons.insights_outlined)),
            Tab(text: 'Histórico', icon: Icon(Icons.history_outlined)),
          ],
        ),
      ),
      body: detailState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.dangerRed),
              const SizedBox(height: 16),
              Text('Erro ao carregar dados da cabine: $error',
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref
                    .read(cabineDetailProvider(widget.cabineId).notifier)
                    .refresh(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (detail) => TabBarView(
          controller: _tabController,
          children: [
            _LiveTab(
                liveAtual: detail.liveAtual, cabineNumero: widget.cabineNumero),
            _InsightsTab(historico: detail.historico),
            _HistoricoTab(historico: detail.historico),
          ],
        ),
      ),
    );
  }
}

class _LiveTab extends ConsumerWidget {
  final CabineLiveAtual? liveAtual;
  final int cabineNumero;

  const _LiveTab({required this.liveAtual, required this.cabineNumero});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = liveAtual; // local copy so analyzer can narrow nullability

    // SSE snapshot: dados em tempo real (null quando live não ativa ou stream sem dados ainda)
    final snapshot = live != null
        ? ref.watch(liveStreamProvider(live.liveId)).valueOrNull
        : null;

    // Valores efetivos: SSE tem prioridade, polling é fallback
    final viewerCount   = snapshot?.viewerCount  ?? live?.viewerCount  ?? 0;
    final gmvAtual      = snapshot?.gmv          ?? live?.gmvAtual     ?? 0.0;
    final totalOrders   = snapshot?.totalOrders   ?? live?.totalOrders  ?? 0;
    final likesCount    = snapshot?.likesCount    ?? 0;
    final commentsCount = snapshot?.commentsCount ?? 0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: live == null
          ? _EmptyTabState(
              key: const ValueKey('empty'),
              icon: Icons.videocam_off_outlined,
              title: 'Nenhuma live ativa nesta cabine',
              description:
                  'Quando a cabine entrar em operação ao vivo, as métricas em tempo real aparecerão aqui com atualização a cada 30 segundos.',
            )
          : SingleChildScrollView(
              key: ValueKey(live.liveId),
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              side: const BorderSide(color: AppColors.successGreen, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle,
                                color: AppColors.successGreen, size: 12),
                            SizedBox(width: 8),
                            Text(
                              'AO VIVO AGORA',
                              style: TextStyle(
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.timer_outlined, color: AppColors.gray400),
                      const SizedBox(width: 4),
                      Text(
                        '${live.duracaoMinutos} min',
                        style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _MetricCard(
                        icon: Icons.visibility,
                        iconColor: AppColors.infoBlue,
                        value: '$viewerCount',
                        label: 'Espectadores',
                      ),
                      _MetricCard(
                        icon: Icons.attach_money,
                        iconColor: AppColors.successGreen,
                        value: _CabineDetailScreenState._currency.format(gmvAtual),
                        label: 'GMV da live',
                      ),
                      _MetricCard(
                        icon: Icons.shopping_cart,
                        iconColor: AppColors.primaryOrange,
                        value: '$totalOrders',
                        label: 'Pedidos',
                      ),
                      _MetricCard(
                        icon: Icons.inventory_2_outlined,
                        iconColor: AppColors.lilac,
                        value: live.topProduto != null
                            ? '${live.topProduto!['quantidade']} un'
                            : 'Nenhum',
                        label: live.topProduto != null
                            ? live.topProduto!['nome'] as String
                            : 'Produto mais vendido',
                      ),
                      _MetricCard(
                        icon: Icons.favorite_rounded,
                        iconColor: AppColors.dangerRed,
                        value: '$likesCount',
                        label: 'Curtidas',
                      ),
                      _MetricCard(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: AppColors.infoPurple,
                        value: '$commentsCount',
                        label: 'Comentários',
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      Text(
                        'Cliente: ${live.clienteNome}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Closer: ${live.apresentadorNome}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pulso operacional',
                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cabine ${cabineNumero.toString().padLeft(2, '0')} em monitoramento real-time. Mantenha esta aba aberta para acompanhar audiência, GMV e top produto sem sair do contexto da unidade.',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
            ),  // end SingleChildScrollView
    );  // end AnimatedSwitcher
  }
}

class _InsightsTab extends StatelessWidget {
  final CabineHistorico? historico;

  const _InsightsTab({required this.historico});

  @override
  Widget build(BuildContext context) {
    if (historico == null) {
      return const _EmptyTabState(
        icon: Icons.analytics_outlined,
        title: 'Sem insights para esta cabine',
        description:
            'Assim que a cabine acumular histórico operacional, esta aba mostrará horários fortes, top clientes e evolução de GMV.',
      );
    }

    final topClientes = historico!.topClientes.take(5).toList();
    final melhoresHorarios = historico!.melhoresHorarios.take(5).toList();
    final hasHorarioData = melhoresHorarios.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionCard(
            title: 'Melhores Horários',
            subtitle:
                'Prime time da cabine baseado no GMV médio das lives encerradas.',
            child: hasHorarioData
                ? RepaintBoundary(
                    child: SizedBox(
                      height: 260,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 58,
                                getTitlesWidget: (value, _) => Text(
                                  NumberFormat.compactSimpleCurrency(
                                          locale: 'pt_BR')
                                      .format(value),
                                  style: AppTypography.caption.copyWith(fontSize: 10),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  final index = value.toInt();
                                  if (index < 0 ||
                                      index >= melhoresHorarios.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      melhoresHorarios[index]['hora'] as String,
                                      style: AppTypography.labelSmall,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            for (var i = 0; i < melhoresHorarios.length; i++)
                              BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: (melhoresHorarios[i]['gmv_medio']
                                            as num)
                                        .toDouble(),
                                    width: 18,
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                    color: AppColors.primaryOrange,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const Text(
                    'Ainda não há janelas suficientes para sugerir horários vencedores.'),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Top Clientes da Cabine',
            subtitle: 'Ranking dos parceiros que mais monetizam nesta unidade.',
            child: topClientes.isEmpty
                ? const Text(
                    'Nenhum cliente com histórico de GMV nesta cabine ainda.')
                : Column(
                    children: topClientes.map((cliente) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RankListTile(
                          title: cliente['nome'] as String,
                          subtitle:
                              '${cliente['total_lives']} lives encerradas',
                          trailing: _CabineDetailScreenState._currency
                              .format((cliente['fat_total'] as num).toDouble()),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Leitura de Eficiência',
            subtitle:
                'Resumo executivo para o franqueado agir sem ruído operacional.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InsightBullet(
                  text: melhoresHorarios.isEmpty
                      ? 'Sem dados suficientes para definir um prime time desta cabine.'
                      : 'A melhor janela atual é ${melhoresHorarios.first['hora']} com GMV médio de ${_CabineDetailScreenState._currency.format((melhoresHorarios.first['gmv_medio'] as num).toDouble())}.',
                ),
                _InsightBullet(
                  text: topClientes.isEmpty
                      ? 'Nenhum parceiro ainda concentrou volume relevante nesta cabine.'
                      : '${topClientes.first['nome']} lidera o volume desta unidade com ${_CabineDetailScreenState._currency.format((topClientes.first['fat_total'] as num).toDouble())}.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoricoTab extends StatelessWidget {
  final CabineHistorico? historico;

  const _HistoricoTab({required this.historico});

  @override
  Widget build(BuildContext context) {
    if (historico == null) {
      return const _EmptyTabState(
        icon: Icons.history_outlined,
        title: 'Sem histórico consolidado',
        description:
            'Conforme as lives forem encerradas, esta aba mostrará evolução mensal, crescimento e totais acumulados da cabine.',
      );
    }

    final meses =
        historico!.desempenhoMensal['meses'] as List<dynamic>? ?? const [];
    final crescimento =
        (historico!.desempenhoMensal['crescimento_pct'] as num? ?? 0)
            .toDouble();
    final totais = historico!.totais;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (meses.length >= 2)
            Container(
              padding: const EdgeInsets.all(AppSpacing.compactPadding),
              decoration: BoxDecoration(
                color: crescimento >= 0
                    ? AppColors.successGreen.withValues(alpha: 0.10)
                    : AppColors.dangerRed.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Row(
                children: [
                  Icon(
                    crescimento >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: crescimento >= 0
                        ? AppColors.successGreen
                        : AppColors.dangerRed,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${crescimento >= 0 ? '+' : ''}${crescimento.toStringAsFixed(1)}% vs último mês',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          if (meses.length >= 2) const SizedBox(height: 16),
          _SectionCard(
            title: 'Evolução Mensal',
            subtitle: 'Histórico de faturamento e cadência de lives da cabine.',
            child: meses.isEmpty
                ? const Text(
                    'Sem meses suficientes para montar a linha histórica desta cabine.')
                : Column(
                    children: meses.take(6).map((mes) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RankListTile(
                          title: mes['mes'] as String,
                          subtitle: '${mes['total_lives']} lives',
                          trailing: _CabineDetailScreenState._currency
                              .format((mes['fat_total'] as num).toDouble()),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Totais Acumulados',
            subtitle: 'Visão consolidada da cabine desde o início da operação.',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _HistoryMetricCard(
                  label: 'Total de lives',
                  value: '${totais['total_lives'] ?? 0}',
                  color: AppColors.infoBlue,
                ),
                _HistoryMetricCard(
                  label: 'Faturamento acumulado',
                  value: _CabineDetailScreenState._currency
                      .format((totais['gmv_total'] as num? ?? 0).toDouble()),
                  color: AppColors.successGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: AppColors.textSecondary)),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(AppSpacing.compactPadding),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: AppTypography.h3.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(label,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;

  const _RankListTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(trailing, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _InsightBullet extends StatelessWidget {
  final String text;

  const _InsightBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 8, color: AppColors.primaryOrange),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _HistoryMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HistoryMetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSpacing.compactPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.h2.copyWith(fontSize: 20, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EmptyTabState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(title,
                style: AppTypography.h3.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(description,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
