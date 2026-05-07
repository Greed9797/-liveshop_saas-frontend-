import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_routes.dart';
import '../../../services/api_service.dart';
import '../../core/responsive.dart';
import '../../theme/tokens.dart';
import '../../theme/livelab_theme.dart';
import '../../widgets/livelab_scaffold.dart';
import '../../widgets/ll_button.dart';
import 'cabines_models.dart';
import 'cabines_repository.dart';
import 'widgets/cabin_card.dart';
import 'widgets/cabin_filter_bar.dart';
import 'widgets/occupancy_panel.dart';
import 'widgets/schedule_timeline.dart';
import 'widgets/quick_actions_panel.dart';

class CabinesScreen extends StatefulWidget {
  const CabinesScreen({super.key, required this.repository});
  final CabinesRepository repository;

  @override
  State<CabinesScreen> createState() => _CabinesScreenState();
}

class _CabinesScreenState extends State<CabinesScreen> {
  late Future<List<Cabin>> _future;
  late Future<List<UpcomingScheduleEntry>> _proximasFuture;
  CabinFilters _filters = const CabinFilters();
  int? _selected;
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = widget.repository.fetchAll();
      _proximasFuture = widget.repository.fetchProximas4h();
    });
  }

  void _setBusy(String id, bool busy) {
    if (!mounted) return;
    setState(() {
      if (busy) {
        _busy.add(id);
      } else {
        _busy.remove(id);
      }
    });
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red.shade700 : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _runAction(Cabin c, Future<void> Function() action, String successMsg) async {
    _setBusy(c.id, true);
    try {
      await action();
      _toast(successMsg);
      _reload();
    } catch (e) {
      _toast(ApiService.extractErrorMessage(e), error: true);
    } finally {
      _setBusy(c.id, false);
    }
  }

  Future<void> _iniciarLive(Cabin c) async {
    final clienteId = c.clienteId;
    if (clienteId == null || clienteId.isEmpty) {
      _toast('Cabine sem cliente vinculado. Reserve antes de iniciar.', error: true);
      return;
    }
    final tituloCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Iniciar live · Cabine ${c.number.toString().padLeft(2, '0')}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(c.client ?? 'Cliente vinculado'),
            const SizedBox(height: 12),
            TextField(
              controller: tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título da live (opcional)',
                hintText: 'Ex: Beauty Trend Quinta',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _runAction(
      c,
      () => widget.repository.iniciarLiveManual(
        c.id,
        clienteId: clienteId,
        titulo: tituloCtrl.text.trim().isEmpty ? null : tituloCtrl.text.trim(),
      ),
      'Live iniciada na cabine ${c.number.toString().padLeft(2, '0')}',
    );
  }

  Future<void> _encerrarLive(Cabin c) async {
    final liveId = c.liveAtualId;
    if (liveId == null) {
      _toast('Sem live ativa nesta cabine', error: true);
      return;
    }
    final fatCtrl = TextEditingController(text: c.gmv > 0 ? c.gmv.toStringAsFixed(2) : '0');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Encerrar live · Cabine ${c.number.toString().padLeft(2, '0')}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Informe o faturamento gerado na live (R\$):'),
            const SizedBox(height: 12),
            TextField(
              controller: fatCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: 'R\$ ',
                hintText: '0.00',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final fat = double.tryParse(fatCtrl.text.replaceAll(',', '.')) ?? 0;
    await _runAction(
      c,
      () => widget.repository.encerrarLive(liveId, fatGerado: fat),
      'Live encerrada · R\$ ${fat.toStringAsFixed(2)}',
    );
  }

  Future<void> _liberar(Cabin c) async {
    await _runAction(
      c,
      () => widget.repository.liberarCabine(c.id),
      'Cabine ${c.number.toString().padLeft(2, '0')} liberada',
    );
  }

  Future<void> _setManutencao(Cabin c) async {
    final motivoCtrl = TextEditingController();
    final etaCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Agendar manutenção · Cabine ${c.number.toString().padLeft(2, '0')}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: motivoCtrl,
              decoration: const InputDecoration(
                labelText: 'Motivo *',
                hintText: 'Ex: troca de iluminação',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: etaCtrl,
              decoration: const InputDecoration(
                labelText: 'Previsão de retorno (opcional)',
                hintText: 'Ex: 16:00',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (motivoCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _runAction(
      c,
      () => widget.repository.setManutencao(
        c.id,
        motivo: motivoCtrl.text.trim(),
        eta: etaCtrl.text.trim().isEmpty ? null : etaCtrl.text.trim(),
      ),
      'Cabine em manutenção',
    );
  }

  Future<void> _abrirNovaLiveDialog(List<Cabin> all) async {
    final disponiveis = all.where((c) =>
      (c.status == CabinStatus.busy || c.status == CabinStatus.free) &&
      c.clienteId != null && c.clienteId!.isNotEmpty
    ).toList();
    if (disponiveis.isEmpty) {
      _toast('Nenhuma cabine com cliente vinculado. Reserve uma cabine primeiro.', error: true);
      return;
    }
    final selected = await showDialog<Cabin>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Selecione a cabine'),
        children: disponiveis.map((c) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, c),
          child: Text('Cabine ${c.number.toString().padLeft(2, '0')} · ${c.client ?? "—"}'),
        )).toList(),
      ),
    );
    if (selected != null) await _iniciarLive(selected);
  }

  @override
  Widget build(BuildContext context) {
    return LivelabScaffold(
      currentRoute: AppRoutes.cabines,
      onRefresh: _reload,
      child: FutureBuilder<List<Cabin>>(
        future: _future,
        builder: (c, snap) {
          if (snap.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar: ${snap.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _content(snap.data!);
        },
      ),
    );
  }

  Widget _content(List<Cabin> all) {
    final t = context.llTokens;
    final r = LlResponsive.of(context);
    final filtered = all.applyFilter(_filters);
    final counts = <CabinStatus?, int>{
      null: all.length,
      CabinStatus.live: all.where((c) => c.status == CabinStatus.live).length,
      CabinStatus.busy: all.where((c) => c.status == CabinStatus.busy).length,
      CabinStatus.free: all.where((c) => c.status == CabinStatus.free).length,
      CabinStatus.maint: all.where((c) => c.status == CabinStatus.maint).length,
    };

    return LayoutBuilder(builder: (c, box) {
      final cols = r.isMobile ? 1 : (r.isTablet ? 3 : (box.maxWidth > 1600 ? 4 : 3));
      final showRail = !r.isMobile;

      final grid = GridView.builder(
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 420,
        ),
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final c = filtered[i];
          return CabinCard(
            cabin: c,
            selected: _selected == c.number,
            busy: _busy.contains(c.id),
            onTap: () => setState(() => _selected = c.number),
            onIniciarLive: () => _iniciarLive(c),
            onEncerrarLive: () => _encerrarLive(c),
            onLiberar: () => _liberar(c),
            onSetManutencao: () => _setManutencao(c),
          );
        },
      );

      final rail = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OccupancyPanel(cabins: all),
          const SizedBox(height: LlSpacing.md),
          FutureBuilder<List<UpcomingScheduleEntry>>(
            future: _proximasFuture,
            builder: (ctx, snap) {
              final entries = snap.data ?? const <UpcomingScheduleEntry>[];
              final liveCount = counts[CabinStatus.live] ?? 0;
              final liveNumbers = all
                  .where((c) => c.status == CabinStatus.live)
                  .map((c) => c.number)
                  .toList();
              final list = <ScheduleEntry>[
                if (liveCount > 0)
                  ScheduleEntry(
                    time: TimeOfDay.now().format(context),
                    title: '$liveCount lives em curso',
                    subtitle: 'Cabines ${liveNumbers.join(", ")}',
                    now: true,
                  ),
                ...entries.map((e) => ScheduleEntry(
                      time: e.timeLabel,
                      title: e.title,
                      subtitle: e.subtitle,
                    )),
              ];
              if (list.isEmpty) {
                list.add(const ScheduleEntry(
                  time: '—',
                  title: 'Nenhum agendamento próximo',
                  subtitle: 'Próximas 4 horas livres',
                ));
              }
              return ScheduleTimeline(entries: list);
            },
          ),
          const SizedBox(height: LlSpacing.md),
          QuickActionsPanel(
            actions: [
              QuickAction(
                icon: Icons.bolt,
                title: 'Iniciar nova live',
                subtitle: '${counts[CabinStatus.free]} cabines disponíveis',
                onTap: () => _abrirNovaLiveDialog(all),
              ),
              QuickAction(
                icon: Icons.notifications_active,
                title: 'Aprovar reservas',
                subtitle: 'Ver solicitações pendentes',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.solicitacoes),
              ),
              QuickAction(
                icon: Icons.settings,
                iconColor: t.warning,
                iconBg: t.warningSoft,
                title: 'Agendar manutenção',
                subtitle: '${counts[CabinStatus.maint]} em manutenção',
                onTap: () async {
                  if (all.isEmpty) return;
                  final livre = all.firstWhere(
                    (c) => c.status == CabinStatus.free,
                    orElse: () => all.first,
                  );
                  await _setManutencao(livre);
                },
              ),
            ],
          ),
        ],
      );

      return SingleChildScrollView(
        padding: EdgeInsets.all(r.isMobile ? LlSpacing.lg : LlSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(t, all),
            const SizedBox(height: LlSpacing.lg),
            CabinFilterBar(
              filters: _filters,
              counts: counts,
              onChanged: (f) => setState(() => _filters = f),
            ),
            const SizedBox(height: LlSpacing.lg),
            if (showRail)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: grid),
                  const SizedBox(width: LlSpacing.lg),
                  SizedBox(width: 320, child: rail),
                ],
              )
            else ...[
              grid,
              const SizedBox(height: LlSpacing.lg),
              rail,
            ],
          ],
        ),
      );
    });
  }

  Widget _header(LlTokens t, List<Cabin> all) {
    final live = all.where((c) => c.status == CabinStatus.live).length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Cabines',
                      style: GoogleFonts.instrumentSerif(
                        color: t.textPrimary,
                        fontStyle: FontStyle.italic,
                        fontSize: 36,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -1,
                      ),
                    ),
                    TextSpan(
                      text: ' ao vivo',
                      style: TextStyle(
                        color: t.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${all.length} cabines · $live transmitindo agora · ocupação em tempo real',
                style: TextStyle(color: t.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
        LlButton(
          label: 'Iniciar nova live',
          icon: Icons.bolt,
          onPressed: () => _abrirNovaLiveDialog(all),
        ),
      ],
    );
  }
}
