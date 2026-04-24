import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../design_system/design_system.dart';
import '../../providers/solicitacoes_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../widgets/solicitacao_card.dart';

class SolicitacoesScreen extends ConsumerStatefulWidget {
  const SolicitacoesScreen({super.key});

  @override
  ConsumerState<SolicitacoesScreen> createState() => _SolicitacoesScreenState();
}

class _SolicitacoesScreenState extends ConsumerState<SolicitacoesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _aprovar(String id) async {
    try {
      await ref.read(solicitacoesProvider.notifier).aprovar(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Live aprovada com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _recusar(String id) {
    final motivoCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => _RecusarDialog(
        ctrl: motivoCtrl,
        onConfirmar: (motivo) async {
          Navigator.pop(ctx);
          try {
            await ref.read(solicitacoesProvider.notifier).recusar(id, motivo);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Agendamento recusado.')),
            );
          } on ApiException catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final solicitacoesAsync = ref.watch(solicitacoesProvider);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final pendentesCount = solicitacoesAsync.valueOrNull
            ?.where((s) => s.status == 'pendente')
            .length ??
        0;

    final aprovadasHoje = solicitacoesAsync.valueOrNull
            ?.where((s) => s.status == 'aprovada' && s.dataSolicitada == today)
            .length ??
        0;

    final recusadasCount = solicitacoesAsync.valueOrNull
            ?.where((s) => s.status == 'recusada')
            .length ??
        0;

    return AppScreenScaffold(
      currentRoute: AppRoutes.agendamentos,
      title: 'Agendamentos de Lives',
      eyebrow: 'Agenda operacional',
      titleSerif: true,
      subtitle: 'Aprove, recuse e acompanhe pedidos de horário dos clientes.',
      child: Column(
        children: [
          // ── KPI Strip ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.x4, AppSpacing.x4, AppSpacing.x4, 0),
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                if (isNarrow) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: KpiAccentCard(
                              label: 'Aguardando você',
                              value: '$pendentesCount',
                              sub: 'agendamentos pendentes',
                              accentTop: true,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.x3),
                          Expanded(
                            child: KpiAccentCard(
                              label: 'Aprovadas hoje',
                              value: '$aprovadasHoje',
                              sub: 'neste dia',
                              valueColor: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.x3),
                      Row(
                        children: [
                          Expanded(
                            child: KpiAccentCard(
                              label: 'Recusadas',
                              value: '$recusadasCount',
                              sub: 'total',
                              valueColor: AppColors.danger,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.x3),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: KpiAccentCard(
                        label: 'Aguardando você',
                        value: '$pendentesCount',
                        sub: 'agendamentos pendentes',
                        accentTop: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: KpiAccentCard(
                        label: 'Aprovadas hoje',
                        value: '$aprovadasHoje',
                        sub: 'neste dia',
                        valueColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: KpiAccentCard(
                        label: 'Recusadas',
                        value: '$recusadasCount',
                        sub: 'total',
                        valueColor: AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x3),
                    const Expanded(
                        child: KpiAccentCard(
                      label: 'Tempo médio',
                      value: '—',
                      sub: 'para resposta',
                    )),
                  ],
                );
              },
            ),
          ),

          // ── Barra de abas ──
          Material(
            color: context.colors.bgCard,
            elevation: 1,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: context.colors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(
                  icon: const Icon(Icons.pending_actions_outlined, size: 18),
                  text: pendentesCount > 0
                      ? 'Pendentes ($pendentesCount)'
                      : 'Pendentes',
                ),
                const Tab(
                  icon: Icon(Icons.list_alt_outlined, size: 18),
                  text: 'Todas',
                ),
              ],
            ),
          ),

          // ── Conteúdo ──
          Expanded(
            child: solicitacoesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.x6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.danger),
                      const SizedBox(height: AppSpacing.x3),
                      Text(ApiService.extractErrorMessage(error),
                          textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.x2),
                      AppSecondaryButton(
                        onPressed: () =>
                            ref.read(solicitacoesProvider.notifier).refresh(),
                        label: 'Tentar novamente',
                      ),
                    ],
                  ),
                ),
              ),
              data: (solicitacoes) {
                final pendentes =
                    solicitacoes.where((s) => s.status == 'pendente').toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 0: Pendentes
                    _SolicitacoesLista(
                      items: pendentes,
                      emptyIcon: Icons.check_circle_outline_rounded,
                      emptyMessage: 'Nenhum agendamento pendente',
                      showActions: true,
                      onAprovar: _aprovar,
                      onRecusar: _recusar,
                      onRefresh: () =>
                          ref.read(solicitacoesProvider.notifier).refresh(),
                    ),
                    // Tab 1: Todas
                    _SolicitacoesLista(
                      items: solicitacoes,
                      emptyIcon: Icons.inbox_outlined,
                      emptyMessage: 'Nenhum agendamento registrado',
                      showActions: false,
                      onAprovar: _aprovar,
                      onRecusar: _recusar,
                      onRefresh: () =>
                          ref.read(solicitacoesProvider.notifier).refresh(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Dialog: Motivo da recusa
// ──────────────────────────────────────────────────────────────

class _RecusarDialog extends StatelessWidget {
  final TextEditingController ctrl;
  final void Function(String motivo) onConfirmar;

  const _RecusarDialog({required this.ctrl, required this.onConfirmar});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      title: const Row(
        children: [
          Icon(Icons.block_rounded, color: AppColors.danger, size: 20),
          SizedBox(width: AppSpacing.x2),
          Text('Motivo da recusa'),
        ],
      ),
      content: AppTextField(
        controller: ctrl,
        hint: 'Explique o motivo da recusa...',
        keyboardType: TextInputType.multiline,
      ),
      actions: [
        AppSecondaryButton(
          onPressed: () => Navigator.pop(context),
          label: 'Cancelar',
        ),
        const SizedBox(width: AppSpacing.x2),
        AppPrimaryButton(
          label: 'Confirmar',
          onPressed: () {
            final motivo = ctrl.text.trim();
            if (motivo.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('O motivo é obrigatório')),
              );
              return;
            }
            onConfirmar(motivo);
          },
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Lista de agendamentos (reutilizada em ambas as tabs)
// ──────────────────────────────────────────────────────────────

class _SolicitacoesLista extends StatelessWidget {
  final List<SolicitacaoFranqueador> items;
  final IconData emptyIcon;
  final String emptyMessage;
  final bool showActions;
  final Future<void> Function(String) onAprovar;
  final void Function(String) onRecusar;
  final Future<void> Function() onRefresh;

  const _SolicitacoesLista({
    required this.items,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.showActions,
    required this.onAprovar,
    required this.onRecusar,
    required this.onRefresh,
  });

  static final _dateDisplay = DateFormat('dd/MM/yyyy');

  String _formatDate(String raw) {
    try {
      return _dateDisplay.format(DateFormat('yyyy-MM-dd').parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 64, color: context.colors.textMuted),
            const SizedBox(height: AppSpacing.x4),
            Text(
              emptyMessage,
              style: AppTypography.bodyMedium
                  .copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.x4),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.x3),
        itemBuilder: (ctx, i) {
          final req = items[i];
          return SolicitacaoCard(
            cabineNumero: req.cabineNumero.toString().padLeft(2, '0'),
            clienteNome: req.clienteNome,
            data: _formatDate(req.dataSolicitada),
            hora: '${req.horaInicioDisplay} – ${req.horaFimDisplay}',
            duracao: req.observacao ?? '',
            solicitadoPor: req.solicitanteNome,
            status: req.status,
            onApprove: showActions ? () => onAprovar(req.id) : () {},
            onReject: showActions ? () => onRecusar(req.id) : () {},
          );
        },
      ),
    );
  }
}
