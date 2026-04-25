import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../design_system/design_system.dart' hide AppCard;
import '../../models/dashboard.dart';
import '../../providers/dashboard_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/metric_card.dart';

final _brl = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: 'R\$',
  decimalDigits: 0,
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardProvider);

    return AppScreenScaffold(
      currentRoute: AppRoutes.home,
      title: 'Home',
      subtitle: 'Visão executiva da unidade.',
      actions: [
        IconButton(
          tooltip: 'Atualizar',
          icon: const Icon(Icons.refresh),
          color: context.colors.textSecondary,
          onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
        ),
      ],
      child: dashAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _HomeError(
          error: e,
          onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
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
        final padding = constraints.maxWidth >= AppBreakpoints.desktop
            ? AppSpacing.x8
            : AppSpacing.x4;

        return ListView(
          padding: EdgeInsets.all(padding),
          children: [
            const _SectionTitle(title: 'Visão executiva'),
            const SizedBox(height: AppSpacing.x3),
            _ExecutiveKpis(dashboard: dashboard),
            const SizedBox(height: AppSpacing.x6),
            const _SectionTitle(title: 'Operação imediata'),
            const SizedBox(height: AppSpacing.x3),
            _OperationBand(dashboard: dashboard),
            const SizedBox(height: AppSpacing.x6),
            const _SectionTitle(title: 'Alertas'),
            const SizedBox(height: AppSpacing.x3),
            _AlertsBand(dashboard: dashboard),
          ],
        );
      },
    );
  }
}

class _ExecutiveKpis extends StatelessWidget {
  final DashboardData dashboard;

  const _ExecutiveKpis({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final cards = [
      MetricCard(
        label: 'GMV do mês',
        value: _brl.format(dashboard.gmvMes),
        icon: PhosphorIcons.currencyCircleDollar(),
        subtitle: 'Resultado consolidado',
      ),
      MetricCard(
        label: 'Pipeline aberto',
        value: '${dashboard.pipelineAberto}',
        icon: PhosphorIcons.funnel(),
        subtitle: 'leads ativos',
      ),
      MetricCard(
        label: 'Valor do pipeline',
        value: _brl.format(dashboard.valorPipeline),
        icon: PhosphorIcons.chartLineUp(),
        subtitle: 'oportunidades abertas',
      ),
      MetricCard(
        label: 'Taxa de conversão',
        value: '${dashboard.taxaConversao.toStringAsFixed(1)}%',
        icon: PhosphorIcons.arrowsLeftRight(),
        subtitle: 'leads fechados → ganho',
      ),
      MetricCard(
        label: 'Clientes ativos',
        value: '${dashboard.clientesAtivos}',
        icon: PhosphorIcons.usersThree(),
        subtitle: 'contratos ativos',
      ),
    ];

    return _ResponsiveGrid(children: cards);
  }
}

class _OperationBand extends StatelessWidget {
  final DashboardData dashboard;

  const _OperationBand({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final proximas = dashboard.proximasLivesDia;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;
        final cards = [
          _InfoPanel(
            icon: PhosphorIcons.calendarBlank(),
            title: 'Agendamentos da semana',
            value: '${dashboard.agendamentosSemana}',
            detail: 'lives aprovadas ou em fila',
          ),
          _InfoPanel(
            icon: PhosphorIcons.videoCamera(),
            title: 'Ocupação hoje',
            value:
                '${dashboard.ocupacaoCabinesHoje.aoVivo}/${dashboard.ocupacaoCabinesHoje.operacionais}',
            detail: 'cabines ao vivo agora',
            progress: dashboard.ocupacaoCabinesHoje.percentual,
          ),
          _NextLivesPanel(lives: proximas),
        ];

        if (!isWide) {
          return Column(
            children: cards
                .map((card) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.x3),
                      child: card,
                    ))
                .toList(),
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: AppSpacing.x3),
              Expanded(child: cards[1]),
              const SizedBox(width: AppSpacing.x3),
              Expanded(flex: 2, child: cards[2]),
            ],
          ),
        );
      },
    );
  }
}

class _AlertsBand extends StatelessWidget {
  final DashboardData dashboard;

  const _AlertsBand({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      children: [
        _AlertCard(
          label: 'Inadimplentes',
          value: '${dashboard.inadimplentes}',
          tone: dashboard.inadimplentes > 0 ? _AlertTone.danger : _AlertTone.ok,
        ),
        _AlertCard(
          label: 'Contratos aguardando assinatura',
          value: '${dashboard.contratosAguardandoAssinatura}',
          tone: dashboard.contratosAguardandoAssinatura > 0
              ? _AlertTone.warning
              : _AlertTone.ok,
        ),
        _AlertCard(
          label: 'Leads parados',
          value: '${dashboard.leadsParados}',
          tone: dashboard.leadsParados > 0 ? _AlertTone.warning : _AlertTone.ok,
        ),
        _AlertCard(
          label: 'Conflitos de agenda',
          value: '${dashboard.conflitosAgenda}',
          tone:
              dashboard.conflitosAgenda > 0 ? _AlertTone.danger : _AlertTone.ok,
        ),
      ],
    );
  }
}

class _NextLivesPanel extends StatelessWidget {
  final List<ProximaLiveDia> lives;

  const _NextLivesPanel({required this.lives});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.x5),
      borderColor: context.colors.borderSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.broadcast(),
                  size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.x2),
              Text(
                'Próximas lives do dia',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x4),
          if (lives.isEmpty)
            Text(
              'Nenhuma live restante hoje.',
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            )
          else
            ...lives.take(4).map(
                  (live) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.x3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: Text(
                            _formatHour(live.horaInicio),
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${live.clienteNome} · Cabine ${live.cabineNumero}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final double? progress;

  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.x5),
      borderColor: context.colors.borderSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(height: AppSpacing.x4),
          Text(title, style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.x2),
          Text(value, style: AppTypography.h2),
          const SizedBox(height: AppSpacing.x1),
          Text(
            detail,
            style: AppTypography.caption.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.x4),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: context.colors.bgMuted,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _AlertTone { ok, warning, danger }

class _AlertCard extends StatelessWidget {
  final String label;
  final String value;
  final _AlertTone tone;

  const _AlertCard({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      _AlertTone.ok => AppColors.success,
      _AlertTone.warning => AppColors.warning,
      _AlertTone.danger => AppColors.danger,
    };

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.x5),
      borderColor: color.withValues(alpha: 0.25),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIcons.warningCircle(), color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.x1),
                Text(value, style: AppTypography.h3.copyWith(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= AppBreakpoints.desktop
            ? 4
            : constraints.maxWidth >= AppBreakpoints.tablet
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.x3,
            mainAxisSpacing: AppSpacing.x3,
            childAspectRatio: columns == 1 ? 2.4 : 1.55,
          ),
          itemBuilder: (_, index) => children[index],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTypography.caption.copyWith(
        color: context.colors.textMuted,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _HomeError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Erro ao carregar dashboard: $error',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          AppSecondaryButton(label: 'Tentar novamente', onPressed: onRetry),
        ],
      ),
    );
  }
}

String _formatHour(String raw) {
  if (raw.length >= 5) return raw.substring(0, 5);
  return raw;
}
