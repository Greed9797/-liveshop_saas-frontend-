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
import '../../theme/theme.dart';
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
              const _ActionButtons(),
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
        const _ActionButtons(),
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
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.cadastroCliente),
            icon: const Icon(Icons.point_of_sale_rounded, size: 18),
            label: const Text('VENDER'),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.financeiro),
            icon: Icon(Icons.account_balance_wallet_rounded,
                size: 18, color: context.colors.textSecondary),
            label: Text(
              'FINANCEIRO',
              style: TextStyle(color: context.colors.textPrimary),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: context.colors.divider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.5,
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
        color: context.colors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.divider),
      ),
      child: Center(
        child: Text('Nenhuma cabine configurada',
            style: AppTypography.labelLarge.copyWith(color: context.colors.textTertiary)),
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
      padding: const EdgeInsets.all(AppSpacing.compactPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CABINES',
                style: AppTypography.labelSmall.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _LiveBadge(
                  liveCount:
                      cabines.where((c) => c.status == 'ao_vivo').length),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.cabines),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver tudo',
                      style: AppTypography.labelSmall.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(Icons.chevron_right,
                        color: context.colors.primary, size: 16),
                  ],
                ),
              ),
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
        color: context.colors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border:
            Border.all(color: context.colors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: context.colors.success, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$liveCount AO VIVO',
            style: AppTypography.caption.copyWith(
                fontSize: 9,
                color: context.colors.success,
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

  void _showDetails(BuildContext context) {
    final statusLabel = switch (cabine.status) {
      'ao_vivo'    => 'AO VIVO',
      'reservada'  => 'RESERVADA',
      'ativa'      => 'ATIVA',
      'disponivel' => 'DISPONÍVEL',
      'manutencao' => 'MANUTENÇÃO',
      _            => cabine.status.toUpperCase(),
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Cabine ${cabine.numero}',
                  style: AppTypography.h3,
                ),
                const SizedBox(width: AppSpacing.sm),
                Builder(
                  builder: (ctx) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: cabine.status == 'ao_vivo'
                          ? ctx.colors.success.withValues(alpha: 0.15)
                          : ctx.colors.divider,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      statusLabel,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cabine.status == 'ao_vivo'
                            ? ctx.colors.success
                            : ctx.colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _DetailRow(icon: Icons.person_outline,
                label: 'Cliente', value: cabine.clienteNome ?? '—'),
            _DetailRow(icon: Icons.attach_money,
                label: 'GMV', value: 'R\$ ${cabine.gmvAtual.toStringAsFixed(2)}'),
            _DetailRow(icon: Icons.visibility_outlined,
                label: 'Viewers', value: '${cabine.viewerCount}'),
            if (cabine.duracaoMin > 0)
              _DetailRow(icon: Icons.timer_outlined,
                  label: 'Duração', value: '${cabine.duracaoMin} min'),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.cabines);
                },
                child: const Text('Ver detalhes completos'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Heatmap: intensidade laranja por status (mais ativo = mais escuro)
    final (Color bgColor, Color textColor) = switch (cabine.status) {
      'ao_vivo'    => (context.colors.primary, Colors.white),
      'reservada'  => (AppColors.orange200, Colors.white),
      'ativa'      => (AppColors.orange100, context.colors.primaryHover),
      'disponivel' => (context.colors.primaryLightBg, AppColors.orange200),
      'manutencao' => (context.colors.divider, context.colors.textSecondary),
      _            => (context.colors.background, context.colors.textTertiary),
    };

    final showName = cabine.clienteNome != null &&
        (cabine.status == 'ao_vivo' || cabine.status == 'reservada');

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${cabine.numero}',
              style: AppTypography.bodySmall.copyWith(
                  color: textColor, fontWeight: FontWeight.w700),
            ),
            if (showName)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  cabine.clienteNome!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    color: textColor.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.colors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Text('$label: ',
              style: AppTypography.labelSmall
                  .copyWith(color: context.colors.textSecondary, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(color: context.colors.textPrimary)),
          ),
        ],
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
        baseColor: context.colors.divider,
        highlightColor: context.colors.background,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                    color: context.colors.cardBackground,
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              flex: 7,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                    color: context.colors.cardBackground,
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

