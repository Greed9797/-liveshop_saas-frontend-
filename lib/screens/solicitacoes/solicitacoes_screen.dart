import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../design_system/design_system.dart';
import '../../providers/solicitacoes_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../widgets/solicitacao_card.dart';

class SolicitacoesScreen extends ConsumerStatefulWidget {
  final bool embedded;

  const SolicitacoesScreen({super.key, this.embedded = false});

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

    final content = Column(
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
    );

    final contentWithFab = Stack(
      children: [
        content,
        Positioned(
          bottom: AppSpacing.x4,
          right: AppSpacing.x4,
          child: FloatingActionButton.extended(
            onPressed: () => _mostrarNovoAgendamento(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Novo Agendamento'),
          ),
        ),
      ],
    );

    if (widget.embedded) return contentWithFab;

    return AppScreenScaffold(
      currentRoute: AppRoutes.agendamentos,
      title: 'Agendamentos de Lives',
      eyebrow: 'Agenda operacional',
      titleSerif: true,
      subtitle: 'Aprove, recuse e acompanhe pedidos de horário dos clientes.',
      child: contentWithFab,
    );
  }

  Future<void> _mostrarNovoAgendamento(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _NovoAgendamentoDialog(
        onSalvar: (data) async {
          await ref
              .read(solicitacoesProvider.notifier)
              .criarAgendamento(data);
        },
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

class _SolicitacoesLista extends StatefulWidget {
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
  State<_SolicitacoesLista> createState() => _SolicitacoesListaState();
}

class _SolicitacoesListaState extends State<_SolicitacoesLista> {
  String _statusFilter = 'todos';
  String _filtroData = '';
  String _filtroCabine = '';
  final _dataCtrl = TextEditingController();
  final _cabineCtrl = TextEditingController();

  static final _dateDisplay = DateFormat('dd/MM/yyyy');
  static final _dateParser = DateFormat('yyyy-MM-dd');

  @override
  void dispose() {
    _dataCtrl.dispose();
    _cabineCtrl.dispose();
    super.dispose();
  }

  String _formatDate(String raw) {
    try {
      return _dateDisplay.format(_dateParser.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  bool get _hasActiveFilters =>
      (!widget.showActions && _statusFilter != 'todos') ||
      _filtroData.isNotEmpty ||
      _filtroCabine.isNotEmpty;

  List<SolicitacaoFranqueador> get _filtered {
    return widget.items.where((item) {
      // Status filter (only in Todas tab)
      if (!widget.showActions && _statusFilter != 'todos') {
        if (item.status != _statusFilter) return false;
      }
      // Data filter
      if (_filtroData.isNotEmpty) {
        final formatted = _formatDate(item.dataSolicitada);
        if (!formatted.contains(_filtroData)) return false;
      }
      // Cabine filter
      if (_filtroCabine.isNotEmpty) {
        if (!item.cabineNumero.toString().contains(_filtroCabine)) return false;
      }
      return true;
    }).toList();
  }

  void _limparFiltros() {
    setState(() {
      _statusFilter = 'todos';
      _filtroData = '';
      _filtroCabine = '';
      _dataCtrl.clear();
      _cabineCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    // Empty original list (no data at all)
    if (widget.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.emptyIcon, size: 64, color: context.colors.textMuted),
            const SizedBox(height: AppSpacing.x4),
            Text(
              widget.emptyMessage,
              style: AppTypography.bodyMedium
                  .copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── Filter Bar ──
        _FilterBar(
          showStatusChips: !widget.showActions,
          statusFilter: _statusFilter,
          dataCtrl: _dataCtrl,
          cabineCtrl: _cabineCtrl,
          hasActiveFilters: _hasActiveFilters,
          onStatusChanged: (v) => setState(() => _statusFilter = v),
          onDataChanged: (v) => setState(() => _filtroData = v),
          onCabineChanged: (v) => setState(() => _filtroCabine = v),
          onLimpar: _limparFiltros,
        ),

        // ── List or empty-filtered state ──
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 56, color: context.colors.textMuted),
                      const SizedBox(height: AppSpacing.x4),
                      Text(
                        'Nenhum resultado para os filtros aplicados',
                        style: AppTypography.bodyMedium
                            .copyWith(color: context.colors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.x4),
                      AppSecondaryButton(
                        label: 'Limpar filtros',
                        icon: Icons.filter_list_off_rounded,
                        onPressed: _limparFiltros,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: widget.onRefresh,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.x4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.x3),
                    itemBuilder: (ctx, i) {
                      final req = filtered[i];
                      return SolicitacaoCard(
                        cabineNumero:
                            req.cabineNumero.toString().padLeft(2, '0'),
                        clienteNome: req.clienteNome,
                        data: _formatDate(req.dataSolicitada),
                        hora:
                            '${req.horaInicioDisplay} – ${req.horaFimDisplay}',
                        duracao: req.observacao ?? '',
                        solicitadoPor: req.solicitanteNome,
                        apresentadoraNome: req.apresentadoraNome,
                        status: req.status,
                        onApprove:
                            widget.showActions ? () => widget.onAprovar(req.id) : () {},
                        onReject:
                            widget.showActions ? () => widget.onRecusar(req.id) : () {},
                        showStatusBadge: !widget.showActions,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Filter Bar widget
// ──────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final bool showStatusChips;
  final String statusFilter;
  final TextEditingController dataCtrl;
  final TextEditingController cabineCtrl;
  final bool hasActiveFilters;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onDataChanged;
  final ValueChanged<String> onCabineChanged;
  final VoidCallback onLimpar;

  const _FilterBar({
    required this.showStatusChips,
    required this.statusFilter,
    required this.dataCtrl,
    required this.cabineCtrl,
    required this.hasActiveFilters,
    required this.onStatusChanged,
    required this.onDataChanged,
    required this.onCabineChanged,
    required this.onLimpar,
  });

  static const _statusOpts = [
    ('todos', 'Todos'),
    ('pendente', 'Pendente'),
    ('aprovada', 'Aprovada'),
    ('recusada', 'Recusada'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.bgCard,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.x4, AppSpacing.x3, AppSpacing.x4, AppSpacing.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status chips row (Todas tab only)
          if (showStatusChips) ...[
            Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x2,
              children: _statusOpts.map((opt) {
                final (value, label) = opt;
                final isActive = statusFilter == value;
                return AppChip(
                  label: label,
                  active: isActive,
                  onTap: () => onStatusChanged(value),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.x3),
          ],
          // Text fields row
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextFormField(
                    controller: dataCtrl,
                    onChanged: onDataChanged,
                    keyboardType: TextInputType.datetime,
                    style: AppTypography.bodySmall,
                    decoration: InputDecoration(
                      hintText: 'Data (dd/mm/aaaa)',
                      hintStyle: AppTypography.bodySmall
                          .copyWith(color: context.colors.textMuted),
                      prefixIcon: Icon(Icons.calendar_today_outlined,
                          size: 16, color: context.colors.textMuted),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x2, vertical: AppSpacing.x2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextFormField(
                    controller: cabineCtrl,
                    onChanged: onCabineChanged,
                    keyboardType: TextInputType.number,
                    style: AppTypography.bodySmall,
                    decoration: InputDecoration(
                      hintText: 'Cabine nº',
                      hintStyle: AppTypography.bodySmall
                          .copyWith(color: context.colors.textMuted),
                      prefixIcon: Icon(Icons.meeting_room_outlined,
                          size: 16, color: context.colors.textMuted),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x2, vertical: AppSpacing.x2),
                    ),
                  ),
                ),
              ),
              if (hasActiveFilters) ...[
                const SizedBox(width: AppSpacing.x2),
                TextButton.icon(
                  onPressed: onLimpar,
                  icon: const Icon(Icons.filter_list_off_rounded, size: 16),
                  label: const Text('Limpar'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2),
                    visualDensity: VisualDensity.compact,
                    textStyle: AppTypography.bodySmall,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Dialog: Novo Agendamento (criado pelo franqueado)
// ──────────────────────────────────────────────────────────────

class _NovoAgendamentoDialog extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> data) onSalvar;

  const _NovoAgendamentoDialog({required this.onSalvar});

  @override
  State<_NovoAgendamentoDialog> createState() => _NovoAgendamentoDialogState();
}

class _NovoAgendamentoDialogState extends State<_NovoAgendamentoDialog> {
  final _cabineIdCtrl      = TextEditingController();
  final _clienteIdCtrl     = TextEditingController();
  final _apresentadoraCtrl = TextEditingController();
  final _dataCtrl          = TextEditingController();
  final _horaInicioCtrl    = TextEditingController();
  final _horaFimCtrl       = TextEditingController();
  final _obsCtrl           = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _cabineIdCtrl.dispose();
    _clienteIdCtrl.dispose();
    _apresentadoraCtrl.dispose();
    _dataCtrl.dispose();
    _horaInicioCtrl.dispose();
    _horaFimCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final cabineId  = _cabineIdCtrl.text.trim();
    final clienteId = _clienteIdCtrl.text.trim();
    final data      = _dataCtrl.text.trim();
    final hI        = _horaInicioCtrl.text.trim();
    final hF        = _horaFimCtrl.text.trim();

    if (cabineId.isEmpty || clienteId.isEmpty || data.isEmpty || hI.isEmpty || hF.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha todos os campos obrigatórios')));
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onSalvar({
        'cabine_id':        cabineId,
        'cliente_id':       clienteId,
        if (_apresentadoraCtrl.text.trim().isNotEmpty)
          'apresentadora_id': _apresentadoraCtrl.text.trim(),
        'data_solicitada':  data,
        'hora_inicio':      hI,
        'hora_fim':         hF,
        if (_obsCtrl.text.trim().isNotEmpty)
          'observacao': _obsCtrl.text.trim(),
      });
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ApiService.extractErrorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      title: const Row(children: [
        Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
        SizedBox(width: AppSpacing.x2),
        Text('Novo Agendamento'),
      ]),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: _cabineIdCtrl,
                  hint: 'ID da Cabine *'),
              const SizedBox(height: AppSpacing.x3),
              AppTextField(controller: _clienteIdCtrl,
                  hint: 'ID do Cliente *'),
              const SizedBox(height: AppSpacing.x3),
              AppTextField(controller: _apresentadoraCtrl,
                  hint: 'ID da Apresentadora (opcional)'),
              const SizedBox(height: AppSpacing.x3),
              AppTextField(controller: _dataCtrl,
                  hint: 'Data (YYYY-MM-DD) *',
                  keyboardType: TextInputType.datetime),
              const SizedBox(height: AppSpacing.x3),
              Row(children: [
                Expanded(
                  child: AppTextField(controller: _horaInicioCtrl,
                      hint: 'Início (HH:MM) *',
                      keyboardType: TextInputType.datetime),
                ),
                const SizedBox(width: AppSpacing.x2),
                Expanded(
                  child: AppTextField(controller: _horaFimCtrl,
                      hint: 'Fim (HH:MM) *',
                      keyboardType: TextInputType.datetime),
                ),
              ]),
              const SizedBox(height: AppSpacing.x3),
              AppTextField(controller: _obsCtrl,
                  hint: 'Observação (opcional)',
                  keyboardType: TextInputType.multiline),
            ],
          ),
        ),
      ),
      actions: [
        AppSecondaryButton(
            label: 'Cancelar',
            onPressed: () => Navigator.of(context).pop()),
        AppPrimaryButton(
            label: 'Agendar',
            isLoading: _saving,
            onPressed: _salvar),
      ],
    );
  }
}
