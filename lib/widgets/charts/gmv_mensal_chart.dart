import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/analytics_dashboard.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_typography.dart';

class GmvMensalChart extends StatelessWidget {
  final List<FaturamentoMensal> dados;

  const GmvMensalChart({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    if (dados.isEmpty) return _buildEmptyState();

    final maxY = _maxY();

    return RepaintBoundary(
      child: Container(
        height: 300,
        padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
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
                  Text('Faturamento Mensal (GMV)', style: AppTypography.h3.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text('Últimos 12 meses', style: AppTypography.caption.copyWith(color: AppColors.gray500)),
                ],
              ),
            ),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  minY: 0,
                  barTouchData: _buildTouchData(),
                  titlesData: _buildTitles(),
                  borderData: FlBorderData(show: false),
                  gridData: _buildGridData(maxY),
                  barGroups: _buildBarGroups(),
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
    final maxGmv = dados.map((d) => d.gmv).fold(0.0, (a, b) => a > b ? a : b);
    return maxGmv > 0 ? maxGmv * 1.15 : 1000;
  }

  BarTouchData _buildTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => AppColors.darkNavy.withValues(alpha: 0.9),
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tooltipRoundedRadius: 8,
        getTooltipItem: (group, _, rod, __) {
          final dado = dados[group.x];
          return BarTooltipItem(
            NumberFormat.simpleCurrency(locale: 'pt_BR').format(dado.gmv),
            const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13),
            children: [
              TextSpan(
                text: '\n${dado.mes}',
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.7), fontSize: 11),
              ),
            ],
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitles() {
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
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 72,
          getTitlesWidget: (value, _) {
            if (value == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$').format(value),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlGridData _buildGridData(double maxY) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 250,
      getDrawingHorizontalLine: (_) => FlLine(
        color: AppColors.darkNavyLight.withValues(alpha: 0.1),
        strokeWidth: 1,
        dashArray: [4, 4],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return dados.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.gmv,
            width: dados.length > 12 ? 14 : 18,
            gradient: LinearGradient(
              colors: [AppColors.primaryOrange, AppColors.primaryOrange.withValues(alpha: 0.4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _maxY(),
              color: AppColors.darkNavyLight.withValues(alpha: 0.05),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.darkNavyLight.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('Sem dados de faturamento', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
