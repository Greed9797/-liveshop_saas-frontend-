import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/cliente_dashboard_provider.dart';
import '../../routes/app_routes.dart';
import '../../design_system/design_system.dart';
import '../../widgets/charts/gmv_mensal_chart.dart';
import '../../widgets/charts/heatmap_horarios_chart.dart';

class ClienteScreen extends ConsumerWidget {
  const ClienteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(clienteDashboardProvider);

    return AppScreenScaffold(
      currentRoute: AppRoutes.cliente,
      eyebrow: 'PAINEL DO PARCEIRO',
      title: 'Minha Loja',
      titleSerif: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: dashAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 80),
                Text('Erro ao carregar dados', style: AppTypography.h3),
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
  final ClienteDashboard dashboard;

  const _ClienteContent({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final crescendo = dashboard.crescimentoPct >= 0;
    final custoPacote = dashboard.pacote?.valor ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dashboard.liveAtiva != null) ...[
          _LivePanel(live: dashboard.liveAtiva!),
          const SizedBox(height: AppSpacing.x6),
        ],

        // ── KPI Row ──
        _KpiRow(
          dashboard: dashboard,
          crescendo: crescendo,
          custoPacote: custoPacote,
        ),
        const SizedBox(height: AppSpacing.x6),

        // ── CTA Pacote ──
        _NextPacoteCard(reserva: dashboard.proximaReserva),
        const SizedBox(height: AppSpacing.x6),

        // ── Top horários ──
        if (dashboard.topHorarios.isNotEmpty) ...[
          ChartCard(
            title: 'Melhores horários',
            sub: 'GMV gerado por hora do dia — últimos 90 dias',
            child: HeatmapHorariosChart(dados: dashboard.topHorarios),
          ),
          const SizedBox(height: AppSpacing.x6),
        ],

        // ── Tendência de faturamento ──
        if (dashboard.faturamentoPorMes.isNotEmpty) ...[
          ChartCard(
            title: 'Tendência de Faturamento',
            sub: 'GMV mensal dos últimos 12 meses',
            child: Column(
              children: [
                GmvMensalChart(dados: dashboard.faturamentoPorMes),
                const SizedBox(height: AppSpacing.x3),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppGhostButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRoutes.clienteDashboard),
                    label: 'Ver análise completa',
                    icon: Icons.arrow_forward_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x6),
        ],

        // ── Benchmark ──
        _BenchmarkSection(
          nicho: dashboard.benchmarkNicho,
          geral: dashboard.benchmarkGeral,
        ),
        const SizedBox(height: AppSpacing.x8),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// KPI ROW
// ═══════════════════════════════════════════════════════════
class _KpiRow extends StatelessWidget {
  static final _currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

  final ClienteDashboard dashboard;
  final bool crescendo;
  final double custoPacote;

  const _KpiRow({
    required this.dashboard,
    required this.crescendo,
    required this.custoPacote,
  });

  @override
  Widget build(BuildContext context) {
    final sign = crescendo ? '+' : '';
    final roasStr = dashboard.roasMes != null
        ? '${dashboard.roasMes!.toStringAsFixed(1)}x'
        : '—';
    final horasStr = '${dashboard.horasMes.toStringAsFixed(1)}h';
    final custoStr = custoPacote > 0 ? _currency.format(custoPacote) : null;

    return Wrap(
      spacing: AppSpacing.x3,
      runSpacing: AppSpacing.x3,
      children: [
        _kpiBox(
          icon: Icons.trending_up_rounded,
          label: 'Faturamento GMV',
          value: _currency.format(dashboard.faturamentoMes),
          delta: '$sign${dashboard.crescimentoPct}% vs mês anterior',
          deltaTone: crescendo ? DeltaTone.up : DeltaTone.down,
        ),
        _kpiBox(
          icon: Icons.inventory_2_rounded,
          label: 'Itens Vendidos',
          value: '${dashboard.volumeVendas}',
        ),
        _kpiBox(
          icon: Icons.bar_chart_rounded,
          label: 'ROAS',
          value: roasStr,
          delta: dashboard.roasMes != null ? 'Retorno sobre investimento' : 'Configure um pacote',
          deltaTone: DeltaTone.neutral,
        ),
        _kpiBox(
          icon: Icons.schedule_rounded,
          label: 'Horas de Live',
          value: horasStr,
          delta: custoStr != null ? '$custoStr investidos' : null,
          deltaTone: DeltaTone.neutral,
        ),
      ],
    );
  }

  Widget _kpiBox({
    required IconData icon,
    required String label,
    required String value,
    String? delta,
    DeltaTone deltaTone = DeltaTone.neutral,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
      child: BigKpi(
        icon: icon,
        label: label,
        value: value,
        delta: delta,
        deltaTone: deltaTone,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// NEXT PACOTE CTA
// ═══════════════════════════════════════════════════════════
class _NextPacoteCard extends StatelessWidget {
  final ProximaReserva? reserva;

  const _NextPacoteCard({this.reserva});

  @override
  Widget build(BuildContext context) {
    final hasReserva = reserva != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.x4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySofter,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(
              hasReserva ? Icons.event_available_rounded : Icons.add_box_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasReserva
                      ? 'Cabine ${reserva!.cabineNumero.toString().padLeft(2, '0')} vinculada'
                      : 'Solicitar mais pacote de horas',
                  style: AppTypography.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  hasReserva
                      ? 'Status: ${reserva!.status == 'ativa' ? 'ativa' : 'reservada'}'
                      : 'Expanda sua operação com mais horas de live.',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (!hasReserva) ...[
            const SizedBox(width: AppSpacing.x3),
            AppPrimaryButton(
              onPressed: () {},
              label: 'Solicitar',
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BENCHMARK SECTION (preserved from original)
// ═══════════════════════════════════════════════════════════
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
        Text(
          'BENCHMARK DA UNIDADE',
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppColors.textPrimary,
          ),
        ),
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
  static final _currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

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
              style: AppTypography.bodyLarge
                  .copyWith(fontWeight: FontWeight.w700)),
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
            style:
                AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value,
            style:
                AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
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
          Text(
            'BENCHMARK DA UNIDADE',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: AppColors.textPrimary,
            ),
          ),
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

// ═══════════════════════════════════════════════════════════
// LIVE PANEL (preserved from original)
// ═══════════════════════════════════════════════════════════
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
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x3, vertical: AppSpacing.x1),
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
              Text(
                '${widget.live.duracaoMin} min',
                style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted, fontWeight: FontWeight.bold),
              ),
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
                  icon: Icons.shopping_cart_rounded,
                  color: AppColors.primary,
                  label: 'GMV Atual',
                  value: currency.format(widget.live.gmvAtual)),
              _LiveMetric(
                  icon: Icons.schedule_rounded,
                  color: AppColors.success,
                  label: 'Duração',
                  value: '${widget.live.duracaoMin} min'),
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
              style: AppTypography.h2
                  .copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label,
              style:
                  AppTypography.caption.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
