import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/money_card.dart';
import '../../widgets/cabine_card.dart';
import '../../widgets/action_button.dart';
import '../../mock/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Tela principal — dashboard do franqueado
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.home,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Linha superior: MoneyCard (~40%) + Painel de Cabines (~55%)
            Expanded(
              flex: 5,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 4,
                    child: MoneyCard(
                      total:   mockFat['total']!,
                      bruto:   mockFat['bruto']!,
                      liquido: mockFat['liquido']!,
                      onTap:   () => Navigator.pushNamed(context, AppRoutes.financeiro),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 6,
                    child: _CabinesPanel(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Botões de ação
            Row(
              children: [
                ActionButton(
                  label: 'MEUS BOLETOS',
                  icon: Icons.receipt_outlined,
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.boletos),
                ),
                const SizedBox(width: 12),
                ActionButton(
                  label: 'VENDAS',
                  icon: Icons.map_outlined,
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.vendas),
                ),
                const SizedBox(width: 12),
                ActionButton(
                  label: 'FINANCEIRO',
                  icon: Icons.bar_chart_rounded,
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.financeiro),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Ranking do dia
            Expanded(
              flex: 3,
              child: _RankingPanel(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid 5x2 de cabines no painel HOME
class _CabinesPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CABINES',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, letterSpacing: 0.8)),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.cabines),
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: 10,
                itemBuilder: (_, i) => CabineCard(
                  cabine: Map<String, dynamic>.from(mockCabines[i]),
                  onTap: () => _showCabineDetail(context, mockCabines[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCabineDetail(BuildContext context, Map cabine) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cabine ${cabine['numero']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${cabine['status']}'),
            if (cabine['apresentador'] != null) Text('Apresentador: ${cabine['apresentador']}'),
            if (cabine['cliente'] != null) Text('Cliente: ${cabine['cliente']}'),
            if (cabine['horario'] != null) Text('Inicio: ${cabine['horario']}'),
            if (cabine['tempo'] != null) Text('Tempo: ${cabine['tempo']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }
}

/// Ranking de vendas do dia
class _RankingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RANKING DO DIA',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            ...mockRanking.asMap().entries.map((e) {
              final pos = e.key + 1;
              final v = e.value;
              final valor = 'R\$ ${(v['valor'] as double).toStringAsFixed(2).replaceAll('.', ',')}';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: pos == 1
                            ? AppColors.warning
                            : AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text('$pos', style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500,
                        color: pos == 1 ? Colors.white : AppColors.primary,
                      )),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(v['nome'] as String,
                      style: const TextStyle(fontSize: 13))),
                    Text(valor, style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.success)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
