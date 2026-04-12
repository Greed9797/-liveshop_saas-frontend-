import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/cabine.dart';
import '../../models/fila_ativacao_item.dart';
import '../../models/franqueado_analytics_resumo.dart';
import '../../providers/cabines/cabine_detail_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/cabines_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme.dart';
import '../../widgets/action_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cabine_card.dart';
import '../../widgets/status_badge.dart';

class CabinesScreen extends ConsumerStatefulWidget {
  const CabinesScreen({super.key});

  @override
  ConsumerState<CabinesScreen> createState() => _CabinesScreenState();
}

class _CabinesScreenState extends ConsumerState<CabinesScreen> {
  static const _desktopBreakpoint = 1100.0;

  static const _statusFilters = [
    'todos',
    'ao_vivo',
    'reservada',
    'ativa',
    'disponivel',
    'manutencao',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'todos';
  String _searchQuery = '';
  String? _selectedCabineId;
  String? _selectedContratoId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _syncSelectedCabine(List<Cabine> cabines, {required bool isDesktop}) {
    if (!isDesktop || cabines.isEmpty) return;

    final hasCurrentSelection =
        cabines.any((cabine) => cabine.id == _selectedCabineId);
    if (hasCurrentSelection) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _selectedCabineId = cabines.first.id);
    });
  }

  List<Cabine> _applyFilters(List<Cabine> cabines) {
    return cabines.where((cabine) {
      if (_statusFilter != 'todos' && cabine.status != _statusFilter) {
        return false;
      }

      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;

      final searchable = [
        cabine.numero.toString(),
        cabine.clienteNome ?? '',
        cabine.apresentadorNome ?? '',
        cabine.contratoId ?? '',
      ].join(' ').toLowerCase();

      return searchable.contains(query);
    }).toList();
  }

  Cabine? _findSelectedCabine(List<Cabine> cabines) {
    if (cabines.isEmpty) return null;

    for (final cabine in cabines) {
      if (cabine.id == _selectedCabineId) return cabine;
    }

    return cabines.first;
  }

  FilaAtivacaoItem? _findSelectedContrato(List<FilaAtivacaoItem> fila) {
    if (fila.isEmpty) return null;

    for (final item in fila) {
      if (item.id == _selectedContratoId) return item;
    }

    return null;
  }

  Future<void> _openFilaAtivacaoSheet() async {
    final selected = await showModalBottomSheet<FilaAtivacaoItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.colors.cardBackground,
      builder: (_) => const _FilaAtivacaoBottomSheet(),
    );

    if (selected == null || !mounted) return;
    setState(() => _selectedContratoId = selected.id);
  }

  Future<void> _reservarCabine(Cabine cabine, {required bool isDesktop}) async {
    if (_selectedContratoId == null) {
      if (isDesktop) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Selecione um contrato na fila de ativação antes de reservar uma cabine.'),
          ),
        );
      } else {
        await _openFilaAtivacaoSheet();
      }
      return;
    }

    try {
      await ref.read(cabinesProvider.notifier).reservarCabine(
            cabineId: cabine.id,
            contratoId: _selectedContratoId!,
          );

      if (!mounted) return;
      setState(() {
        _selectedContratoId = null;
        if (isDesktop) _selectedCabineId = cabine.id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Cabine ${cabine.numero.toString().padLeft(2, '0')} reservada com sucesso.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService.extractErrorMessage(error))),
      );
    }
  }

  Future<void> _iniciarLive(Cabine cabine) async {
    try {
      await ref.read(cabinesProvider.notifier).iniciarLive(cabineId: cabine.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Live iniciada na cabine ${cabine.numero.toString().padLeft(2, '0')}.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService.extractErrorMessage(error))),
      );
    }
  }

  Future<void> _liberarCabine(Cabine cabine) async {
    try {
      await ref.read(cabinesProvider.notifier).liberarCabine(cabine.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Cabine ${cabine.numero.toString().padLeft(2, '0')} liberada.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService.extractErrorMessage(error))),
      );
    }
  }

  Future<void> _encerrarLive(Cabine cabine) async {
    final fatCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Encerrar Live'),
        content: TextField(
          controller: fatCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Faturamento gerado (R\$)',
            prefixText: 'R\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );

    if (confirmed != true || cabine.liveAtualId == null) return;

    final fatGerado = double.tryParse(fatCtrl.text.replaceAll(',', '.')) ?? 0;
    try {
      await ref
          .read(cabinesProvider.notifier)
          .encerrarLive(cabine.liveAtualId!, fatGerado);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Live encerrada na cabine ${cabine.numero.toString().padLeft(2, '0')}.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService.extractErrorMessage(error))),
      );
    }
  }

  void _handleCabineTap(Cabine cabine, {required bool isDesktop}) {
    if (isDesktop) {
      setState(() => _selectedCabineId = cabine.id);
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.cabineDetail,
      arguments: cabine,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cabinesAsync = ref.watch(cabinesProvider);
    final filaAsync = ref.watch(filaAtivacaoProvider);

    return AppScaffold(
      currentRoute: AppRoutes.cabines,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= _desktopBreakpoint;

          return cabinesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Erro ao carregar cabines: ${ApiService.extractErrorMessage(error)}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(cabinesProvider.notifier).refresh(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
            data: (cabines) {
              _syncSelectedCabine(cabines, isDesktop: isDesktop);
              final filteredCabines = _applyFilters(cabines);
              final metrics = _CabinesMetrics.from(cabines);
              final selectedCabine = _findSelectedCabine(cabines);
              final fila = filaAsync.valueOrNull ?? const <FilaAtivacaoItem>[];
              final selectedContrato = _findSelectedContrato(fila);

              final mainArea = _MainOperationalArea(
                metrics: metrics,
                cabines: filteredCabines,
                statusFilter: _statusFilter,
                searchController: _searchController,
                selectedCabineId: _selectedCabineId,
                selectedContrato: selectedContrato,
                isDesktop: isDesktop,
                onOpenQueue: _openFilaAtivacaoSheet,
                onRefresh: () => ref.read(cabinesProvider.notifier).refresh(),
                onSearchChanged: (value) =>
                    setState(() => _searchQuery = value),
                onFilterChanged: (value) =>
                    setState(() => _statusFilter = value),
                onClearSelectedContrato: selectedContrato == null
                    ? null
                    : () => setState(() => _selectedContratoId = null),
                onCabineTap: (cabine) =>
                    _handleCabineTap(cabine, isDesktop: isDesktop),
                onReservar: (cabine) =>
                    _reservarCabine(cabine, isDesktop: isDesktop),
                onIniciarLive: _iniciarLive,
                onEncerrarLive: _encerrarLive,
                onLiberar: _liberarCabine,
              );

              if (!isDesktop) return mainArea;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: mainArea),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 380,
                    child: _SidebarContent(
                      selectedCabine: selectedCabine,
                      selectedContrato: selectedContrato,
                      filaAsync: filaAsync,
                      onContratoSelected: (contrato) =>
                          setState(() => _selectedContratoId = contrato.id),
                      onClearContrato: selectedContrato == null
                          ? null
                          : () => setState(() => _selectedContratoId = null),
                      onOpenAnalyticalDetail: selectedCabine == null
                          ? null
                          : () => Navigator.pushNamed(
                                context,
                                AppRoutes.cabineDetail,
                                arguments: selectedCabine,
                              ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _MainOperationalArea extends StatelessWidget {
  final _CabinesMetrics metrics;
  final List<Cabine> cabines;
  final String statusFilter;
  final TextEditingController searchController;
  final String? selectedCabineId;
  final FilaAtivacaoItem? selectedContrato;
  final bool isDesktop;
  final VoidCallback onOpenQueue;
  final VoidCallback onRefresh;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback? onClearSelectedContrato;
  final ValueChanged<Cabine> onCabineTap;
  final ValueChanged<Cabine> onReservar;
  final ValueChanged<Cabine> onIniciarLive;
  final ValueChanged<Cabine> onEncerrarLive;
  final ValueChanged<Cabine> onLiberar;

  const _MainOperationalArea({
    required this.metrics,
    required this.cabines,
    required this.statusFilter,
    required this.searchController,
    required this.selectedCabineId,
    required this.selectedContrato,
    required this.isDesktop,
    required this.onOpenQueue,
    required this.onRefresh,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onClearSelectedContrato,
    required this.onCabineTap,
    required this.onReservar,
    required this.onIniciarLive,
    required this.onEncerrarLive,
    required this.onLiberar,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = switch (MediaQuery.of(context).size.width) {
      > 1750 => 5,
      > 1500 => 4,
      > 1200 => 3,
      > 760 => 2,
      _ => 2,
    };

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          sliver: SliverToBoxAdapter(
            child: _HeaderSection(
              onOpenQueue: onOpenQueue,
              onRefresh: onRefresh,
              selectedContrato: selectedContrato,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: _KpiSection(metrics: metrics),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: _ToolbarSection(
              controller: searchController,
              currentFilter: statusFilter,
              onSearchChanged: onSearchChanged,
              onFilterChanged: onFilterChanged,
            ),
          ),
        ),
        if (!isDesktop && selectedContrato != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: SliverToBoxAdapter(
              child: _SelectedContractBanner(
                contrato: selectedContrato!,
                onClear: onClearSelectedContrato,
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          sliver: cabines.isEmpty
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _CabinesEmptyState(),
                )
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cabine = cabines[index];
                      return _OperationalCard(
                        cabine: cabine,
                        isSelected: cabine.id == selectedCabineId,
                        isDesktop: isDesktop,
                        hasSelectedContrato: selectedContrato != null,
                        onTap: () => onCabineTap(cabine),
                        onReservar: cabine.status == 'disponivel'
                            ? () => onReservar(cabine)
                            : null,
                        onIniciarLive: (cabine.status == 'reservada' ||
                                cabine.status == 'ativa')
                            ? () => onIniciarLive(cabine)
                            : null,
                        onEncerrarLive: cabine.status == 'ao_vivo'
                            ? () => onEncerrarLive(cabine)
                            : null,
                        onLiberar: (cabine.status == 'reservada' ||
                                cabine.status == 'ativa')
                            ? () => onLiberar(cabine)
                            : null,
                      );
                    },
                    childCount: cabines.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                ),
        ),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final VoidCallback onOpenQueue;
  final VoidCallback onRefresh;
  final FilaAtivacaoItem? selectedContrato;

  const _HeaderSection({
    required this.onOpenQueue,
    required this.onRefresh,
    required this.selectedContrato,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Painel de Cabines',
              style: AppTypography.h1.copyWith(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Visão operacional da unidade: quem está ao vivo, quem está reservado e o que está rendendo agora.',
              style: TextStyle(color: context.colors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ActionButton(
              label: selectedContrato == null
                  ? 'Fila de Ativação'
                  : 'Contrato selecionado',
              icon: Icons.playlist_add_check_circle_outlined,
              outlined: selectedContrato == null,
              color:
                  selectedContrato == null ? context.colors.info : context.colors.primary,
              onPressed: onOpenQueue,
            ),
            IconButton(
              tooltip: 'Atualizar dados',
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiSection extends StatelessWidget {
  final _CabinesMetrics metrics;

  const _KpiSection({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final items = [
      _KpiCardData('Total', metrics.total.toString(), context.colors.textPrimary,
          'cabines mapeadas'),
      _KpiCardData('Ao vivo', metrics.aoVivo.toString(), context.colors.success,
          'sessões em andamento'),
      _KpiCardData('Reservadas', metrics.reservadas.toString(),
          context.colors.warning, 'aguardando ativação'),
      _KpiCardData('Ativas', metrics.ativas.toString(), context.colors.info,
          'cabines com contrato vigente'),
      _KpiCardData('Livres', metrics.disponiveis.toString(),
          context.colors.textSecondary, 'prontas para receber'),
      _KpiCardData(
          'GMV Total Hoje',
          'R\$ ${metrics.gmvTotalHoje.toStringAsFixed(2)}',
          context.colors.success,
          'soma do ao vivo'),
      _KpiCardData('Audiência Total', metrics.audienciaTotal.toString(),
          context.colors.primary, 'público simultâneo'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: 220,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.compactPadding),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: context.colors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label,
                        style: TextStyle(color: context.colors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(
                      item.value,
                      style: AppTypography.h1.copyWith(fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: item.color),
                    ),
                    const SizedBox(height: 4),
                    Text(item.helper,
                        style: AppTypography.caption.copyWith(color: context.colors.textSecondary)),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ToolbarSection extends StatelessWidget {
  final TextEditingController controller;
  final String currentFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;

  const _ToolbarSection({
    required this.controller,
    required this.currentFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText:
                'Buscar por cliente, apresentador, contrato ou número da cabine',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: context.colors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: context.colors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: context.colors.divider),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _CabinesScreenState._statusFilters
              .map(
                (filter) => ChoiceChip(
                  label: Text(_statusLabel(filter)),
                  selected: currentFilter == filter,
                  onSelected: (_) => onFilterChanged(filter),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'ao_vivo':
        return 'Ao vivo';
      case 'reservada':
        return 'Reservadas';
      case 'ativa':
        return 'Ativas';
      case 'disponivel':
        return 'Livres';
      case 'manutencao':
        return 'Manutenção';
      default:
        return 'Todas';
    }
  }
}

class _SelectedContractBanner extends StatelessWidget {
  final FilaAtivacaoItem contrato;
  final VoidCallback? onClear;

  const _SelectedContractBanner({required this.contrato, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.compactPadding),
      decoration: BoxDecoration(
        color: context.colors.primaryLightBg,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border:
            Border.all(color: context.colors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.link_rounded, color: context.colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contrato selecionado para ativação',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('${contrato.clienteNome} • ${contrato.localizacao}'),
              ],
            ),
          ),
          if (onClear != null)
            TextButton(
              onPressed: onClear,
              child: const Text('Limpar'),
            ),
        ],
      ),
    );
  }
}

class _OperationalCard extends StatelessWidget {
  final Cabine cabine;
  final bool isSelected;
  final bool isDesktop;
  final bool hasSelectedContrato;
  final VoidCallback onTap;
  final VoidCallback? onReservar;
  final VoidCallback? onIniciarLive;
  final VoidCallback? onEncerrarLive;
  final VoidCallback? onLiberar;

  const _OperationalCard({
    required this.cabine,
    required this.isSelected,
    required this.isDesktop,
    required this.hasSelectedContrato,
    required this.onTap,
    this.onReservar,
    this.onIniciarLive,
    this.onEncerrarLive,
    this.onLiberar,
  });

  String _trendLabel() {
    if (cabine.status == 'ao_vivo' && cabine.viewerCount > 0) {
      return cabine.gmvAtual > 500
          ? '↑ acima da média da unidade'
          : '→ operação estável';
    }

    if (cabine.status == 'reservada') {
      return 'Pronta para ativação';
    }
    if (cabine.status == 'ativa') {
      return 'Contrato vigente aguardando próxima live';
    }
    if (cabine.status == 'disponivel') {
      return 'Capacidade ociosa disponível';
    }
    return 'Intervenção técnica necessária';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CabineCard(
            cabine: cabine,
            onTap: onTap,
            isSelected: isSelected,
            isSelectable:
                hasSelectedContrato && cabine.status == 'disponivel',
          ),
        ),
        const SizedBox(height: 8),
        _OperationalActions(
          cabine: cabine,
          onReservar: onReservar,
          onIniciarLive: onIniciarLive,
          onEncerrarLive: onEncerrarLive,
          onLiberar: onLiberar,
        ),
        if (!isDesktop) ...[
          const SizedBox(height: 4),
          TextButton(
            onPressed: onTap,
            child: const Text('Ver dashboard'),
          ),
        ],
      ],
    );
  }
}

class _OperationalActions extends StatelessWidget {
  final Cabine cabine;
  final VoidCallback? onReservar;
  final VoidCallback? onIniciarLive;
  final VoidCallback? onEncerrarLive;
  final VoidCallback? onLiberar;

  const _OperationalActions({
    required this.cabine,
    this.onReservar,
    this.onIniciarLive,
    this.onEncerrarLive,
    this.onLiberar,
  });

  @override
  Widget build(BuildContext context) {
    if (cabine.status == 'ao_vivo') {
      return ActionButton(
        label: 'ENCERRAR LIVE',
        icon: Icons.stop_circle_rounded,
        outlined: false,
        color: context.colors.error,
        onPressed: onEncerrarLive,
      );
    }

    if (cabine.status == 'reservada' || cabine.status == 'ativa') {
      return Row(
        children: [
          Expanded(
            child: ActionButton(
              label: 'INICIAR LIVE',
              icon: Icons.play_arrow_rounded,
              onPressed: onIniciarLive,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(onPressed: onLiberar, child: const Text('Liberar')),
        ],
      );
    }

    if (cabine.status == 'disponivel') {
      return ActionButton(
        label: 'VINCULAR CONTRATO',
        icon: Icons.link_rounded,
        outlined: true,
        color: context.colors.info,
        onPressed: onReservar,
      );
    }

    return ActionButton(
      label: 'MANUTENÇÃO',
      outlined: true,
      color: context.colors.textTertiary,
      onPressed: null,
    );
  }
}

class _SidebarContent extends ConsumerWidget {
  final Cabine? selectedCabine;
  final FilaAtivacaoItem? selectedContrato;
  final AsyncValue<List<FilaAtivacaoItem>> filaAsync;
  final ValueChanged<FilaAtivacaoItem> onContratoSelected;
  final VoidCallback? onClearContrato;
  final VoidCallback? onOpenAnalyticalDetail;

  const _SidebarContent({
    required this.selectedCabine,
    required this.selectedContrato,
    required this.filaAsync,
    required this.onContratoSelected,
    this.onClearContrato,
    this.onOpenAnalyticalDetail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabine = selectedCabine;
    final detailAsync = cabine == null
        ? AsyncValue<CabineDetailState>.data(CabineDetailState())
        : ref.watch(cabineDetailProvider(cabine.id));

    return Container(
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.colors.divider),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trilho Operacional',
            style: AppTypography.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Da fila de ativação ao raio-X da cabine, sem sair do painel.',
            style: TextStyle(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SelectedCabinePanel(
                    cabine: cabine,
                    detailAsync: detailAsync,
                    onOpenAnalyticalDetail: onOpenAnalyticalDetail,
                  ),
                  const SizedBox(height: 16),
                  _QueuePanel(
                    filaAsync: filaAsync,
                    selectedContrato: selectedContrato,
                    onContratoSelected: onContratoSelected,
                    onClearContrato: onClearContrato,
                  ),
                  const SizedBox(height: 16),
                  _MiniAnalyticsPanel(detailAsync: detailAsync),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedCabinePanel extends StatelessWidget {
  final Cabine? cabine;
  final AsyncValue<CabineDetailState> detailAsync;
  final VoidCallback? onOpenAnalyticalDetail;

  const _SelectedCabinePanel({
    required this.cabine,
    required this.detailAsync,
    this.onOpenAnalyticalDetail,
  });

  @override
  Widget build(BuildContext context) {
    return _SidebarCard(
      title: 'Cabine Selecionada',
      child: cabine == null
          ? const Text(
              'Selecione uma cabine no grid para inspecionar a operação desta unidade.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Cabine ${cabine!.numero.toString().padLeft(2, '0')}',
                        style: AppTypography.h3.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    StatusBadge(status: cabine!.status),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoLine(
                    label: 'Cliente',
                    value: cabine!.clienteNome ?? 'Sem vínculo ativo'),
                _InfoLine(
                    label: 'Contrato',
                    value:
                        cabine!.contratoId?.substring(0, 8) ?? 'Sem contrato'),
                _InfoLine(
                    label: 'Apresentador',
                    value: cabine!.apresentadorNome ?? 'A definir'),
                const SizedBox(height: 12),
                detailAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
                  error: (_, __) => const Text(
                      'Não foi possível carregar os indicadores detalhados desta cabine.'),
                  data: (detail) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoLine(
                        label: 'GMV atual',
                        value: detail.liveAtual == null
                            ? 'Sem live agora'
                            : 'R\$ ${detail.liveAtual!.gmvAtual.toStringAsFixed(2)}',
                      ),
                      _InfoLine(
                        label: 'Audiência',
                        value: detail.liveAtual == null
                            ? '0 espectadores'
                            : '${detail.liveAtual!.viewerCount} espectadores',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ActionButton(
                  label: 'VER ANALÍTICO COMPLETO',
                  icon: Icons.analytics_outlined,
                  outlined: true,
                  onPressed: onOpenAnalyticalDetail,
                ),
              ],
            ),
    );
  }
}

class _QueuePanel extends StatelessWidget {
  final AsyncValue<List<FilaAtivacaoItem>> filaAsync;
  final FilaAtivacaoItem? selectedContrato;
  final ValueChanged<FilaAtivacaoItem> onContratoSelected;
  final VoidCallback? onClearContrato;

  const _QueuePanel({
    required this.filaAsync,
    required this.selectedContrato,
    required this.onContratoSelected,
    this.onClearContrato,
  });

  @override
  Widget build(BuildContext context) {
    return _SidebarCard(
      title: 'Fila de Ativação',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedContrato != null) ...[
            _SelectedContractBanner(
                contrato: selectedContrato!, onClear: onClearContrato),
            const SizedBox(height: 12),
          ],
          filaAsync.when(
            loading: () => const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            )),
            error: (error, _) => Text(ApiService.extractErrorMessage(error)),
            data: (fila) {
              if (fila.isEmpty) {
                return const Text(
                    'Nenhum contrato ativo aguardando cabine no momento.');
              }

              return Column(
                children: fila.take(4).map((item) {
                  final isSelected = selectedContrato?.id == item.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => onContratoSelected(item),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          color: isSelected
                              ? context.colors.primaryLightBg
                              : context.colors.background,
                          border: Border.all(
                            color: isSelected
                                ? context.colors.primary
                                    .withValues(alpha: 0.35)
                                : context.colors.divider,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.clienteNome,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(item.localizacao,
                                style: TextStyle(
                                    color: context.colors.textSecondary)),
                            const SizedBox(height: 8),
                            Text(
                              'Contrato ${item.id.substring(0, 8)} • Fixo R\$ ${item.valorFixo.toStringAsFixed(2)}',
                              style: AppTypography.caption.copyWith(color: context.colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MiniAnalyticsPanel extends ConsumerWidget {
  final AsyncValue<CabineDetailState> detailAsync;

  const _MiniAnalyticsPanel({required this.detailAsync});

  static final NumberFormat _currency =
      NumberFormat.simpleCurrency(locale: 'pt_BR');

  String _formatHourBucket(int hora) {
    final end = (hora + 1) % 24;
    return '${hora.toString().padLeft(2, '0')}h-${end.toString().padLeft(2, '0')}h';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(franqueadoAnalyticsResumoProvider);

    return _SidebarCard(
      title: 'Mini Analytics',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: analyticsAsync.when(
          loading: () => const Padding(
            key: ValueKey('analytics-loading'),
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Text(
            ApiService.extractErrorMessage(error),
            key: const ValueKey('analytics-error'),
          ),
          data: (analytics) {
            final historico = detailAsync.valueOrNull?.historico;
            final cabineTopClientes =
                historico?.topClientes.take(3).toList() ?? const [];
            final cabineMelhoresHorarios =
                historico?.melhoresHorarios.take(3).toList() ?? const [];
            final heatmapTop = [...analytics.heatmapHorarios]
              ..sort((a, b) => b.gmvTotal.compareTo(a.gmvTotal));

            return Column(
              key: const ValueKey('analytics-data'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnalyticsSummaryRow(resumo: analytics.resumoHoje),
                const SizedBox(height: 16),
                const Text('Top Closers da unidade',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (analytics.rankingClosers.isEmpty)
                  const Text('Nenhum closer com histórico suficiente ainda.')
                else
                  ...analytics.rankingClosers
                      .take(3)
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _RankedMetricRow(
                            rank: entry.key,
                            title: entry.value.apresentadorNome,
                            subtitle:
                                '${entry.value.totalLives} lives fechadas',
                            value: _currency.format(entry.value.gmvTotal),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                const Text('Top Parceiros por volume',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (analytics.rankingClientes.isEmpty)
                  const Text('Nenhum parceiro com volume relevante ainda.')
                else
                  ...analytics.rankingClientes.take(3).map(
                        (cliente) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _MetricRankRow(
                            title: cliente.clienteNome,
                            value: _currency.format(cliente.gmvTotal),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                const Text('Prime time da franquia',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (analytics.heatmapHorarios.isEmpty)
                  const Text(
                      'Ainda não há dados suficientes para mapear o melhor horário da unidade.')
                else
                  ...heatmapTop.take(3).map(
                        (horario) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _MetricRankRow(
                            title: _formatHourBucket(horario.hora),
                            value: _currency.format(horario.gmvTotal),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                const Text('Raio-X da cabine selecionada',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (historico == null)
                  const Text(
                      'Selecione uma cabine no grid para ver os clientes e horários fortes desta unidade.')
                else ...[
                  if (cabineTopClientes.isEmpty)
                    const Text(
                        'Sem histórico de clientes para esta cabine ainda.')
                  else
                    ...cabineTopClientes.map(
                      (cliente) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _MetricRankRow(
                          title: cliente['nome'] as String,
                          value: _currency
                              .format((cliente['fat_total'] as num).toDouble()),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (cabineMelhoresHorarios.isEmpty)
                    const Text(
                        'Ainda não há amostra suficiente para sugerir janelas ideais desta cabine.')
                  else
                    ...cabineMelhoresHorarios.map(
                      (horario) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _MetricRankRow(
                          title: horario['hora'] as String,
                          value:
                              'GMV médio ${_currency.format((horario['gmv_medio'] as num).toDouble())}',
                        ),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SidebarCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SidebarCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.compactPadding),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 94,
            child: Text(
              '$label:',
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRankRow extends StatelessWidget {
  final String title;
  final String value;

  const _MetricRankRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(child: Text(value, style: TextStyle(color: context.colors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _RankedMetricRow extends StatelessWidget {
  final int rank;
  final String title;
  final String subtitle;
  final String value;

  const _RankedMetricRow({
    required this.rank,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final rankLabel = switch (rank) {
      0 => 'Ouro',
      1 => 'Prata',
      _ => 'Bronze',
    };

    final rankColor = switch (rank) {
      0 => AppColors.medalGold,
      1 => AppColors.medalSilver,
      _ => AppColors.medalBronze,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: rankColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            rankLabel,
            style: AppTypography.labelSmall.copyWith(
                color: rankColor, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: AppTypography.caption.copyWith(color: context.colors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(value, style: TextStyle(color: context.colors.textSecondary)),
      ],
    );
  }
}

class _AnalyticsSummaryRow extends StatelessWidget {
  final ResumoHojeAnalytics resumo;

  const _AnalyticsSummaryRow({required this.resumo});

  static final NumberFormat _currency =
      NumberFormat.simpleCurrency(locale: 'pt_BR');

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        'GMV hoje',
        _currency.format(resumo.gmvTotalHoje),
        context.colors.success
      ),
      ('Audiência', '${resumo.audienciaTotalAoVivo}', context.colors.primary),
      ('Lives hoje', '${resumo.totalLivesHoje}', context.colors.info),
    ];

    return Row(
      children: cards
          .map(
            (item) => Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                margin: EdgeInsets.only(right: item == cards.last ? 0 : 8),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: context.colors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.$1,
                        style: AppTypography.labelSmall.copyWith(color: context.colors.textSecondary)),
                    const SizedBox(height: 6),
                    Text(
                      item.$2,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: item.$3),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CabinesEmptyState extends StatelessWidget {
  const _CabinesEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: context.colors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_camera_front_outlined,
                size: 42, color: context.colors.textTertiary),
            const SizedBox(height: 12),
            Text(
              'Nenhuma cabine cadastrada nesta unidade.',
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Quando a infraestrutura estiver configurada, as cabines aparecerão aqui com estado operacional em tempo real.',
              style: AppTypography.bodySmall.copyWith(color: context.colors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaAtivacaoBottomSheet extends ConsumerWidget {
  const _FilaAtivacaoBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filaAsync = ref.watch(filaAtivacaoProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fila de Ativação',
              style: AppTypography.h2.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Selecione um contrato ativo e depois toque em uma cabine disponível.',
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: filaAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(ApiService.extractErrorMessage(error)),
                ),
                data: (fila) {
                  if (fila.isEmpty) {
                    return const Center(
                      child: Text(
                          'Nenhum contrato ativo aguardando cabine no momento.'),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: fila.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = fila[index];
                      return InkWell(
                        onTap: () => Navigator.pop(context, item),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.compactPadding),
                          decoration: BoxDecoration(
                            color: context.colors.cardBackground,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: context.colors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.clienteNome,
                                  style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(item.localizacao,
                                  style: TextStyle(
                                      color: context.colors.textSecondary)),
                              const SizedBox(height: 8),
                              Text(
                                'Contrato ${item.id.substring(0, 8)} • Fixo R\$ ${item.valorFixo.toStringAsFixed(2)} • Comissão ${item.comissaoPct.toStringAsFixed(0)}%',
                                style: AppTypography.caption.copyWith(
                                    color: context.colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCardData {
  final String label;
  final String value;
  final Color color;
  final String helper;

  const _KpiCardData(this.label, this.value, this.color, this.helper);
}

// ─── METRICS ─────────────────────────────────────────────────────────────────

class _CabinesMetrics {
  final int total;
  final int aoVivo;
  final int reservadas;
  final int ativas;
  final int disponiveis;
  final double gmvTotalHoje;
  final int audienciaTotal;

  const _CabinesMetrics({
    required this.total,
    required this.aoVivo,
    required this.reservadas,
    required this.ativas,
    required this.disponiveis,
    required this.gmvTotalHoje,
    required this.audienciaTotal,
  });

  factory _CabinesMetrics.from(List<Cabine> cabines) {
    return _CabinesMetrics(
      total: cabines.length,
      aoVivo: cabines.where((c) => c.status == 'ao_vivo').length,
      reservadas: cabines.where((c) => c.status == 'reservada').length,
      ativas: cabines.where((c) => c.status == 'ativa').length,
      disponiveis: cabines.where((c) => c.status == 'disponivel').length,
      gmvTotalHoje: cabines.fold(0.0, (sum, c) => sum + c.gmvAtual),
      audienciaTotal: cabines.fold(0, (sum, c) => sum + c.viewerCount),
    );
  }
}

