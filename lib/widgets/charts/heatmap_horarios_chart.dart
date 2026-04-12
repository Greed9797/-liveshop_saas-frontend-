import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/franqueado_analytics_resumo.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme.dart';

class HeatmapHorariosChart extends StatelessWidget {
  final List<HeatmapHorarioAnalytics> dados;
  final double? metaDiaria;

  const HeatmapHorariosChart({
    super.key,
    required this.dados,
    this.metaDiaria,
  });

  @override
  Widget build(BuildContext context) {
    if (dados.isEmpty) {
      return _buildEmptyState(context);
    }

    final maxY = _calculateMaxY();

    return RepaintBoundary(
      child: Container(
        height: 300,
        padding: const EdgeInsets.fromLTRB(16, 32, 24, 16),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prime Time (Faturamento por Hora)',
                        style: AppTypography.h3.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Horários com maior volume de GMV gerado hoje',
                        style: AppTypography.caption
                            .copyWith(color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                  if (metaDiaria != null && metaDiaria! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.flag_rounded,
                              size: 14, color: context.colors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Meta: ${NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$').format(metaDiaria)}',
                            style: AppTypography.caption.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  minY: 0,
                  barTouchData: _buildTouchData(context),
                  titlesData: _buildTitles(context),
                  borderData: FlBorderData(show: false),
                  gridData: _buildGridData(context),
                  extraLinesData: _buildExtraLines(maxY, context),
                  barGroups: _buildBarGroups(context),
                ),
                swapAnimationDuration: const Duration(milliseconds: 600),
                swapAnimationCurve: Curves.easeOutQuint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.colors.cardBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 48,
            color: context.colors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aguardando as primeiras lives',
            style:
                AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Seu mapa de calor de vendas aparecerá aqui.',
            style: AppTypography.bodySmall
                .copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }

  double _calculateMaxY() {
    double maxFaturamento = 0;
    for (var d in dados) {
      if (d.gmvTotal > maxFaturamento) {
        maxFaturamento = d.gmvTotal;
      }
    }

    if (metaDiaria != null && metaDiaria! > 0) {
      return maxFaturamento > metaDiaria!
          ? maxFaturamento * 1.1
          : metaDiaria! * 1.15;
    }

    return maxFaturamento > 0 ? maxFaturamento * 1.1 : 1000;
  }

  BarTouchData _buildTouchData(BuildContext context) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => context.colors.tooltipBg,
        tooltipPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        tooltipMargin: 8,
        tooltipRoundedRadius: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final dado = dados[group.x];
          final valorFormatado = NumberFormat.simpleCurrency(locale: 'pt_BR')
              .format(dado.gmvTotal);

          String metaText = '';
          if (metaDiaria != null && metaDiaria! > 0) {
            final pct = (dado.gmvTotal / metaDiaria!) * 100;
            metaText = '\n\n${pct.toStringAsFixed(1)}% da meta';
          }

          return BarTooltipItem(
            '$valorFormatado\n',
            TextStyle(
              color: context.colors.tooltipText,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text:
                    '${dado.totalLives} live${dado.totalLives > 1 ? 's' : ''}',
                style: TextStyle(
                  color: context.colors.tooltipText.withValues(alpha: 0.7),
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              if (metaText.isNotEmpty)
                TextSpan(
                  text: metaText,
                  style: TextStyle(
                    color: (dado.gmvTotal >= metaDiaria!)
                        ? context.colors.success
                        : context.colors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitles(BuildContext context) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= 0 && value.toInt() < dados.length) {
              final hora = dados[value.toInt()].hora;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${hora}h',
                  style: AppTypography.caption
                      .copyWith(color: context.colors.textSecondary),
                ),
              );
            }
            return const SizedBox.shrink();
          },
          reservedSize: 32,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 72,
          getTitlesWidget: (value, meta) {
            if (value == 0) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$')
                    .format(value),
                style: AppTypography.caption.copyWith(
                  color: context.colors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlGridData _buildGridData(BuildContext context) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: _calculateMaxY() / 4 > 0 ? _calculateMaxY() / 4 : 250,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: context.colors.divider,
          strokeWidth: 1,
          dashArray: [4, 4],
        );
      },
    );
  }

  ExtraLinesData _buildExtraLines(double maxY, BuildContext context) {
    if (metaDiaria == null || metaDiaria! <= 0) {
      return ExtraLinesData(horizontalLines: []);
    }

    return ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
          y: metaDiaria!,
          color: context.colors.success.withValues(alpha: 0.8),
          strokeWidth: 2,
          dashArray: [6, 4],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 4, bottom: 4),
            style: TextStyle(
              color: context.colors.success,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
            labelResolver: (line) => 'META',
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups(BuildContext context) {
    return dados.asMap().entries.map((entry) {
      final index = entry.key;
      final dado = entry.value;
      final bateuMeta = (metaDiaria != null &&
          metaDiaria! > 0 &&
          dado.gmvTotal >= metaDiaria!);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: dado.gmvTotal,
            width: dados.length > 12 ? 16 : 24,
            gradient: LinearGradient(
              colors: bateuMeta
                  ? [
                      context.colors.success,
                      context.colors.success.withValues(alpha: 0.4),
                    ]
                  : [
                      context.colors.primary,
                      context.colors.primary.withValues(alpha: 0.4),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _calculateMaxY(),
              color: context.colors.divider.withValues(alpha: 0.08),
            ),
          ),
        ],
      );
    }).toList();
  }
}
