import 'package:flutter/material.dart';
import '../../../design_system/app_screen_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../../core/responsive.dart';
import '../../theme/tokens.dart';
import 'cabines_models.dart';
import 'cabines_repository.dart';
import 'widgets/cabin_card.dart';
import 'widgets/cabin_filter_bar.dart';
import 'widgets/kpi_strip.dart';
import 'widgets/cabin_focus_panel.dart';
import 'widgets/activation_queue_panel.dart';

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

  @override
  Widget build(BuildContext context) {
    return AppScreenScaffold(
      currentRoute: AppRoutes.cabines,
      eyebrow: 'Operação ao vivo',
      title: 'Painel de Cabines',
      titleSerif: true,
      subtitle: 'Visão operacional em tempo real da sua unidade — do raio-X de cada cabine ao GMV consolidado.',
      actions: [
        IconButton(
          onPressed: () => setState(() => _future = widget.repository.fetchAll()),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          tooltip: 'Atualizar',
        ),
      ],
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
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return _content(snap.data!);
        },
      ),
    );
  }

  Widget _content(List<Cabin> all) {
    final r = LlResponsive.of(context);
    final filtered = all.applyFilter(_filters);
    final counts = <CabinStatus?, int>{
      null: all.length,
      CabinStatus.live: all.where((c) => c.status == CabinStatus.live).length,
      CabinStatus.busy: all.where((c) => c.status == CabinStatus.busy).length,
      CabinStatus.free: all.where((c) => c.status == CabinStatus.free).length,
      CabinStatus.maint: all.where((c) => c.status == CabinStatus.maint).length,
    };

    final selectedCabin = _selected != null
        ? all.where((c) => c.number == _selected).firstOrNull
        : all.firstOrNull;

    return LayoutBuilder(builder: (_, box) {
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
          mainAxisExtent: 220,
        ),
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final cabin = filtered[i];
          return CabinCard(
            cabin: cabin,
            selected: _selected == cabin.number,
            onTap: () => setState(() => _selected = cabin.number),
          );
        },
      );

      final rail = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CabinFocusPanel(cabin: selectedCabin),
          const SizedBox(height: LlSpacing.md),
          ActivationQueuePanel(entries: widget.repository.queue),
        ],
      );

      return SingleChildScrollView(
        padding: EdgeInsets.all(r.isMobile ? LlSpacing.lg : LlSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KpiStrip(cabins: all),
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
}
