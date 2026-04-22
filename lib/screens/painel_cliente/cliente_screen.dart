import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/cliente_dashboard_provider.dart';
import '../../routes/app_routes.dart';
import '../../design_system/design_system.dart' hide AppCard;
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_card.dart';
import '../../widgets/metric_card.dart';

class ClienteScreen extends ConsumerWidget {
  const ClienteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(clienteDashboardProvider);

    return AppScaffold(
      currentRoute: AppRoutes.cliente,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: dashAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Erro: $error'),
                const SizedBox(height: AppSpacing.x3),
                AppPrimaryButton(
                  onPressed: () =>
                      ref.read(clienteDashboardProvider.notifier).refresh(),
                  label: 'Tentar novamente',
                ),
              ],
            ),
          ),
          data: (dashboard) => _ClienteContent(dashboard: dashboard),
        ),
      ),
    );
  }
}

class _ClienteContent extends StatelessWidget {
  static final NumberFormat _currency =
      NumberFormat.simpleCurrency(locale: 'pt_BR');
  static final DateFormat _friendlyDate =
      DateFormat("dd/MM 'às' HH:mm", 'pt_BR');

  final ClienteDashboard dashboard;

  const _ClienteContent({required this.dashboard});

  String _reservationSubtitle(ProximaReserva reserva) {
    final referenceDate = reserva.ativadoEm ?? reserva.assinadoEm;
    if (referenceDate != null) {
      return 'Vínculo confirmado em ${_friendlyDate.format(referenceDate.toLocal())}';
    }

    return reserva.status == 'ativa'
        ? 'Sua cabine já está ativa para a próxima operação.'
        : 'Sua cabine está pronta para a próxima live.';
  }

  @override
  Widget build(BuildContext context) {
    final crescendo = dashboard.crescimentoPct >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.store, color: Colors.white, size: 28),
            ),
            const SizedBox(width: AppSpacing.x3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Minha Loja', style: AppTypography.h3.copyWith(fontWeight: FontWeight.w500)),
                Text('Visão Geral do Parceiro', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x6),
        _ProximaReservaCard(
          reserva: dashboard.proximaReserva,
          subtitleBuilder: _reservationSubtitle,
        ),
        const SizedBox(height: AppSpacing.x6),
        if (dashboard.liveAtiva != null) ...[
          _LivePanel(live: dashboard.liveAtiva!),
          const SizedBox(height: AppSpacing.x6),
        ],
        Text('RESULTADOS DO MÊS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.x3),
        Wrap(
          spacing: AppSpacing.x3,
          runSpacing: AppSpacing.x3,
          children: [
            SizedBox(
              width: 200,
              child: MetricCard(
                label: 'CRESCIMENTO',
                value: '${crescendo ? '+' : ''}${dashboard.crescimentoPct}%',
                icon: crescendo ? Icons.trending_up : Icons.trending_down,
                iconColor: crescendo ? AppColors.success : AppColors.danger,
              ),
            ),
            SizedBox(
              width: 200,
              child: MetricCard(
                label: 'VENDAS DO MÊS',
                value: _currency.format(dashboard.faturamentoMes),
                icon: Icons.attach_money,
                iconColor: AppColors.primary,
              ),
            ),
            SizedBox(
              width: 200,
              child: MetricCard(
                label: 'MEU LUCRO ESTIMADO',
                value: _currency.format(dashboard.lucroEstimado),
                icon: Icons.percent,
                iconColor: AppColors.lilac,
              ),
            ),
            SizedBox(
              width: 200,
              child: MetricCard(
                label: 'ITENS VENDIDOS',
                value: '${dashboard.volumeVendas}',
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x8),
        _BenchmarkSection(
          nicho: dashboard.benchmarkNicho,
          geral: dashboard.benchmarkGeral,
        ),
        const SizedBox(height: AppSpacing.x8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dashboard.rankingDia != null)
              Expanded(
                  flex: 1, child: _RankingCard(ranking: dashboard.rankingDia!)),
            if (dashboard.rankingDia != null) const SizedBox(width: AppSpacing.x4),
            Expanded(
                flex: 2,
                child: _MaisVendidosCard(produtos: dashboard.maisVendidos)),
          ],
        ),
      ],
    );
  }
}

