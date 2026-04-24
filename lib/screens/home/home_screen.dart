import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/excelencia_card.dart';
import '../../widgets/nps_gauge.dart';
import '../../widgets/chamados_card.dart';
import '../../widgets/ranking_destaque.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/dashboard.dart';
import '../../routes/app_routes.dart';
import '../../design_system/design_system.dart' hide AppCard;
import '../../widgets/app_card.dart';
import '../../widgets/metric_card.dart';

String _formatFaturamento(double value) {
  if (value >= 1000000) return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return 'R\$ ${(value / 1000).toStringAsFixed(1)}k';
  return 'R\$ ${value.toStringAsFixed(0)}';
}

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
              AppSecondaryButton(
                onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
                label: 'Tentar novamente',
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
        final responsivePadding = constraints.maxWidth >= AppBreakpoints.desktop
            ? AppSpacing.x8
            : constraints.maxWidth >= AppBreakpoints.tablet
                ? AppSpacing.x6
                : AppSpacing.x4;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(responsivePadding),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.x6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFFF1EFEE), Color(0xFFFCD7C5)],
                    ),
                  ),
                  child: isWideLayout
                      ? _DesktopLayout(dashboard: dashboard)
                      : _MobileLayout(dashboard: dashboard),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── KPI ROW ──────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  final DashboardData dashboard;
  const _KpiRow({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < AppBreakpoints.mobile;

    final cards = [
      MetricCard(
        label: 'GMV do Mês',
        value: _formatFaturamento(dashboard.gmvLivesMes),
        icon: PhosphorIcons.currencyCircleDollar(),
        subtitle: '${dashboard.livesMes} lives encerradas',
      ),
      MetricCard(
        label: 'Clientes Ativos',
        value: '${dashboard.clientesAtivos}',
        icon: PhosphorIcons.usersThree(),
        subtitle: '+${dashboard.novosClientes} novos',
      ),
      MetricCard(
        label: 'Lives no Mês',
        value: '${dashboard.livesMes}',
        icon: PhosphorIcons.broadcast(),
        subtitle: '${dashboard.mediaViewers} viewers médio',
      ),
      MetricCard(
        label: 'Contratos em Análise',
        value: '${dashboard.contratosAnalise}',
        icon: PhosphorIcons.fileText(),
        subtitle: dashboard.boletosVencidos > 0
            ? '${dashboard.boletosVencidos} boletos vencidos'
            : null,
        deltaPositive: dashboard.boletosVencidos > 0 ? false : null,
      ),
    ];

    if (isMobile) {
      // Agrupar em pares de 2 — IntrinsicHeight garante mesma altura
      // por linha sem cortar conteúdo
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: AppSpacing.x4),
                Expanded(child: cards[1]),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x4),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: AppSpacing.x4),
                Expanded(child: cards[3]),
              ],
            ),
          ),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: AppSpacing.x4),
          Expanded(child: cards[1]),
          const SizedBox(width: AppSpacing.x4),
          Expanded(child: cards[2]),
          const SizedBox(width: AppSpacing.x4),
          Expanded(child: cards[3]),
        ],
      ),
    );
  }
}

// ─── LAYOUT DESKTOP ───────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  final DashboardData dashboard;
  const _DesktopLayout({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _KpiRow(dashboard: dashboard),
        const SizedBox(height: AppSpacing.x4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coluna esquerda: excelência
            Expanded(
              flex: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ExcelenciaCard(),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.x4),
            // Coluna direita: cabines + NPS/chamados + ranking
            Expanded(
              flex: 7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dashboard.cabines.isNotEmpty)
                    _CabinesMiniGrid(
                        cabines: dashboard.cabines, isLargeScreen: true)
                  else
                    const _CabinesEmptyCard(),
                  const SizedBox(height: AppSpacing.x4),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Expanded(
                          child: NpsGauge(score: 9.8),
                        ),
                        const SizedBox(width: AppSpacing.x4),
                        Expanded(
                          flex: 2,
                          child:
                              ChamadosCard(count: dashboard.contratosAnalise),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x4),
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
        _KpiRow(dashboard: dashboard),
        const SizedBox(height: AppSpacing.x4),
        if (dashboard.cabines.isNotEmpty)
          _CabinesMiniGrid(cabines: dashboard.cabines, isLargeScreen: false)
        else
          const _CabinesEmptyCard(),
        const SizedBox(height: AppSpacing.x4),
        RankingDestaque(
          rankings: dashboard.rankingDia
              .take(3)
              .map((e) => {'nome': e.nome})
              .toList(),
        ),
        const SizedBox(height: AppSpacing.x4),
        const NpsGauge(score: 9.8),
        const SizedBox(height: AppSpacing.x4),
        const ExcelenciaCard(),
      ],
    );
  }
}

