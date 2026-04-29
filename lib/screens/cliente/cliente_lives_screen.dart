import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../design_system/app_colors.dart' as ds_colors;
import '../../design_system/app_colors_theme.dart';
import '../../design_system/app_screen_scaffold.dart';
import '../../design_system/app_tokens.dart' as ds_tokens;
import '../../design_system/app_typography.dart' as ds_typography;
import '../../providers/cliente_dashboard_provider.dart'
    show ClienteDashboard, LiveAtiva, ProximaReserva, ClientePeriod, clientePeriodProvider, clienteDashboardProvider;
import '../../providers/cliente_lives_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/metric_card.dart';

// ---------------------------------------------------------------------------
// Local aliases
// ---------------------------------------------------------------------------

class _AppColors {
  static const primary = ds_colors.AppColors.primary;
  static const primaryLight = ds_colors.AppColors.primaryLight;
  static const success = ds_colors.AppColors.success;
  static const info = ds_colors.AppColors.info;
  static const warning = ds_colors.AppColors.warning;
  static const lilac = ds_colors.AppColors.lilac;
}

class _AppSpacing {
  static const xs = ds_tokens.AppSpacing.x1;
  static const sm = ds_tokens.AppSpacing.x2;
  static const md = ds_tokens.AppSpacing.x4;
  static const lg = ds_tokens.AppSpacing.x6;
  static const xl = ds_tokens.AppSpacing.x8;
  static const x3l = ds_tokens.AppSpacing.x12;
  static const screenPadding = ds_tokens.AppSpacing.x6;
}

class _AppTypography {
  static const h2 = ds_typography.AppTypography.h2;
  static const h3 = ds_typography.AppTypography.h3;
  static const bodyLarge = ds_typography.AppTypography.bodyLarge;
  static const bodySmall = ds_typography.AppTypography.bodySmall;
  static const caption = ds_typography.AppTypography.caption;
}

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------

class ClienteLivesScreen extends StatelessWidget {
  const ClienteLivesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreenScaffold(
      currentRoute: AppRoutes.clienteLives,
      eyebrow: 'LIVES',
      title: 'Minhas Lives',
      child: const ClienteLivesBody(),
    );
  }
}

// Body reusável em tabs externas
class ClienteLivesBody extends ConsumerStatefulWidget {
  const ClienteLivesBody({super.key});

  @override
  ConsumerState<ClienteLivesBody> createState() => _ClienteLivesBodyState();
}

