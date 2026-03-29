import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/money_card.dart';
import '../../widgets/cabine_card.dart';
import '../../widgets/action_button.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/dashboard.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

/// Tela principal — dashboard do franqueado
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardProvider);

    return AppScaffold(
      currentRoute: AppRoutes.home,
      child: dashAsync.when(
        loading: () => const _HomeShimmerLoader(),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Erro ao carregar dashboard: $e'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (dashboard) => _HomeSliverContent(dashboard: dashboard),
      ),
    );
  }
}

class _HomeSliverContent extends StatelessWidget {
  final DashboardData dashboard;
  const _HomeSliverContent({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: AspectRatio(
                              aspectRatio: 1.5,
                              child: MoneyCard(
                                total: dashboard.fatTotal,
                                bruto: dashboard.fatBruto,
                                liquido: dashboard.fatLiquido,
                                onTap: () => Navigator.pushNamed(
                                    context, AppRoutes.financeiro),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 6,
                            child: _CabinesPanel(
                                cabines: dashboard.cabines,
                                isDesktop: isDesktop),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.8,
                            child: MoneyCard(
                              total: dashboard.fatTotal,
                              bruto: dashboard.fatBruto,
                              liquido: dashboard.fatLiquido,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.financeiro),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _CabinesPanel(
                              cabines: dashboard.cabines, isDesktop: isDesktop),
                        ],
                      ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionButton(
                        label: 'MEUS BOLETOS',
                        icon: Icons.receipt_outlined,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.boletos),
                      ),
                      const SizedBox(width: 12),
                      ActionButton(
                        label: 'VENDAS',
                        icon: Icons.map_outlined,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.vendas),
                      ),
                      const SizedBox(width: 12),
                      ActionButton(
                        label: 'FINANCEIRO',
                        icon: Icons.bar_chart_rounded,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.financeiro),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _ResumoSection(dashboard: dashboard),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 5,
                            child: _RankingPanel(ranking: dashboard.rankingDia),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _ResumoSection(dashboard: dashboard),
                          const SizedBox(height: 16),
                          _RankingPanel(ranking: dashboard.rankingDia),
                        ],
                      ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      },
    );
  }
}

class _ResumoSection extends StatelessWidget {
  final DashboardData dashboard;
  const _ResumoSection({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ResumoClientesCard(dashboard: dashboard),
        const SizedBox(height: 8),
        _ResumoLivesCard(dashboard: dashboard),
        const SizedBox(height: 8),
        _AlertasCard(dashboard: dashboard),
      ],
    );
  }
}

class _HomeShimmerLoader extends StatelessWidget {
  const _HomeShimmerLoader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(width: 16),
                  Expanded(
                      flex: 6,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 16),
            Expanded(
                flex: 4,
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)))),
          ],
        ),
      ),
    );
  }
}

class _ResumoClientesCard extends StatelessWidget {
  final DashboardData dashboard;
  const _ResumoClientesCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMetric(
                'CLIENTES ATIVOS', '${dashboard.clientesAtivos}', null),
            _buildMetric(
                'NOVOS (MÊS)', '+${dashboard.novosClientes}', Colors.green),
            _buildMetric('CHURN (MÊS)', '${dashboard.churnMes}',
                dashboard.churnMes > 0 ? Colors.red : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color? valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}

class _ResumoLivesCard extends StatelessWidget {
  final DashboardData dashboard;
  const _ResumoLivesCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMetric('LIVES (MÊS)', '${dashboard.livesMes}', null),
            _buildMetric(
                'GMV DAS LIVES',
                'R\$ ${dashboard.gmvLivesMes.toStringAsFixed(0)}',
                Colors.green),
            _buildMetric(
                'MÉDIA VIEWERS', '${dashboard.mediaViewers}', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color? valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}

class _AlertasCard extends StatelessWidget {
  final DashboardData dashboard;
  const _AlertasCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAlerta('Contratos Análise', dashboard.contratosAnalise,
                Icons.description),
            _buildAlerta(
                'Boletos Vencidos', dashboard.boletosVencidos, Icons.money_off),
            _buildAlerta(
                'Leads Livres', dashboard.leadsDisponiveis, Icons.person_add),
          ],
        ),
      ),
    );
  }

  Widget _buildAlerta(String label, int count, IconData icon) {
    return Row(
      children: [
        Icon(icon,
            size: 16, color: count > 0 ? Colors.orange[800] : Colors.grey),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            Text('$count',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: count > 0 ? Colors.orange[900] : Colors.black87)),
          ],
        ),
      ],
    );
  }
}

class _CabinesPanel extends StatelessWidget {
  final List<CabineStatus> cabines;
  final bool isDesktop;
  const _CabinesPanel({required this.cabines, required this.isDesktop});

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
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        letterSpacing: 0.8)),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.cabines),
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 5 : 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.1,
              ),
              itemCount: cabines.length.clamp(0, isDesktop ? 10 : 6),
              itemBuilder: (_, i) => CabineCard(
                cabine: cabines[i].toMockMap(),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.cabines, // Should ideally be detail
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingPanel extends StatelessWidget {
  final List<RankingEntry> ranking;
  const _RankingPanel({required this.ranking});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RANKING DO DIA',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    letterSpacing: 0.8)),
            const SizedBox(height: 8),
            if (ranking.isEmpty)
              const Text('Sem dados de hoje ainda.',
                  style: TextStyle(color: Colors.grey)),
            ...ranking.asMap().entries.map((e) {
              final pos = e.key + 1;
              final r = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: pos == 1
                            ? AppColors.warning
                            : AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text('$pos',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: pos == 1 ? Colors.white : AppColors.primary,
                          )),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.nome,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500)),
                          Text('${r.lives} lives hoje',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text(
                      'R\$ ${r.gmv.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success),
                    ),
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
