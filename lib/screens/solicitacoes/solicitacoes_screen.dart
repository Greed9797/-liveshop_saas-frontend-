import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/solicitacoes_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/status_badge.dart';

class SolicitacoesScreen extends ConsumerStatefulWidget {
  const SolicitacoesScreen({super.key});

  @override
  ConsumerState<SolicitacoesScreen> createState() =>
      _SolicitacoesScreenState();
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
        SnackBar(
          content: const Text('Live aprovada com sucesso!'),
          backgroundColor: context.colors.success,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: context.colors.error,
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
            await ref
                .read(solicitacoesProvider.notifier)
                .recusar(id, motivo);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Solicitação recusada.')),
            );
          } on ApiException catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                backgroundColor: context.colors.error,
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

    final pendentesCount = solicitacoesAsync.valueOrNull
            ?.where((s) => s.status == 'pendente')
            .length ??
        0;

    return AppScaffold(
      currentRoute: AppRoutes.solicitacoes,
      child: Column(
        children: [
          // ── Barra de abas ──
          Material(
            color: context.colors.cardBackground,
            elevation: 1,
            child: TabBar(
              controller: _tabController,
              labelColor: context.colors.primary,
              unselectedLabelColor: context.colors.textSecondary,
              indicatorColor: context.colors.primary,
              tabs: [
                Tab(
                  text: pendentesCount > 0
                      ? 'Pendentes ($pendentesCount)'
                      : 'Pendentes',
                ),
                const Tab(text: 'Todas'),
              ],
            ),
          ),

          // ── Conteúdo ──
          Expanded(
            child: solicitacoesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding:
                      const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: context.colors.error),
                      const SizedBox(height: AppSpacing.md),
                      Text('Erro: $error',
                          textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () => ref
                            .read(solicitacoesProvider.notifier)
                            .refresh(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (solicitacoes) {
                final pendentes = solicitacoes
                    .where((s) => s.status == 'pendente')
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 0: Pendentes
                    _SolicitacoesLista(
                      items: pendentes,
                      emptyIcon: Icons.check_circle_outline_rounded,
                      emptyMessage: 'Nenhuma solicitação pendente',
                      showActions: true,
                      onAprovar: _aprovar,
                      onRecusar: _recusar,
                      onRefresh: () => ref
                          .read(solicitacoesProvider.notifier)
                          .refresh(),
                    ),
                    // Tab 1: Todas
                    _SolicitacoesLista(
                      items: solicitacoes,
                      emptyIcon: Icons.inbox_outlined,
                      emptyMessage: 'Nenhuma solicitação registrada',
                      showActions: false,
                      onAprovar: _aprovar,
                      onRecusar: _recusar,
                      onRefresh: () => ref
                          .read(solicitacoesProvider.notifier)
                          .refresh(),
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
      title: Row(
        children: [
          Icon(Icons.block_rounded, color: context.colors.error, size: 20),
          const SizedBox(width: 8),
          const Text('Motivo da recusa'),
        ],
      ),
      content: TextField(
        controller: ctrl,
        decoration: const InputDecoration(
          hintText: 'Explique o motivo da recusa...',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error),
          onPressed: () {
            final motivo = ctrl.text.trim();
            if (motivo.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('O motivo é obrigatório')),
              );
              return;
            }
            onConfirmar(motivo);
          },
          child: const Text('Confirmar',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Lista de solicitações (reutilizada em ambas as tabs)
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

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 64, color: context.colors.textTertiary),
            const SizedBox(height: AppSpacing.lg),
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
      color: context.colors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _SolicitacaoCard(
          item: items[i],
          showActions: showActions,
          onAprovar: onAprovar,
          onRecusar: onRecusar,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Card de solicitação
// ──────────────────────────────────────────────────────────────

class _SolicitacaoCard extends StatefulWidget {
  final SolicitacaoFranqueador item;
  final bool showActions;
  final Future<void> Function(String) onAprovar;
  final void Function(String) onRecusar;

  const _SolicitacaoCard({
    required this.item,
    required this.showActions,
    required this.onAprovar,
    required this.onRecusar,
  });

  @override
  State<_SolicitacaoCard> createState() => _SolicitacaoCardState();
}

class _SolicitacaoCardState extends State<_SolicitacaoCard> {
  bool _isAprovando = false;

  static final _dateDisplay = DateFormat('dd/MM/yyyy');

  String _formatDate(String raw) {
    try {
      return _dateDisplay
          .format(DateFormat('yyyy-MM-dd').parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.item;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabeçalho: cabine + cliente + badge ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Cabine ${s.cabineNumero.toString().padLeft(2, '0')}',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  s.clienteNome,
                  style: AppTypography.bodySmall
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(status: s.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Data e horário ──
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: context.colors.textTertiary),
              const SizedBox(width: 4),
              Text(
                _formatDate(s.dataSolicitada),
                style: AppTypography.caption
                    .copyWith(color: context.colors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.access_time_rounded,
                  size: 14, color: context.colors.textTertiary),
              const SizedBox(width: 4),
              Text(
                '${s.horaInicioDisplay} – ${s.horaFimDisplay}',
                style: AppTypography.caption
                    .copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),

          // ── Observação (condicional) ──
          if (s.observacao != null && s.observacao!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 13, color: context.colors.textTertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    s.observacao!,
                    style: AppTypography.caption
                        .copyWith(color: context.colors.textSecondary),
                  ),
                ),
              ],
            ),
          ],

          // ── Motivo de recusa (condicional) ──
          if (s.status == 'recusada' &&
              s.motivoRecusa != null &&
              s.motivoRecusa!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.block_rounded,
                      size: 13, color: context.colors.error),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      s.motivoRecusa!,
                      style: AppTypography.caption
                          .copyWith(color: context.colors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Ações (apenas em pendentes) ──
          if (widget.showActions) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: Icon(Icons.close_rounded,
                      size: 16, color: context.colors.error),
                  label: Text('Recusar',
                      style: TextStyle(color: context.colors.error)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.colors.error),
                  ),
                  onPressed: _isAprovando
                      ? null
                      : () => widget.onRecusar(s.id),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton.icon(
                  icon: _isAprovando
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white),
                  label: const Text('Aprovar',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.success),
                  onPressed: _isAprovando
                      ? null
                      : () async {
                          setState(() => _isAprovando = true);
                          await widget.onAprovar(s.id);
                          if (mounted) {
                            setState(() => _isAprovando = false);
                          }
                        },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
