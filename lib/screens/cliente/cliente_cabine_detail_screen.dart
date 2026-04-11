import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/cliente_cabine_detail_provider.dart';
import '../../providers/live_stream_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';

class ClienteCabineDetailScreen extends ConsumerStatefulWidget {
  final String cabineId;
  final int cabineNumero;

  const ClienteCabineDetailScreen({
    super.key,
    required this.cabineId,
    required this.cabineNumero,
  });

  @override
  ConsumerState<ClienteCabineDetailScreen> createState() =>
      _ClienteCabineDetailScreenState();
}

class _ClienteCabineDetailScreenState
    extends ConsumerState<ClienteCabineDetailScreen>
    with SingleTickerProviderStateMixin {
  static final _currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
  static final _dateFormat = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR');

  late final TabController _tabController;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_syncPolling);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _tabController
      ..removeListener(_syncPolling)
      ..dispose();
    super.dispose();
  }

  void _syncPolling() {
    final detail =
        ref.read(clienteCabineDetailProvider(widget.cabineId)).valueOrNull;
    final shouldPoll = _tabController.index == 0 &&
        detail?.liveAtual != null &&
        !_tabController.indexIsChanging;

    if (shouldPoll) {
      _pollingTimer ??=
          Timer.periodic(const Duration(seconds: 30), (_) {
        ref
            .read(clienteCabineDetailProvider(widget.cabineId).notifier)
            .refreshLiveOnly();
      });
      return;
    }
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ClienteCabineDetailState>>(
        clienteCabineDetailProvider(widget.cabineId), (_, __) {
      _syncPolling();
    });

    final detailAsync =
        ref.watch(clienteCabineDetailProvider(widget.cabineId));

    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: Text(
          'Cabine ${widget.cabineNumero.toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () => ref
                .read(clienteCabineDetailProvider(widget.cabineId).notifier)
                .refresh(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryOrange,
          unselectedLabelColor: AppColors.gray500,
          indicatorColor: AppColors.primaryOrange,
          tabs: const [
            Tab(text: 'Live', icon: Icon(Icons.live_tv_outlined)),
            Tab(text: 'Histórico', icon: Icon(Icons.history_outlined)),
          ],
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.dangerRed),
                const SizedBox(height: AppSpacing.md),
                Text('Erro ao carregar dados: $error',
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => ref
                      .read(clienteCabineDetailProvider(widget.cabineId)
                          .notifier)
                      .refresh(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
        data: (detail) => TabBarView(
          controller: _tabController,
          children: [
            _LiveTab(
              liveAtual: detail.liveAtual,
              currency: _currency,
            ),
            _HistoricoTab(
              lives: detail.historicoLives,
              currency: _currency,
              dateFormat: _dateFormat,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Tab: Live
// ──────────────────────────────────────────────────────────────

class _LiveTab extends ConsumerWidget {
  final ClienteLiveAtual? liveAtual;
  final NumberFormat currency;

  const _LiveTab({required this.liveAtual, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = liveAtual;

    // SSE snapshot com fallback para os dados REST
    final snapshot = live != null
        ? ref.watch(liveStreamProvider(live.liveId)).valueOrNull
        : null;

    final viewerCount   = snapshot?.viewerCount   ?? live?.viewerCount   ?? 0;
    final gmvAtual      = snapshot?.gmv            ?? live?.gmvAtual      ?? 0.0;
    final totalOrders   = snapshot?.totalOrders    ?? live?.totalOrders   ?? 0;
    final likesCount    = snapshot?.likesCount     ?? live?.likesCount    ?? 0;
    final commentsCount = snapshot?.commentsCount  ?? live?.commentsCount ?? 0;

    if (live == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off_outlined,
                  size: 64, color: AppColors.gray300),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Nenhuma live em andamento',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray600),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Quando sua cabine estiver ao vivo, as métricas\naparecerão aqui em tempo real.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.gray400),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card AO VIVO
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.dangerRed,
                        borderRadius:
                            BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle,
                              size: 8, color: AppColors.white),
                          SizedBox(width: 4),
                          Text('AO VIVO',
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (live.apresentadorNome != null)
                      Expanded(
                        child: Text(
                          live.apresentadorNome!,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.gray600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Text(
                      '${live.duracaoMinutos}min',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.gray500),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Métricas em grid 2x2
                _MetricGrid(
                  items: [
                    _MetricItem(
                      icon: Icons.remove_red_eye_outlined,
                      label: 'Espectadores',
                      value: '$viewerCount',
                      color: AppColors.infoBlue,
                    ),
                    _MetricItem(
                      icon: Icons.attach_money_rounded,
                      label: 'GMV',
                      value: currency.format(gmvAtual),
                      color: AppColors.successGreen,
                    ),
                    _MetricItem(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Pedidos',
                      value: '$totalOrders',
                      color: AppColors.primaryOrange,
                    ),
                    _MetricItem(
                      icon: Icons.favorite_outline_rounded,
                      label: 'Curtidas',
                      value: '$likesCount',
                      color: AppColors.dangerRed,
                    ),
                  ],
                ),
                if (commentsCount > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          size: 14, color: AppColors.gray400),
                      const SizedBox(width: 4),
                      Text(
                        '$commentsCount comentários',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.gray500),
                      ),
                    ],
                  ),
                ],
                if (live.topProduto != null) ...[
                  const Divider(height: AppSpacing.x2l),
                  Row(
                    children: [
                      const Icon(Icons.star_outline_rounded,
                          size: 16, color: AppColors.warningYellow),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Mais vendido: ${live.topProduto}',
                          style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final List<_MetricItem> items;
  const _MetricGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.4,
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, size: 18, color: item.color),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.value,
                            style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray900),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.label,
                            style: AppTypography.caption
                                .copyWith(color: AppColors.gray500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _MetricItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

// ──────────────────────────────────────────────────────────────
// Tab: Histórico
// ──────────────────────────────────────────────────────────────

class _HistoricoTab extends StatelessWidget {
  final List<ClienteHistoricoLive> lives;
  final NumberFormat currency;
  final DateFormat dateFormat;

  const _HistoricoTab({
    required this.lives,
    required this.currency,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    if (lives.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_outlined,
                  size: 64, color: AppColors.gray300),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Nenhuma live registrada nesta cabine',
                style:
                    TextStyle(color: AppColors.gray500, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: lives.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => _LiveHistoricoCard(
        live: lives[i],
        currency: currency,
        dateFormat: dateFormat,
      ),
    );
  }
}

class _LiveHistoricoCard extends StatelessWidget {
  final ClienteHistoricoLive live;
  final NumberFormat currency;
  final DateFormat dateFormat;

  const _LiveHistoricoCard({
    required this.live,
    required this.currency,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    // Exibe a data conforme armazenada (sem conversão de fuso — Phase 5 cuida disso)
    DateTime? date;
    try {
      date = DateTime.parse(live.iniciadoEm).toLocal();
    } catch (_) {}

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  date != null
                      ? dateFormat.format(date)
                      : live.iniciadoEm,
                  style: AppTypography.bodySmall
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              StatusBadge(status: live.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.timer_outlined,
                  size: 14, color: AppColors.gray400),
              const SizedBox(width: 4),
              Text(
                '${live.duracaoMin} min',
                style: AppTypography.caption
                    .copyWith(color: AppColors.gray500),
              ),
            ],
          ),
          const Divider(height: AppSpacing.x2l),
          Row(
            children: [
              _StatColumn(
                value: currency.format(live.fatGerado),
                label: 'faturamento',
                color: AppColors.successGreen,
              ),
              if (live.comissaoCalculada > 0) ...[
                const SizedBox(width: AppSpacing.x2l),
                _StatColumn(
                  value: currency.format(live.comissaoCalculada),
                  label: 'sua comissão',
                  color: AppColors.lilac,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.bodyLarge
              .copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: AppTypography.caption
              .copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