class _ProximaReservaCard extends StatelessWidget {
  final ProximaReserva? reserva;
  final String Function(ProximaReserva reserva) subtitleBuilder;

  const _ProximaReservaCard({
    required this.reserva,
    required this.subtitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final hasReserva = reserva != null;

    return Card(
      elevation: 0,
      color: hasReserva
          ? AppColors.info.withValues(alpha: 0.10)
          : AppColors.warning.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(
          color: hasReserva
              ? AppColors.info.withValues(alpha: 0.35)
              : AppColors.warning.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  hasReserva ? AppColors.info : AppColors.warning,
              child: Icon(
                hasReserva
                    ? Icons.event_available_outlined
                    : Icons.event_busy_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasReserva
                        ? 'Próxima Reserva'
                        : 'Solicite sua próxima cabine',
                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  if (hasReserva) ...[
                    Text(
                      'Cabine ${reserva!.cabineNumero.toString().padLeft(2, '0')} ${reserva!.status == 'ativa' ? 'já ativa' : 'reservada'} para sua próxima operação.',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitleBuilder(reserva!),
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ] else ...[
                    Text(
                      'No momento não há cabine vinculada à sua operação. Fale com seu franqueado para abrir a próxima janela de live.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    Wrap(
                      spacing: AppSpacing.x2,
                      children: [
                        ActionChip(
                          label: const Text('Ver minhas cabines'),
                          backgroundColor: AppColors.bgCard,
                          side: BorderSide(color: AppColors.borderLight),
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.clienteCabines),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenchmarkSection extends StatelessWidget {
  final BenchmarkResumo? nicho;
  final BenchmarkResumo? geral;

  const _BenchmarkSection({required this.nicho, required this.geral});

  @override
  Widget build(BuildContext context) {
    if (nicho == null && geral == null) {
      return const _BenchmarkEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BENCHMARK DA UNIDADE', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.x3),
        Wrap(
          spacing: AppSpacing.x4,
          runSpacing: AppSpacing.x4,
          children: [
            if (nicho != null)
              SizedBox(
                width: 360,
                child: _BenchmarkCard(
                  title: 'Seu nicho',
                  benchmark: nicho!,
                  description: 'Você vs. o mercado direto do seu segmento.',
                ),
              ),
            if (geral != null)
              SizedBox(
                width: 360,
                child: _BenchmarkCard(
                  title: 'Visão geral da unidade',
                  benchmark: geral!,
                  description:
                      'Sua performance comparada ao ecossistema completo.',
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BenchmarkCard extends StatelessWidget {
  static final NumberFormat _currency =
      NumberFormat.simpleCurrency(locale: 'pt_BR');

  final String title;
  final BenchmarkResumo benchmark;
  final String description;

  const _BenchmarkCard({
    required this.title,
    required this.benchmark,
    required this.description,
  });

  String _headline() {
    if (benchmark.percentualDaMedia >= 100) {
      return 'Parabéns! Sua performance está ${benchmark.percentualDaMedia.toStringAsFixed(0)}% da média de referência.';
    }

    return 'Você está com ${benchmark.percentualDaMedia.toStringAsFixed(0)}% da média de referência. Vamos acelerar?';
  }

  String _subCopy() {
    if (benchmark.acimaDaMedia) {
      return benchmark.percentil == null
          ? 'Seu resultado já supera a média deste recorte.'
          : 'Você performa acima de ${(benchmark.percentil! * 100).toStringAsFixed(0)}% dos parceiros deste recorte.';
    }

    return benchmark.percentil == null
        ? 'Operações mais frequentes costumam superar essa média.'
        : 'Você está à frente de ${(benchmark.percentil! * 100).toStringAsFixed(0)}% dos parceiros deste recorte. Há espaço claro para crescer.';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (benchmark.percentualDaMedia / 100).clamp(0.0, 1.0);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(title,
                style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(description,
                style: TextStyle(color: AppColors.textSecondary)),
            if (benchmark.nicho != null) ...[
              const SizedBox(height: AppSpacing.x2),
              Text('Nicho: ${benchmark.nicho}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: AppSpacing.x3),
            Text(_headline(),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.x2),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: progress,
                backgroundColor: AppColors.borderLight,
                color: benchmark.acimaDaMedia
                    ? AppColors.success
                    : AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(_subCopy(),
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _BenchmarkMetric(
                    label: 'Seu GMV',
                    value: _currency.format(benchmark.meuGmv),
                  ),
                ),
                const SizedBox(width: AppSpacing.x3),
                Expanded(
                  child: _BenchmarkMetric(
                    label: 'Média',
                    value: _currency.format(benchmark.mediaGmv),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _BenchmarkMetric(
              label: 'Amostra considerada',
              value: '${benchmark.amostra} parceiros',
            ),
          ],
        ),
    );
  }
}

class _BenchmarkMetric extends StatelessWidget {
  final String label;
  final String value;

  const _BenchmarkMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _BenchmarkEmptyState extends StatelessWidget {
  const _BenchmarkEmptyState();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BENCHMARK DA UNIDADE', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.x2),
          Text(
            'Os dados comparativos ainda estão em processamento. Assim que houver amostra suficiente, vamos mostrar como a sua operação se posiciona no nicho e na unidade.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _LivePanel extends StatefulWidget {
  final LiveAtiva live;

  const _LivePanel({required this.live});

  @override
  State<_LivePanel> createState() => _LivePanelState();
}

class _LivePanelState extends State<_LivePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.success, width: 2),
        boxShadow: AppShadows.lg,
      ),
      padding: const EdgeInsets.all(AppSpacing.x5),
      child: Column(
        children: [
          Row(
            children: [
              FadeTransition(
                opacity: _ctrl,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3, vertical: AppSpacing.x1),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.live_tv, color: Colors.white, size: 16),
                      const SizedBox(width: AppSpacing.x2),
                      Text(
                        'AO VIVO AGORA',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Text('Cabine ${widget.live.cabineNumero}',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              Icon(Icons.timer_outlined, color: AppColors.textMuted, size: 18),
              const SizedBox(width: AppSpacing.x1),
              Text('${widget.live.duracaoMin} min',
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 32),
          Wrap(
            spacing: AppSpacing.x6,
            runSpacing: AppSpacing.x4,
            alignment: WrapAlignment.spaceAround,
            children: [
              _LiveMetric(
                  icon: Icons.visibility,
                  color: AppColors.info,
                  label: 'Espectadores',
                  value: '${widget.live.viewerCount}'),
              _LiveMetric(
                  icon: Icons.shopping_cart,
                  color: AppColors.primary,
                  label: 'GMV Atual',
                  value: currency.format(widget.live.gmvAtual)),
              _LiveMetric(
                  icon: Icons.savings,
                  color: AppColors.success,
                  label: 'Sua Comissão',
                  value: currency.format(widget.live.comissaoProjetada)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveMetric extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _LiveMetric({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSpacing.x2),
          Text(value,
              style: AppTypography.h2.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _MaisVendidosCard extends StatelessWidget {
  final List<ProdutoVendido> produtos;

  const _MaisVendidosCard({required this.produtos});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PRODUTOS MAIS VENDIDOS',
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
          const Divider(),
          if (produtos.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.x3),
              child: Text('Nenhuma venda registrada neste mês.',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
          ...produtos.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.x2),
                      decoration: BoxDecoration(
                        color: AppColors.bgBase,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        '${p.qty}x',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: Text(p.produto,
                          style:
                              const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    Text(currency.format(p.valor),
                        style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final RankingDia ranking;

  const _RankingCard({required this.ranking});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Card(
      color: AppColors.warning.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('RANKING DE HOJE',
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5)),
            const SizedBox(height: AppSpacing.x4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '#${ranking.posicao}',
                  style: AppTypography.h1.copyWith(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primaryHover),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 4),
                  child: Text('/ ${ranking.totalParticipantes}',
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textMuted)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              'Você gerou ${currency.format(ranking.gmvDia)} hoje',
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
