import 'package:flutter/material.dart';
import '../../../design_system/app_screen_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../../core/responsive.dart';
import '../../theme/tokens.dart';
import '../../theme/livelab_theme.dart';
import 'home_models.dart';
import 'home_repository.dart';
import 'widgets/pulse_strip.dart';
import 'widgets/live_now_panel.dart';
import 'widgets/upcoming_panel.dart';
import 'widgets/ranking_panel.dart';
import 'widgets/alerts_panel.dart';

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

  @override
  Widget build(BuildContext context) {
    return AppScreenScaffold(
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

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LiveNowPanel(lives: d.lives),
        const SizedBox(height: LlSpacing.md),
        UpcomingPanel(upcoming: d.upcoming),
      ],
    );

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AlertsPanel(alerts: d.alerts),
        const SizedBox(height: LlSpacing.md),
        RankingPanel(entries: d.ranking),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(r.isMobile ? LlSpacing.lg : LlSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(t),
          const SizedBox(height: LlSpacing.lg),
          PulseStrip(kpis: d.kpis),
          const SizedBox(height: LlSpacing.lg),
          if (twoCol)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: left),
                const SizedBox(width: LlSpacing.lg),
                Expanded(flex: 2, child: right),
              ],
            )
          else ...[
            left,
            const SizedBox(height: LlSpacing.lg),
            right,
          ],
        ],
      ),
    );
  }

  Widget _header(LlTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Visão',
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
                text: ' da unidade',
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
          'Pulso operacional, comercial e alertas em tempo real.',
          style: TextStyle(color: t.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}
