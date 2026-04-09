import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/money_card.dart';
import '../../widgets/excelencia_card.dart';
import '../../widgets/nps_gauge.dart';
import '../../widgets/chamados_card.dart';
import '../../widgets/ranking_destaque.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/dashboard.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_breakpoints.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_card.dart';

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
        final isWideLayout = constraints.maxWidth >= AppBreakpoints.tablet;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              sliver: SliverToBoxAdapter(
                child: isWideLayout
                    ? _DesktopLayout(dashboard: dashboard)
                    : _MobileLayout(dashboard: dashboard),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── LAYOUT DESKTOP ───────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  final DashboardData dashboard;
  const _DesktopLayout({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coluna esquerda: dinheiro + excelência + ações
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MoneyCard(
                total: dashboard.fatTotal,
                bruto: dashboard.fatBruto,
                liquido: dashboard.fatLiquido,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.financeiro),
              ),
              const SizedBox(height: AppSpacing.cardGap),
              const ExcelenciaCard(),
              const SizedBox(height: AppSpacing.cardGap),
              _ActionButtons(
                cabinesDisponiveis: dashboard.cabines
                    .where((cabine) => cabine.status == 'disponivel')
                    .length,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.cardGap),
        // Coluna direita: cabines + NPS/chamados + ranking
        Expanded(
          flex: 7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dashboard.cabines.isNotEmpty)
                _CabinesMiniGrid(cabines: dashboard.cabines, isLargeScreen: true)
              else
                const _CabinesEmptyCard(),
              const SizedBox(height: AppSpacing.cardGap),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: NpsGauge(score: 9.8),
                    ),
                    const SizedBox(width: AppSpacing.cardGap),
                    Expanded(
                      flex: 2,
                      child: ChamadosCard(count: dashboard.contratosAnalise),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.cardGap),
              RankingDestaque(
                rankings: dashboard.rankingDia
                    .take(3)
                    .map((e) => {'nome': e.nome})
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── LAYOUT MOBILE ────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final DashboardData dashboard;
  const _MobileLayout({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MoneyCard(
          total: dashboard.fatTotal,
          bruto: dashboard.fatBruto,
          liquido: dashboard.fatLiquido,
          onTap: () => Navigator.pushNamed(context, AppRoutes.financeiro),
        ),
        const SizedBox(height: AppSpacing.cardGap),
        if (dashboard.cabines.isNotEmpty)
          _CabinesMiniGrid(cabines: dashboard.cabines, isLargeScreen: false)
        else
          const _CabinesEmptyCard(),
        const SizedBox(height: AppSpacing.cardGap),
        _ActionButtons(
          cabinesDisponiveis: dashboard.cabines
              .where((cabine) => cabine.status == 'disponivel')
              .length,
        ),
        const SizedBox(height: AppSpacing.cardGap),
        RankingDestaque(
          rankings: dashboard.rankingDia
              .take(3)
              .map((e) => {'nome': e.nome})
              .toList(),
        ),
        const SizedBox(height: AppSpacing.cardGap),
        const NpsGauge(score: 9.8),
        const SizedBox(height: AppSpacing.cardGap),
        const ExcelenciaCard(),
      ],
    );
  }
}

// ─── WIDGETS INTERNOS ─────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final int cabinesDisponiveis;
  const _ActionButtons({required this.cabinesDisponiveis});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.cadastroCliente),
              child: SizedBox(
                height: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.point_of_sale, size: 38, color: AppColors.white),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'VENDER',
                      style: AppTypography.h3.copyWith(
                          fontWeight: FontWeight.bold, color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Material(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, AppRoutes.cabines),
              child: SizedBox(
                height: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.video_camera_front_outlined,
                        size: 38, color: AppColors.gray500),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'CABINES',
                      style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold, color: AppColors.gray700),
                    ),
                    Text(
                      '$cabinesDisponiveis disponíveis',
                      style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.gray400),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CabinesEmptyCard extends StatelessWidget {
  const _CabinesEmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.sidebarBorder),
      ),
      child: Center(
        child: Text('Nenhuma cabine configurada',
            style: AppTypography.labelLarge.copyWith(color: AppColors.gray400)),
      ),
    );
  }
}

class _CabinesMiniGrid extends StatelessWidget {
  final List<CabineStatus> cabines;
  final bool isLargeScreen;
  const _CabinesMiniGrid({required this.cabines, required this.isLargeScreen});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.cabines),
      padding: const EdgeInsets.all(AppSpacing.compactPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CABINES',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _LiveBadge(
                  liveCount:
                      cabines.where((c) => c.status == 'ao_vivo').length),
              const Spacer(),
              Text(
                'Ver tudo',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.chevron_right,
                  color: AppColors.primaryOrange, size: 16),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLargeScreen ? 5 : 4,
              crossAxisSpacing: AppSpacing.xs,
              mainAxisSpacing: AppSpacing.xs,
              childAspectRatio: 1.5,
            ),
            itemCount: cabines.length,
            itemBuilder: (_, i) => _CabineMiniTile(cabine: cabines[i]),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final int liveCount;
  const _LiveBadge({required this.liveCount});

  @override
  Widget build(BuildContext context) {
    if (liveCount == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border:
            Border.all(color: AppColors.successGreen.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                color: AppColors.successGreen, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$liveCount AO VIVO',
            style: AppTypography.caption.copyWith(
                fontSize: 9,
                color: AppColors.successGreen,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _CabineMiniTile extends StatelessWidget {
  final CabineStatus cabine;
  const _CabineMiniTile({required this.cabine});

  @override
  Widget build(BuildContext context) {
    // Heatmap: intensidade laranja por status (mais ativo = mais escuro)
    final (Color bgColor, Color textColor) = switch (cabine.status) {
      'ao_vivo'    => (AppColors.primaryOrange, AppColors.white),
      'reservada'  => (AppColors.orange200, AppColors.white),
      'ativa'      => (AppColors.orange100, AppColors.orange600),
      'disponivel' => (AppColors.primaryOrangeLight, AppColors.orange200),
      'manutencao' => (AppColors.gray200, AppColors.gray500),
      _            => (AppColors.gray100, AppColors.gray400),
    };

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Center(
        child: Text(
          '${cabine.numero}',
          style: AppTypography.bodySmall.copyWith(
              color: textColor, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── SHIMMER LOADER ───────────────────────────────────────────────────────────

class _HomeShimmerLoader extends StatelessWidget {
  const _HomeShimmerLoader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Shimmer.fromColors(
        baseColor: AppColors.gray200,
        highlightColor: AppColors.gray100,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              flex: 7,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