class _ClienteLivesBodyState extends ConsumerState<ClienteLivesBody>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(clientePeriodProvider);

    return Column(
      children: [
        TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Ao Vivo'),
            Tab(text: 'Histórico'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _AoVivoTab(),
              _HistoricoTab(period: period),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: Ao Vivo — body extracted from ClienteAoVivoScreen
// ---------------------------------------------------------------------------

class _AoVivoTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(clienteDashboardProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(_AppSpacing.screenPadding),
      child: dashAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Erro: $error'),
              const SizedBox(height: _AppSpacing.md),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(clienteDashboardProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (dashboard) => _AoVivoContent(dashboard: dashboard),
      ),
    );
  }
}

class _AoVivoContent extends StatelessWidget {
  final ClienteDashboard dashboard;

  const _AoVivoContent({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final live = dashboard.liveAtiva;

    if (live == null) {
      return _EmptyState(proximaReserva: dashboard.proximaReserva);
    }

    return _LiveActiveView(live: live);
  }
}

class _LiveActiveView extends StatelessWidget {
  static final NumberFormat _currency =
      NumberFormat.simpleCurrency(locale: 'pt_BR');

  final LiveAtiva live;

  const _LiveActiveView({required this.live});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LiveHeader(live: live),
        const SizedBox(height: _AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 480;
            final tiles = <Widget>[
              _MetricTile(
                icon: PhosphorIcons.currencyDollar(),
                iconColor: _AppColors.success,
                label: 'GMV Atual',
                value: _currency.format(live.gmvAtual),
                large: true,
              ),
              _MetricTile(
                icon: PhosphorIcons.users(),
                iconColor: _AppColors.info,
                label: 'Viewers',
                value: '–',
                large: true,
              ),
              _MetricTile(
                icon: PhosphorIcons.shoppingCartSimple(),
                iconColor: _AppColors.primary,
                label: 'Pedidos',
                value: '${live.pedidos}',
              ),
              _MetricTile(
                icon: PhosphorIcons.coinVertical(),
                iconColor: _AppColors.warning,
                label: 'Comissão Projetada',
                value: _currency.format(live.comissaoProjetada),
              ),
            ];

            if (isWide) {
              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: _AppSpacing.md,
                mainAxisSpacing: _AppSpacing.md,
                childAspectRatio: 2.6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: tiles,
              );
            }

            return Column(
              children: tiles
                  .map(
                    (tile) => Padding(
                      padding: const EdgeInsets.only(bottom: _AppSpacing.md),
                      child: tile,
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: _AppSpacing.lg),
        _EngagementRow(live: live),
        const SizedBox(height: _AppSpacing.lg),
        _ActionButtons(),
      ],
    );
  }
}

class _LiveHeader extends StatelessWidget {
  final LiveAtiva live;

  const _LiveHeader({required this.live});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: _AppColors.success,
      padding: const EdgeInsets.symmetric(
        horizontal: _AppSpacing.lg,
        vertical: _AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: _AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: _AppSpacing.sm),
          Expanded(
            child: Text(
              '🔴 Você está ao vivo! — Cabine ${live.cabineNumero}',
              style: _AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: _AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: _AppSpacing.md,
              vertical: _AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: context.colors.bgMuted,
              borderRadius: BorderRadius.circular(ds_tokens.AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIcons.timer(),
                  size: 14,
                  color: context.colors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${live.duracaoMin} min',
                  style: _AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool large;

  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(_AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: large ? 52 : 44,
            height: large ? 52 : 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ds_tokens.AppRadius.md),
            ),
            child: Icon(icon, color: iconColor, size: large ? 26 : 22),
          ),
          const SizedBox(width: _AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: (large ? _AppTypography.h2 : _AppTypography.h3)
                      .copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: _AppTypography.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EngagementRow extends StatelessWidget {
  final LiveAtiva live;

  const _EngagementRow({required this.live});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(_AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENGAJAMENTO',
            style: _AppTypography.caption.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: context.colors.textMuted,
            ),
          ),
          const SizedBox(height: _AppSpacing.md),
          Wrap(
            spacing: _AppSpacing.sm,
            runSpacing: _AppSpacing.sm,
            children: [
              _EngagementChip(
                icon: PhosphorIcons.heart(),
                iconColor: const Color(0xFFE53E3E),
                label: '${live.likes} likes',
              ),
              _EngagementChip(
                icon: PhosphorIcons.chatCircle(),
                iconColor: _AppColors.info,
                label: '${live.comentarios} comentários',
              ),
              _EngagementChip(
                icon: PhosphorIcons.shareNetwork(),
                iconColor: _AppColors.lilac,
                label: '${live.shares} shares',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EngagementChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _EngagementChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _AppSpacing.md,
        vertical: _AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.bgMuted,
        borderRadius: BorderRadius.circular(ds_tokens.AppRadius.full),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: _AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ProximaReserva? proximaReserva;

  const _EmptyState({this.proximaReserva});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(_AppSpacing.xl),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.colors.bgMuted,
                  borderRadius: BorderRadius.circular(ds_tokens.AppRadius.lg),
                ),
                child: Icon(
                  PhosphorIcons.wifiSlash(),
                  size: 28,
                  color: context.colors.textMuted,
                ),
              ),
              const SizedBox(width: _AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sem live ativa no momento',
                      style: _AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Suas métricas aparecerão aqui assim que uma transmissão for iniciada.',
                      style: _AppTypography.caption.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (proximaReserva != null) ...[
          const SizedBox(height: _AppSpacing.lg),
          _ProximaReservaCard(reserva: proximaReserva!),
        ],
        const SizedBox(height: _AppSpacing.lg),
        _ActionButtons(),
      ],
    );
  }
}

class _ProximaReservaCard extends StatelessWidget {
  static final DateFormat _dateFormat =
      DateFormat("dd/MM 'às' HH:mm", 'pt_BR');

  final ProximaReserva reserva;

  const _ProximaReservaCard({required this.reserva});

  String get _statusLabel {
    switch (reserva.status) {
      case 'ativo':
        return 'Ativa';
      case 'pendente':
        return 'Pendente';
      case 'assinado':
        return 'Assinada';
      default:
        return reserva.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ativadoEm = reserva.ativadoEm;

    return AppCard(
      borderColor: _AppColors.primary.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(_AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.calendarCheck(),
                size: 18,
                color: _AppColors.primary,
              ),
              const SizedBox(width: _AppSpacing.sm),
              Text(
                'Próxima Reserva',
                style: _AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: _AppSpacing.md),
          _ReservaRow(
            label: 'Cabine',
            value: 'Cabine ${reserva.cabineNumero}',
          ),
          const SizedBox(height: _AppSpacing.sm),
          _ReservaRow(label: 'Status', value: _statusLabel),
          if (ativadoEm != null) ...[
            const SizedBox(height: _AppSpacing.sm),
            _ReservaRow(
              label: 'Ativada em',
              value: _dateFormat.format(ativadoEm.toLocal()),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReservaRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReservaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: _AppTypography.caption.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ),
        Text(
          value,
          style: _AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.clienteReservas),
            icon: Icon(
              PhosphorIcons.calendarBlank(),
              size: 18,
              color: _AppColors.primary,
            ),
            label: const Text('Ver agenda'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _AppColors.primary,
              side: const BorderSide(color: _AppColors.primary),
              padding: const EdgeInsets.symmetric(
                  horizontal: _AppSpacing.md, vertical: _AppSpacing.sm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ds_tokens.AppRadius.md),
              ),
            ),
          ),
        ),
        const SizedBox(width: _AppSpacing.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.clienteAgenda),
            icon: Icon(
              PhosphorIcons.plusCircle(),
              size: 18,
              color: _AppColors.primary,
            ),
            label: const Text('Solicitar nova live'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _AppColors.primary,
              side: const BorderSide(color: _AppColors.primary),
              padding: const EdgeInsets.symmetric(
                  horizontal: _AppSpacing.md, vertical: _AppSpacing.sm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ds_tokens.AppRadius.md),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: Histórico — body extracted from ClienteHistoricoScreen
// ---------------------------------------------------------------------------

class _HistoricoTab extends ConsumerWidget {
  final ClientePeriod period;

  const _HistoricoTab({required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livesAsync = ref.watch(clienteLivesProvider);

    return Column(
      children: [
        // Period selector toolbar
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: _AppSpacing.screenPadding,
              vertical: _AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_HistoryPeriodSelector(period: period)],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(_AppSpacing.screenPadding),
            child: livesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Erro: $error'),
                    const SizedBox(height: _AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(clienteLivesProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              data: (data) => _HistoricoContent(data: data),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoricoContent extends StatelessWidget {
  static final NumberFormat _currency =
      NumberFormat.simpleCurrency(locale: 'pt_BR');

  final ClienteLivesResponse data;

  const _HistoricoContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final resumo = data.resumo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: _AppSpacing.md,
          runSpacing: _AppSpacing.md,
          children: [
            _MetricBox(
              child: MetricCard(
                label: 'GMV',
                value: _currency.format(resumo.gmvTotal),
                icon: Icons.payments_rounded,
                iconColor: _AppColors.primary,
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'ITENS VENDIDOS',
                value: '${resumo.itensVendidos}',
                icon: Icons.inventory_2_outlined,
                iconColor: _AppColors.info,
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'LIVES',
                value: '${resumo.totalLives}',
                icon: Icons.video_library_rounded,
                iconColor: _AppColors.primary,
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'HORAS',
                value: resumo.horasLive.toStringAsFixed(1),
                icon: Icons.schedule_rounded,
                iconColor: _AppColors.lilac,
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'INVESTIDO',
                value: _currency.format(resumo.valorInvestidoLives),
                icon: Icons.savings_rounded,
                iconColor: _AppColors.warning,
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'ROAS',
                value: resumo.roas.toStringAsFixed(2),
                icon: Icons.show_chart_rounded,
                iconColor: _AppColors.success,
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'VIEWERS',
                value: '${resumo.viewerCount}',
                icon: Icons.visibility_rounded,
                iconColor: _AppColors.info,
              ),
            ),
            _MetricBox(
              child: MetricCard(
                label: 'COMENTÁRIOS',
                value: '${resumo.commentsCount}',
                icon: Icons.forum_rounded,
                iconColor: _AppColors.primaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: _AppSpacing.x3l),
        if (data.lives.isEmpty)
          AppCard(
            boxShadow: const [],
            child: Text(
              'Nenhuma live registrada neste período.',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          )
        else
          Column(
            children: data.lives
                .map(
                  (live) => Padding(
                    padding: const EdgeInsets.only(bottom: _AppSpacing.md),
                    child: _LiveHistoryCard(live: live),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  final Widget child;

  const _MetricBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 210, child: child);
  }
}

class _HistoryPeriodSelector extends ConsumerWidget {
  static final DateFormat _periodFormat = DateFormat.yMMMM('pt_BR');

  final ClientePeriod period;

  const _HistoryPeriodSelector({required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = _periodFormat.format(DateTime(period.ano, period.mes));

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      boxShadow: const [],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Mês anterior',
            onPressed: () =>
                ref.read(clientePeriodProvider.notifier).state =
                    period.previous(),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          SizedBox(
            width: 150,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: _AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Próximo mês',
            onPressed: () =>
                ref.read(clientePeriodProvider.notifier).state = period.next(),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
          const SizedBox(width: _AppSpacing.xs),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => ref.invalidate(clienteLivesProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _LiveHistoryCard extends StatelessWidget {
  static final NumberFormat _currency =
      NumberFormat.simpleCurrency(locale: 'pt_BR');
  static final DateFormat _date = DateFormat("dd/MM 'às' HH:mm", 'pt_BR');

  final ClienteLive live;

  const _LiveHistoryCard({required this.live});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(_AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  live.iniciadoEm == null
                      ? 'Live'
                      : _date.format(live.iniciadoEm!.toLocal()),
                  style: _AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(status: live.status),
            ],
          ),
          const SizedBox(height: _AppSpacing.md),
          Wrap(
            spacing: _AppSpacing.lg,
            runSpacing: _AppSpacing.md,
            children: [
              _DetailMetric(
                label: 'Duração',
                value: '${live.duracaoHoras.toStringAsFixed(1)}h',
              ),
              _DetailMetric(label: 'GMV', value: _currency.format(live.gmv)),
              _DetailMetric(
                label: 'Itens / pedidos',
                value: '${live.itensVendidos} / ${live.totalOrders}',
              ),
              _DetailMetric(label: 'Viewers', value: '${live.viewerCount}'),
              _DetailMetric(
                label: 'Comentários',
                value: '${live.commentsCount}',
              ),
              _DetailMetric(
                label: 'Likes / shares',
                value: '${live.likesCount} / ${live.sharesCount}',
              ),
              _DetailMetric(
                label: 'Top produto',
                value: live.topProduto?.isNotEmpty == true
                    ? live.topProduto!
                    : '-',
              ),
              _DetailMetric(
                  label: 'ROAS', value: live.roas.toStringAsFixed(2)),
              _DetailMetric(
                label: 'Investido',
                value: _currency.format(live.valorInvestido),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  final String label;
  final String value;

  const _DetailMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: _AppTypography.caption
                .copyWith(color: context.colors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: _AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final isLive = status == 'em_andamento';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _AppSpacing.md,
        vertical: _AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: (isLive
                ? _AppColors.success
                : context.colors.borderSubtle)
            .withValues(alpha: isLive ? 1 : 0.7),
        borderRadius: BorderRadius.circular(ds_tokens.AppRadius.full),
      ),
      child: Text(
        isLive ? 'AO VIVO' : 'ENCERRADA',
        style: _AppTypography.caption.copyWith(
          color: isLive ? context.colors.bgCard : context.colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
