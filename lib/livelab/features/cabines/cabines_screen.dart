import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
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
  CabinFilters _filters = const CabinFilters();
  int? _selected;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.fetchAll();
  }

  void _refresh() {
    setState(() => _future = widget.repository.fetchAll());
  }

  @override
  Widget build(BuildContext context) {
    return LivelabScaffold(
      currentRoute: AppRoutes.cabines,
      onRefresh: _refresh,
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
          mainAxisExtent: 360,
        ),
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final c = filtered[i];
          return CabinCard(
            cabin: c,
            selected: _selected == c.number,
            onTap: () => setState(() => _selected = c.number),
          );
        },
      );

      final rail = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OccupancyPanel(cabins: all),
          const SizedBox(height: LlSpacing.md),
          ScheduleTimeline(entries: _scheduleEntries(all)),
          const SizedBox(height: LlSpacing.md),
          QuickActionsPanel(
            actions: [
              QuickAction(
                icon: Icons.bolt,
                title: 'Iniciar nova live',
                subtitle: '${counts[CabinStatus.free]} cabines disponíveis',
              ),
              const QuickAction(
                icon: Icons.notifications_active,
                title: 'Aprovar reservas',
                subtitle: '4 pendentes',
              ),
              QuickAction(
                icon: Icons.settings,
                iconColor: t.warning,
                iconBg: t.warningSoft,
                title: 'Agendar manutenção',
                subtitle: 'Cabine 10 retorna às 16:00',
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
                      style: TextStyle(
                        color: t.textPrimary,
                        fontFamily: 'serif',
                        fontStyle: FontStyle.italic,
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.6,
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
        const LlButton(label: 'Iniciar nova live', icon: Icons.bolt),
      ],
    );
  }

  List<ScheduleEntry> _scheduleEntries(List<Cabin> all) {
    final live = all.where((c) => c.status == CabinStatus.live).map((c) => c.number).toList();
    return [
      ScheduleEntry(
        time: '14:30',
        title: '${live.length} lives em curso',
        subtitle: 'Cabines ${live.join(", ")}',
        now: true,
      ),
      const ScheduleEntry(time: '15:00', title: 'Beauty Trend · Pré-live', subtitle: 'Cabine 03 · Rafael T. · 2h'),
      const ScheduleEntry(time: '15:30', title: 'Tech Mode', subtitle: 'Cabine 09 · 90min'),
      const ScheduleEntry(time: '16:00', title: 'Cabine 10 retoma', subtitle: 'Manutenção concluída'),
      const ScheduleEntry(time: '16:30', title: 'Loja Fashion Demo', subtitle: 'Cabine 05 · Camila M.'),
      const ScheduleEntry(time: '17:00', title: 'Moda Express', subtitle: 'Cabine 02 · Ana Lima'),
    ];
  }
}
