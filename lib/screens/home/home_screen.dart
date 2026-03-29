import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/money_card.dart';
import '../../widgets/nps_gauge.dart';
import '../../widgets/chamados_card.dart';
import '../../widgets/excelencia_card.dart';
import '../../widgets/ranking_destaque.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/dashboard.dart';
import '../../routes/app_routes.dart';

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
        data: (dashboard) => _HomeContent(dashboard: dashboard),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final DashboardData dashboard;
  const _HomeContent({required this.dashboard});

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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1.5,
                                  child: MoneyCard(
                                    total: dashboard.fatTotal,
                                    bruto: dashboard.fatBruto,
                                    futuro: 0, // Placeholder
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Aqui entrariam os botões "VENDER" e afins
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFC107),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.point_of_sale, size: 40),
                                            SizedBox(height: 8),
                                            Text('VENDER',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade400,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.business_center,
                                                size: 40,
                                                color: Colors.black54),
                                            SizedBox(height: 8),
                                            Text('ESTOQUE',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black54)),
                                            Text('VOCÊ POSSUI 5 MALETAS',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.black54)),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const ExcelenciaCard(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 7,
                            child: Column(
                              children: [
                                const Expanded(
                                  flex: 5,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: 80,
                                          child: NpsGauge(score: 9.8)),
                                      SizedBox(width: 16),
                                      Expanded(child: ChamadosCard(count: 0)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  flex: 6,
                                  child: RankingDestaque(
                                    rankings: dashboard.rankingDia
                                        .take(3)
                                        .map((e) => {'nome': e.nome})
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          MoneyCard(
                            total: dashboard.fatTotal,
                            bruto: dashboard.fatBruto,
                            futuro: 0,
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(
                            height: 180,
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 80, child: NpsGauge(score: 9.8)),
                                SizedBox(width: 16),
                                Expanded(child: ChamadosCard(count: 0)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          RankingDestaque(
                            rankings: dashboard.rankingDia
                                .take(3)
                                .map((e) => {'nome': e.nome})
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          const ExcelenciaCard(),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
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
                              borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(width: 16),
                  Expanded(
                      flex: 6,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
