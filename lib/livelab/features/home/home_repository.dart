import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import 'home_models.dart';

abstract class HomeRepository {
  Future<HomeData> fetch();
}

/// Real implementation — fetches from GET /v1/home/dashboard.
class ApiHomeRepository implements HomeRepository {
  static final _brl = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);

  static String _fmtMoney(num v) => _brl.format(v);

  @override
  Future<HomeData> fetch() async {
    final raw = (await ApiService.get<Map<String, dynamic>>('/home/dashboard')).data!;

    final fat = raw['faturamento'] as Map<String, dynamic>? ?? {};
    final resumo = raw['resumo_mes'] as Map<String, dynamic>? ?? {};
    final gmvMes = (resumo['gmv_lives_mes'] as num? ?? 0).toDouble();
    final taxaConv = (raw['taxa_conversao'] as num? ?? 0).toDouble();
    final livesMes = (resumo['lives_mes'] as num? ?? 0).toInt();

    final cabinesRaw = raw['cabines'] as List<dynamic>? ?? [];
    final liveCabines = cabinesRaw.where((c) => (c['status'] as String? ?? '') == 'ao_vivo').toList();
    final viewersTotal = liveCabines.fold<int>(0, (a, c) => a + ((c['viewer_count'] as num? ?? 0).toInt()));
    final salesTotal = liveCabines.fold<double>(0, (a, c) => a + ((c['gmv_atual'] as num? ?? 0).toDouble()));
    final totalCabines = cabinesRaw.length;

    // Hero
    final hero = HeroSummary(
      liveCount: liveCabines.length,
      totalCabins: totalCabines,
      gmvMes: _fmtMoney(gmvMes),
      gmvDelta: '',
      gmvDeltaPositive: true,
      gmvSpark: const [],
      viewersNow: viewersTotal,
      salesNow: salesTotal,
      peakOfDay: viewersTotal > 0,
    );

    // Lives ao vivo → upcoming list (status = now)
    final upcoming = <UpcomingLive>[];
    for (final c in liveCabines) {
      final dMin = (c['duracao_min'] as num? ?? 0).toInt();
      final h = dMin ~/ 60;
      final m = dMin % 60;
      final dur = h > 0 ? '${h}h ${m.toString().padLeft(2, '0')}min' : '${m}min';
      final timeFmt = DateTime.now();
      final hh = timeFmt.hour.toString().padLeft(2, '0');
      final mm = timeFmt.minute.toString().padLeft(2, '0');
      upcoming.add(UpcomingLive(
        time: '$hh:$mm',
        client: (c['cliente_nome'] as String? ?? '').isEmpty ? '—' : c['cliente_nome'] as String,
        cabin: (c['numero'] as num? ?? 0).toInt(),
        presenter: c['apresentador'] as String? ?? '—',
        duration: dur,
        status: UpcomingStatus.now,
        viewers: (c['viewer_count'] as num? ?? 0).toInt(),
      ));
    }

    // KPIs (executive view)
    final clientesAtivos = (resumo['clientes_ativos'] as num? ?? 0).toInt();
    final pipeline = (resumo['pipeline_aberto'] as num? ?? 0).toDouble();
    final kpis = <HomeKpi>[
      HomeKpi(
        label: 'GMV do mês',
        value: _fmtMoney(gmvMes),
        delta: '',
        deltaPositive: true,
        icon: Icons.attach_money,
        primaryIcon: true,
        footnote: 'vs mês anterior',
      ),
      HomeKpi(
        label: 'Pipeline aberto',
        value: _fmtMoney(pipeline),
        delta: '',
        deltaPositive: true,
        icon: Icons.filter_alt_outlined,
        footnote: 'oportunidades em aberto',
      ),
      HomeKpi(
        label: 'Taxa de conversão',
        value: '${taxaConv.toStringAsFixed(1)}%',
        delta: '',
        deltaPositive: taxaConv >= 0,
        icon: Icons.bar_chart,
        footnote: 'últimos 90 dias',
      ),
      HomeKpi(
        label: 'Clientes ativos',
        value: '$clientesAtivos',
        delta: '',
        deltaPositive: true,
        icon: Icons.people_alt_outlined,
        footnote: 'contratos faturando',
      ),
    ];

    // Alerts
    final alertasRaw = raw['alertas'] as Map<String, dynamic>? ?? {};
    final alerts = <HomeAlert>[];
    final inadimp = (alertasRaw['inadimplentes'] as num? ?? 0).toInt();
    final contratos = (alertasRaw['contratos_aguardando_assinatura'] as num? ?? 0).toInt();
    final conflitos = (alertasRaw['conflitos_agenda'] as num? ?? 0).toInt();
    final leadsParados = (alertasRaw['leads_parados'] as num? ?? 0).toInt();

    if (contratos > 0) {
      alerts.add(HomeAlert(
        title: 'Contratos aguardando assinatura',
        subtitle: 'há mais de 5 dias úteis',
        severity: HomeAlertSeverity.warning,
        count: contratos,
      ));
    }
    if (inadimp > 0) {
      alerts.add(HomeAlert(
        title: 'Boletos vencidos',
        subtitle: 'requer atenção financeira',
        severity: HomeAlertSeverity.danger,
        count: inadimp,
      ));
    }
    alerts.add(HomeAlert(
      title: 'Conflitos de agenda',
      subtitle: conflitos == 0 ? 'tudo limpo nas próximas 48h' : '$conflitos conflito${conflitos > 1 ? 's' : ''}',
      severity: conflitos == 0 ? HomeAlertSeverity.success : HomeAlertSeverity.danger,
      count: conflitos,
    ));
    if (leadsParados > 0) {
      alerts.add(HomeAlert(
        title: 'Leads parados',
        subtitle: 'retome o contato',
        severity: HomeAlertSeverity.warning,
        count: leadsParados,
      ));
    }

    // CTAs
    final freeCabines = cabinesRaw.where((c) => (c['status'] as String? ?? '') == 'livre').length;
    final ctas = <CtaItem>[
      CtaItem(
        icon: Icons.bolt,
        title: 'Iniciar live agora',
        subtitle: freeCabines > 0 ? '$freeCabines cabines disponíveis' : 'sem cabines livres',
        primary: true,
      ),
      CtaItem(
        icon: Icons.notifications_active_outlined,
        title: 'Aprovar solicitações',
        subtitle: 'aguardando você',
        count: contratos,
      ),
      CtaItem(
        icon: Icons.attach_money,
        title: 'Boletos a vencer',
        subtitle: 'próximos 7 dias',
        count: (alertasRaw['boletos_proximos'] as num? ?? 0).toInt(),
      ),
      CtaItem(
        icon: Icons.people_alt_outlined,
        title: 'Leads quentes',
        subtitle: 'fit ≥ 80',
        count: (alertasRaw['leads_quentes'] as num? ?? 0).toInt(),
      ),
    ];

    // touch unused vars to keep linter happy (reserved for future use)
    fat.length;
    livesMes.toString();

    return HomeData(
      hero: hero,
      ctas: ctas,
      kpis: kpis,
      alerts: alerts,
      upcoming: upcoming,
      ranking: const [],
      lives: const [],
    );
  }
}

