import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/cliente_historico_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/metric_card.dart';

class ClienteHistoricoScreen extends ConsumerStatefulWidget {
  const ClienteHistoricoScreen({super.key});

  @override
  ConsumerState<ClienteHistoricoScreen> createState() =>
      _ClienteHistoricoScreenState();
}

class _ClienteHistoricoScreenState
    extends ConsumerState<ClienteHistoricoScreen> {
  late int _mes;
  late int _ano;

  static final _currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
  static final _dateFormat = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR');
  static final _meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _mes = now.month;
    _ano = now.year;
  }

  void _mudarMes(int delta) {
    setState(() {
      final d = DateTime(_ano, _mes + delta);
      _mes = d.month;
      _ano = d.year;
    });
    ref.read(clienteHistoricoProvider.notifier).carregarPeriodo(_mes, _ano);
  }

  @override
  Widget build(BuildContext context) {
    final historicoAsync = ref.watch(clienteHistoricoProvider);

    return AppScaffold(
      currentRoute: AppRoutes.clienteHistorico,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PeriodSelector(
              mes: _mes,
              ano: _ano,
              meses: _meses,
              onPrev: () => _mudarMes(-1),
              onNext: () => _mudarMes(1),
            ),
            const SizedBox(height: AppSpacing.x2l),
            historicoAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Erro: $error'),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(clienteHistoricoProvider.notifier)
                          .carregarPeriodo(_mes, _ano),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              data: (data) => _HistoricoContent(
                data: data,
                currency: _currency,
                dateFormat: _dateFormat,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final int mes;
  final int ano;
  final List<String> meses;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PeriodSelector({
    required this.mes,
    required this.ano,
    required this.meses,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrev,
          tooltip: 'Mês anterior',
        ),
        Expanded(
          child: Text(
            '${meses[mes - 1]} $ano',
            style: AppTypography.h3.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
          tooltip: 'Próximo mês',
        ),
      ],
    );
  }
}

class _HistoricoContent extends StatelessWidget {
  final ClienteHistoricoData data;
  final NumberFormat currency;
  final DateFormat dateFormat;

  const _HistoricoContent({
    required this.data,
    required this.currency,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(
              width: 200,
              child: MetricCard(
                label: 'FATURAMENTO',
                value: currency.format(data.resumo.totalFaturamento),
                icon: Icons.attach_money,
                iconColor: AppColors.successGreen,
              ),
            ),
            SizedBox(
              width: 200,
              child: MetricCard(
                label: 'ITENS VENDIDOS',
                value: '${data.resumo.totalVendas}',
                icon: Icons.shopping_bag_outlined,
                iconColor: AppColors.primaryOrange,
              ),
            ),
            SizedBox(
              width: 200,
              child: MetricCard(
                label: 'TOTAL DE LIVES',
                value: '${data.resumo.totalLives}',
                icon: Icons.live_tv_outlined,
                iconColor: AppColors.infoBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x3l),
        if (data.lives.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.x3l),
              child: Text(
                'Nenhuma live encontrada neste período.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.lives.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, i) =>
                _LiveCard(live: data.lives[i], currency: currency, dateFormat: dateFormat),
          ),
      ],
    );
  }
}

class _LiveCard extends StatelessWidget {
  final LiveHistorico live;
  final NumberFormat currency;
  final DateFormat dateFormat;

  const _LiveCard({
    required this.live,
    required this.currency,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final date =
        DateTime.tryParse(live.iniciadoEm)?.toLocal() ?? DateTime.now();
    final isEncerrada = live.status == 'encerrada';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dateFormat.format(date),
                style: AppTypography.bodySmall
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              _StatusBadge(encerrada: isEncerrada),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.videocam_outlined,
                  size: 16, color: AppColors.gray500),
              const SizedBox(width: 4),
              Text(
                'Cabine ${live.cabineNumero.toString().padLeft(2, '0')}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              if (live.streamerNome != null) ...[
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.person_outline,
                    size: 16, color: AppColors.gray500),
                const SizedBox(width: 4),
                Text(
                  live.streamerNome!,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
              const Spacer(),
              const Icon(Icons.timer_outlined,
                  size: 16, color: AppColors.gray500),
              const SizedBox(width: 4),
              Text(
                '${live.duracaoMin} min',
                style: AppTypography.caption
                    .copyWith(color: AppColors.gray500, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: AppSpacing.x2l),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency.format(live.totalFaturamento),
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.successGreen,
                    ),
                  ),
                  Text(
                    'faturamento',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.x3l),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${live.totalVendas} itens',
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'vendidos',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (live.comissao > 0) ...[
                const SizedBox(width: AppSpacing.x3l),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.format(live.comissao),
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.lilac,
                      ),
                    ),
                    Text(
                      'sua comissão',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool encerrada;

  const _StatusBadge({required this.encerrada});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: encerrada
            ? AppColors.gray100
            : AppColors.successGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        encerrada ? 'Encerrada' : 'Em andamento',
        style: AppTypography.caption.copyWith(
          color: encerrada ? AppColors.gray500 : AppColors.successGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
