import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/roleta_widget.dart';
import '../../widgets/metric_card.dart';
import '../../mock/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Controle financeiro com 3 abas
class FinanceiroScreen extends StatelessWidget {
  const FinanceiroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.financeiro,
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Operacional'),
                  Tab(text: 'Faturamento Detalhado'),
                  Tab(text: 'Roleta do Franqueado'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OperacionalTab(),
                  _FaturamentoTab(),
                  _RoletaTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperacionalTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Controle Operacional',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          SizedBox(height: 16),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              SizedBox(width: 200, child: MetricCard(
                label: 'CUSTOS OPERACIONAIS', value: 'R\$ 8.650,00',
                icon: Icons.remove_circle_outline, iconColor: AppColors.danger)),
              SizedBox(width: 200, child: MetricCard(
                label: 'FLUXO DE CAIXA', value: 'R\$ 20.800,00',
                icon: Icons.swap_horiz, iconColor: AppColors.info)),
              SizedBox(width: 200, child: MetricCard(
                label: 'PAGAMENTOS', value: '12 realizados',
                icon: Icons.check_circle_outline, iconColor: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FaturamentoTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Faturamento Detalhado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          SizedBox(height: 16),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              SizedBox(width: 200, child: MetricCard(
                label: 'POR CLIENTE', value: 'R\$ 4.832,00',
                icon: Icons.person_outline, subtitle: 'Média por cliente')),
              SizedBox(width: 200, child: MetricCard(
                label: 'POR PRODUTO', value: 'R\$ 142,00',
                icon: Icons.inventory_2_outlined, subtitle: 'Ticket médio')),
              SizedBox(width: 200, child: MetricCard(
                label: 'COMISSÕES', value: 'R\$ 9.664,00',
                icon: Icons.percent, iconColor: AppColors.primary,
                subtitle: '20% do fat bruto')),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoletaTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2860),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ROLETA DO FRANQUEADO',
              style: TextStyle(color: AppColors.lilac, fontSize: 13, letterSpacing: 1)),
            const SizedBox(height: 32),
            RoletaWidget(value: mockFat['bruto']!,   label: 'FAT BRUTO',        fontSize: 36),
            const SizedBox(height: 24),
            RoletaWidget(value: mockFat['liquido']!, label: 'FAT LÍQUIDO',      fontSize: 28),
            const SizedBox(height: 24),
            RoletaWidget(value: mockFat['total']!,   label: 'TOTAL ACUMULADO',  fontSize: 22),
          ],
        ),
      ),
    );
  }
}