// ─── WIDGETS INTERNOS ─────────────────────────────────────────────────────────

class _CabinesEmptyCard extends StatelessWidget {
  const _CabinesEmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: Text('Nenhuma cabine configurada',
            style: AppTypography.label.copyWith(color: AppColors.textMuted)),
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
      padding: const EdgeInsets.all(AppSpacing.x4),
      borderColor: Colors.transparent,
      boxShadow: AppShadows.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.videoCamera(),
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.x2),
              Text(
                'Cabines',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              _LiveBadge(
                  liveCount:
                      cabines.where((c) => c.status == 'ao_vivo').length),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppSpacing.x4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLargeScreen ? 5 : 4,
              crossAxisSpacing: AppSpacing.x2,
              mainAxisSpacing: AppSpacing.x2,
              childAspectRatio: 1.15,
            ),
            itemCount: cabines.length,
            itemBuilder: (_, i) => _CabineMiniTile(cabine: cabines[i]),
          ),
          const SizedBox(height: AppSpacing.x4),
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => Navigator.pushNamed(context, AppRoutes.cabines),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
              decoration: BoxDecoration(
                color: AppColors.bgMuted,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ver tudo',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  Icon(PhosphorIcons.arrowRight(),
                      size: 16, color: AppColors.textMuted),
                ],
              ),
            ),
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
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.x2, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                color: AppColors.success, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.x1),
          Text(
            '$liveCount AO VIVO',
            style: AppTypography.caption.copyWith(
                fontSize: 9,
                color: AppColors.success,
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
      'ao_vivo' => 'AO VIVO',
      'reservada' => 'RESERVADA',
      'ativa' => 'ATIVA',
      'disponivel' => 'DISPONÍVEL',
      'manutencao' => 'MANUTENÇÃO',
      _ => cabine.status.toUpperCase(),
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Cabine ${cabine.numero}',
                  style:
                      AppTypography.h3.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(width: AppSpacing.x2),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x2, vertical: 2),
                  decoration: BoxDecoration(
                    color: cabine.status == 'ao_vivo'
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cabine.status == 'ao_vivo'
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x3),
            _DetailRow(
                icon: PhosphorIcons.user(),
                label: 'Cliente',
                value: cabine.clienteNome ?? '—'),
            _DetailRow(
                icon: PhosphorIcons.currencyDollar(),
                label: 'GMV',
                value: 'R\$ ${cabine.gmvAtual.toStringAsFixed(2)}'),
            _DetailRow(
                icon: PhosphorIcons.eye(),
                label: 'Viewers',
                value: '${cabine.viewerCount}'),
            if (cabine.duracaoMin > 0)
              _DetailRow(
                  icon: PhosphorIcons.timer(),
                  label: 'Duração',
                  value: '${cabine.duracaoMin} min'),
            const SizedBox(height: AppSpacing.x3),
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
    final isEmpty = cabine.status == 'disponivel' && cabine.clienteNome == null;

    final (Color bgColor, Color textColor) = switch (cabine.status) {
      'ao_vivo' => (AppColors.primary, Colors.white),
      'reservada' => (AppColors.bgMuted, AppColors.textMuted),
      'ativa' => (AppColors.bgGradientStart, AppColors.primaryHover),
      'disponivel' => (AppColors.bgMuted, AppColors.textMuted),
      'manutencao' => (AppColors.borderLight, AppColors.textSecondary),
      _ => (AppColors.bgMuted, AppColors.textMuted),
    };

    final showName = cabine.clienteNome != null &&
        (cabine.status == 'ao_vivo' || cabine.status == 'reservada');

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isEmpty)
              Text(
                '+',
                style: AppTypography.h3.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w400,
                ),
              )
            else
              Text(
                'Cabine ${cabine.numero.toString().padLeft(2, '0')}',
                style: AppTypography.bodySmall
                    .copyWith(color: textColor, fontWeight: FontWeight.w500),
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
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.x2),
          Text('$label: ',
              style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textPrimary)),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsivePadding = constraints.maxWidth >= AppBreakpoints.desktop
            ? AppSpacing.x8
            : constraints.maxWidth >= AppBreakpoints.tablet
                ? AppSpacing.x6
                : AppSpacing.x4;

        return Padding(
          padding: EdgeInsets.all(responsivePadding),
          child: Shimmer.fromColors(
            baseColor: AppColors.borderLight,
            highlightColor: AppColors.bgBase,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(AppRadius.lg)),
                  ),
                ),
                const SizedBox(width: AppSpacing.x4),
                Expanded(
                  flex: 7,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(AppRadius.lg)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
