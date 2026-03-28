import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/metric_card.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Programa de excelência com métricas e cálculo de ROI
class ExcelenciaScreen extends StatelessWidget {
  const ExcelenciaScreen({super.key});

  static const _taxaFranquia = 29000.0;
  static const _fatMensal    = 29450.0;
  static double get _mesesROI => _taxaFranquia / _fatMensal;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.excelencia,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Programa de Excelência',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            const Wrap(
              spacing: 14, runSpacing: 14,
              children: [
                SizedBox(width: 220, child: MetricCard(
                  label: 'EXCELÊNCIA DA FRANQUIA',
                  value: '★★★★☆',
                  icon: Icons.workspace_premium_outlined,
                  iconColor: AppColors.warning,
                  subtitle: 'Score 4.2 / 5.0',
                )),
                SizedBox(width: 220, child: MetricCard(
                  label: 'CRESCIMENTO DE CLIENTES',
                  value: '+18.5%',
                  icon: Icons.people_outline,
                  iconColor: AppColors.success,
                  subtitle: 'vs. mês anterior',
                )),
                SizedBox(width: 220, child: MetricCard(
                  label: 'PRODUTIVIDADE',
                  value: '3 novos/mês',
                  icon: Icons.bolt_outlined,
                  iconColor: AppColors.primary,
                  subtitle: 'Crescimento saudável',
                )),
                SizedBox(width: 220, child: MetricCard(
                  label: 'CHURN',
                  value: '5.2%',
                  icon: Icons.remove_circle_outline,
                  iconColor: AppColors.danger,
                  subtitle: '1 cancelamento / 19 clientes',
                )),
                SizedBox(width: 220, child: MetricCard(
                  label: 'ÍNDICE DE FIDELIDADE',
                  value: '94.8%',
                  icon: Icons.favorite_border,
                  iconColor: AppColors.success,
                  subtitle: 'Carteira ativa',
                )),
              ],
            ),
            const SizedBox(height: 28),
            Card(
              color: const Color(0xFF2D2860),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    const Icon(Icons.savings_outlined, color: AppColors.lilac, size: 40),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('RETORNO SOBRE INVESTIMENTO (ROI)',
                            style: TextStyle(color: AppColors.lilac, fontSize: 12, letterSpacing: 0.8)),
                          const SizedBox(height: 8),
                          Text(
                            '${_mesesROI.toStringAsFixed(1)} meses',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Taxa de franquia R\$ ${_taxaFranquia.toStringAsFixed(0)} ÷ Fat. líq. R\$ ${_fatMensal.toStringAsFixed(0)}/mês',
                            style: TextStyle(
                              color: AppColors.lilac.withValues(alpha: 0.8), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