class MockHomeRepository implements HomeRepository {
  @override
  Future<HomeData> fetch() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _seed;
  }

  static const _sparkData = <double>[42, 48, 52, 49, 58, 65, 72, 68, 80, 84, 78, 92, 88, 95, 102, 98, 110, 124];

  static final HomeData _seed = HomeData(
    hero: const HeroSummary(
      liveCount: 5,
      totalCabins: 11,
      gmvMes: 'R\$ 124.402',
      gmvDelta: '+18,4%',
      gmvDeltaPositive: true,
      gmvSpark: _sparkData,
      nextLiveTime: '15:00',
      nextLiveCabin: 'Cabine 03',
      nextLiveClient: 'Loja Fashion Demo',
      nextLiveStartsIn: 'em 28 minutos',
      viewersNow: 3842,
      salesNow: 18290,
      peakOfDay: true,
    ),
    ctas: [
      CtaItem(
        icon: Icons.bolt,
        title: 'Iniciar live agora',
        subtitle: 'Cabine 07 disponível',
        primary: true,
      ),
      CtaItem(
        icon: Icons.notifications_active_outlined,
        title: 'Aprovar solicitações',
        subtitle: 'aguardando você',
        count: 4,
      ),
      CtaItem(
        icon: Icons.attach_money,
        title: 'Boletos a vencer',
        subtitle: 'próximos 7 dias',
        count: 3,
      ),
      CtaItem(
        icon: Icons.people_alt_outlined,
        title: 'Leads quentes',
        subtitle: 'fit ≥ 80',
        count: 7,
      ),
    ],
    kpis: [
      HomeKpi(
        label: 'GMV do mês',
        value: 'R\$ 124.402',
        delta: '+18,4%',
        deltaPositive: true,
        icon: Icons.attach_money,
        primaryIcon: true,
        footnote: 'vs mês anterior',
      ),
      HomeKpi(
        label: 'Pipeline aberto',
        value: 'R\$ 48.620',
        delta: '',
        deltaPositive: true,
        icon: Icons.filter_alt_outlined,
        footnote: '12 oportunidades · 7 quentes',
      ),
      HomeKpi(
        label: 'Taxa de conversão',
        value: '62,4%',
        delta: '+4,1pp',
        deltaPositive: true,
        icon: Icons.bar_chart,
        footnote: 'últimos 90 dias',
      ),
      HomeKpi(
        label: 'Clientes ativos',
        value: '12',
        delta: '',
        deltaPositive: true,
        icon: Icons.people_alt_outlined,
        footnote: 'contratos faturando',
      ),
    ],
    alerts: [
      HomeAlert(
        title: 'Contratos aguardando assinatura',
        subtitle: 'há mais de 5 dias úteis',
        severity: HomeAlertSeverity.warning,
        count: 12,
      ),
      HomeAlert(
        title: 'Boletos vencidos',
        subtitle: 'R\$ 75 em atraso · 7 dias',
        severity: HomeAlertSeverity.danger,
        count: 1,
      ),
      HomeAlert(
        title: 'Conflitos de agenda',
        subtitle: 'tudo limpo nas próximas 48h',
        severity: HomeAlertSeverity.success,
        count: 0,
      ),
    ],
    upcoming: [
      UpcomingLive(
        time: '14:32',
        client: 'Loja Fashion Demo',
        cabin: 1,
        presenter: 'Camila M.',
        viewers: 3842,
        status: UpcomingStatus.now,
      ),
      UpcomingLive(
        time: '15:00',
        client: 'Beauty Trend',
        cabin: 3,
        presenter: 'Rafael T.',
        duration: '2h',
        status: UpcomingStatus.warming,
      ),
      UpcomingLive(
        time: '17:00',
        client: 'Moda Express',
        cabin: 2,
        presenter: 'Ana Lima',
        duration: '90min',
        status: UpcomingStatus.scheduled,
      ),
      UpcomingLive(
        time: '19:30',
        client: 'Urban Co · prime time',
        cabin: 7,
        presenter: 'Camila M.',
        duration: '2h',
        status: UpcomingStatus.scheduled,
      ),
    ],
    ranking: [
      RankingEntry(position: 1, name: 'Camila Moura', lives: 4, orders: 1842, gmv: 38420),
      RankingEntry(position: 2, name: 'Rafael Torres', lives: 3, orders: 1108, gmv: 24180),
      RankingEntry(position: 3, name: 'Ana Lima', lives: 2, orders: 892, gmv: 18640),
      RankingEntry(position: 4, name: 'Bia Santos', lives: 2, orders: 612, gmv: 12380),
      RankingEntry(position: 5, name: 'Júlia Reis', lives: 1, orders: 408, gmv: 7920),
    ],
  );
}
