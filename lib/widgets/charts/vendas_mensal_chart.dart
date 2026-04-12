import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/analytics_dashboard.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme.dart';

class VendasMensalChart extends StatelessWidget {
  final List<VendasMensal> dados;

  const VendasMensalChart({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    if (dados.isEmpty) return _buildEmptyState(context);

    final maxY = _maxY();

    return RepaintBoundary(
      child: Container(
        height: 300,
        padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vendas Mensal', style: AppTypography.h3.copyWith(fontSize: 15, color: context.colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Número de lives encerradas por mês',
                      style: AppTypography.caption.copyWith(color: context.colors.textSecondary)),
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
                  gridData: _buildGridData(maxY, context),
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

  double _maxY() {
    final maxV = dados.map((d) => d.totalVendas.toDouble()).fold(0.0, (a, b) => a > b ? a : b);
    return maxV > 0 ? maxV * 1.2 : 10;
  }

  BarTouchData _buildTouchData(BuildContext context) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => context.colors.tooltipBg,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tooltipRoundedRadius: 8,
        getTooltipItem: (group, _, rod, __) {
          final dado = dados[group.x];
          return BarTooltipItem(
            '${dado.totalVendas} live${dado.totalVendas != 1 ? 's' : ''}',
            TextStyle(color: context.colors.tooltipText, fontWeight: FontWeight.bold, fontSize: 13),
            children: [
              TextSpan(
                text: '\n${dado.mes}',
                style: TextStyle(color: context.colors.tooltipText.withValues(alpha: 0.7), fontSize: 11),
              ),
            ],
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitles(BuildContext context) {
    final shortMonths = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (value, _) {
            final idx = value.toInt();
            if (idx < 0 || idx >= dados.length) return const SizedBox.shrink();
            final month = int.tryParse(dados[idx].mes.split('-').last) ?? 1;
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                shortMonths[month - 1],
                style: AppTypography.caption.copyWith(color: context.colors.textSecondary, fontSize: 10),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          getTitlesWidget: (value, _) {
            if (value == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                value.toInt().toString(),
                style: AppTypography.caption.copyWith(
                  color: context.colors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
                textAlign: TextAlign.right,
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlGridData _buildGridData(double maxY, BuildContext context) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 2,
      getDrawingHorizontalLine: (_) => FlLine(
        color: context.colors.divider,
        strokeWidth: 1,
        dashArray: [4, 4],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(BuildContext context) {
    return dados.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.totalVendas.toDouble(),
            width: dados.length > 12 ? 14 : 18,
            gradient: LinearGradient(
              colors: [context.colors.info, context.colors.info.withValues(alpha: 0.4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _maxY(),
              color: context.colors.divider.withValues(alpha: 0.08),
            ),
          ),
        ],
      );
    }).toList();
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
          Icon(Icons.bar_chart_rounded, size: 48, color: context.colors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('Sem dados de vendas', style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary)),
        ],
      ),
    );
  }
}
