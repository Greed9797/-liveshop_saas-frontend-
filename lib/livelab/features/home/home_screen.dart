import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_scaffold.dart';
import '../../core/responsive.dart';
import '../../theme/tokens.dart';
import '../../theme/livelab_theme.dart';
import 'home_models.dart';
import 'home_repository.dart';
import 'widgets/hero_strip.dart';
import 'widgets/cta_strip.dart';
import 'widgets/kpi_grid.dart';
import 'widgets/alerts_row.dart';
import 'widgets/upcoming_panel.dart';
import 'widgets/ranking_panel.dart';
import 'widgets/section_label.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});
  final HomeRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.fetch();
  }

  void _refresh() {
    setState(() => _future = widget.repository.fetch());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.home,
      child: FutureBuilder<HomeData>(
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

  Widget _content(HomeData d) {
    final t = context.llTokens;
    final r = LlResponsive.of(context);
    final twoCol = !r.isMobile;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        r.isMobile ? 16 : 28,
        20,
        r.isMobile ? 16 : 28,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _pageHeader(t),
          const SizedBox(height: 18),
          HeroStrip(hero: d.hero),
          const SizedBox(height: 18),
          CtaStrip(items: d.ctas),
          const SizedBox(height: 22),
          SectionLabel(
            label: 'Visão executiva',
            trailing: SectionAllLink(label: 'Ver detalhado', onTap: _refresh),
          ),
          const SizedBox(height: 8),
          KpiGrid(kpis: d.kpis),
          const SizedBox(height: 22),
          const SectionLabel(label: 'Atenção imediata'),
          const SizedBox(height: 8),
          AlertsRow(alerts: d.alerts),
          const SizedBox(height: 18),
          if (twoCol)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 14,
                  child: UpcomingPanel(
                    upcoming: d.upcoming,
                    liveCount: d.upcoming.where((u) => u.status == UpcomingStatus.now).length,
                    totalScheduled: d.upcoming.length,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 10,
                  child: RankingPanel(entries: d.ranking),
                ),
              ],
            )
          else ...[
            UpcomingPanel(
              upcoming: d.upcoming,
              liveCount: d.upcoming.where((u) => u.status == UpcomingStatus.now).length,
              totalScheduled: d.upcoming.length,
            ),
            const SizedBox(height: 14),
            RankingPanel(entries: d.ranking),
          ],
        ],
      ),
    );
  }

  Widget _pageHeader(LlTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Visão',
                style: TextStyle(
                  color: t.primary,
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.6,
                ),
              ),
              TextSpan(
                text: ' da unidade',
                style: TextStyle(
                  color: t.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.9,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pulso operacional, comercial e alertas em tempo real.',
          style: TextStyle(color: t.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}
