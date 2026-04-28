import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import 'home_models.dart';

abstract class HomeRepository {
  Future<HomeData> fetch();
}

/// Real implementation — fetches from GET /v1/home/dashboard.
class ApiHomeRepository implements HomeRepository {
  static final _brl = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);
  static final _compact = NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 1);

  static String _fmt(num v) => v >= 10000 ? _compact.format(v) : _brl.format(v);
  static String _fmtInt(num v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);

  @override
  Future<HomeData> fetch() async {
    final raw = (await ApiService.get<Map<String, dynamic>>('/home/dashboard')).data!;

    // --- KPIs (faturamento + resumo_mes) ---
    final fat = raw['faturamento'] as Map<String, dynamic>? ?? {};
    final resumo = raw['resumo_mes'] as Map<String, dynamic>? ?? {};
    final gmvMes = (resumo['gmv_lives_mes'] as num? ?? 0).toDouble();
    final taxaConv = (raw['taxa_conversao'] as num? ?? 0).toDouble();
    final mediaView = (resumo['media_viewers'] as num? ?? 0).toDouble();

    final kpis = <HomeKpi>[
      HomeKpi(
        label: 'GMV do mês',
        value: _fmt(gmvMes),
        delta: '',
        deltaPositive: true,
        spark: const [],
      ),
      HomeKpi(
        label: 'Lives no mês',
        value: '${resumo['lives_mes'] ?? 0}',
        delta: '',
        deltaPositive: true,
        spark: const [],
      ),
      HomeKpi(
        label: 'Espectadores médios',
        value: _fmtInt(mediaView),
        delta: '',
        deltaPositive: true,
        spark: const [],
      ),
      HomeKpi(
        label: 'Conversão',
        value: '${taxaConv.toStringAsFixed(1)}%',
        delta: '',
        deltaPositive: taxaConv >= 0,
        spark: const [],
      ),
    ];

    // --- Lives ao vivo (cabines com status "ao_vivo") ---
    final cabinesRaw = raw['cabines'] as List<dynamic>? ?? [];
    final lives = cabinesRaw
        .where((c) => (c['status'] as String? ?? '') == 'ao_vivo')
        .map((c) {
          final dMin = (c['duracao_min'] as num? ?? 0).toInt();
          final h = dMin ~/ 60;
          final m = dMin % 60;
          final dur = h > 0 ? '${h}h ${m.toString().padLeft(2, '0')}min' : '${m}min';
          return LiveNow(
            cabin: (c['numero'] as num? ?? 0).toInt(),
            client: c['cliente_nome'] as String? ?? '',
            presenter: c['apresentador'] as String? ?? '',
            viewers: (c['viewer_count'] as num? ?? 0).toInt(),
            gmv: (c['gmv_atual'] as num? ?? 0).toDouble(),
            duration: dur,
          );
        })
        .toList();

    // --- Alertas ---
    final alertasRaw = raw['alertas'] as Map<String, dynamic>? ?? {};
    final alerts = <HomeAlert>[];
    final inadimp = (alertasRaw['inadimplentes'] as num? ?? 0).toInt();
    final contratos = (alertasRaw['contratos_aguardando_assinatura'] as num? ?? 0).toInt();
    final agendamentos = (alertasRaw['agendamentos_semana'] as num? ?? 0).toInt();
    final leadsParados = (alertasRaw['leads_parados'] as num? ?? 0).toInt();
    final conflitos = (alertasRaw['conflitos_agenda'] as num? ?? 0).toInt();

    if (inadimp > 0) {
      alerts.add(HomeAlert(
        title: '$inadimp cliente${inadimp > 1 ? 's' : ''} inadimplente${inadimp > 1 ? 's' : ''}',
        subtitle: 'Requer atenção financeira',
        severity: HomeAlertSeverity.danger,
      ));
    }
    if (contratos > 0) {
      alerts.add(HomeAlert(
        title: '$contratos contrato${contratos > 1 ? 's' : ''} aguardando assinatura',
        subtitle: 'Pendente de aprovação',
        severity: HomeAlertSeverity.warning,
      ));
    }
    if (agendamentos > 0) {
      alerts.add(HomeAlert(
        title: '$agendamentos agendamento${agendamentos > 1 ? 's' : ''} esta semana',
        subtitle: 'Verifique a agenda',
        severity: HomeAlertSeverity.info,
      ));
    }
    if (leadsParados > 0) {
      alerts.add(HomeAlert(
        title: '$leadsParados lead${leadsParados > 1 ? 's' : ''} parado${leadsParados > 1 ? 's' : ''}',
        subtitle: 'Retome o contato',
        severity: HomeAlertSeverity.warning,
      ));
    }
    if (conflitos > 0) {
      alerts.add(HomeAlert(
        title: '$conflitos conflito${conflitos > 1 ? 's' : ''} na agenda',
        subtitle: 'Verifique e resolva',
        severity: HomeAlertSeverity.danger,
      ));
    }

    return HomeData(
      kpis: kpis,
      lives: lives,
      upcoming: const [], // endpoint doesn't provide upcoming — future work
      ranking: const [],  // endpoint doesn't provide ranking — future work
      alerts: alerts,
    );
  }
}

class MockHomeRepository implements HomeRepository {
  @override
  Future<HomeData> fetch() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _seed;
  }

  static const _seed = HomeData(
    kpis: [
      HomeKpi(label: 'GMV de hoje', value: 'R\$ 142.840', delta: '+18% vs ontem', deltaPositive: true,
          spark: [12, 18, 14, 22, 26, 31, 28, 34, 42, 38, 46, 52]),
      HomeKpi(label: 'Pedidos', value: '1.842', delta: '+12% vs ontem', deltaPositive: true,
          spark: [8, 12, 10, 18, 22, 24, 28, 32, 30, 36, 40, 44]),
      HomeKpi(label: 'Espectadores únicos', value: '38.4k', delta: '+24% vs ontem', deltaPositive: true,
          spark: [10, 14, 18, 16, 22, 28, 34, 30, 38, 44, 48, 52]),
      HomeKpi(label: 'Conversão', value: '4.8%', delta: '-0.3% vs ontem', deltaPositive: false,
          spark: [42, 44, 40, 46, 48, 44, 42, 40, 38, 42, 44, 40]),
    ],
    lives: [
      LiveNow(cabin: 1, client: 'Loja Fashion Demo', presenter: 'Camila Moura', viewers: 3842, gmv: 18290, duration: '1h 24min'),
      LiveNow(cabin: 2, client: 'Beauty Trend', presenter: 'Rafael Torres', viewers: 1208, gmv: 9420, duration: '42min'),
      LiveNow(cabin: 4, client: 'Urban Co', presenter: 'Bia Santos', viewers: 612, gmv: 4180, duration: '18min'),
      LiveNow(cabin: 6, client: 'Glow Beauty', presenter: 'Júlia Reis', viewers: 408, gmv: 2890, duration: '12min'),
      LiveNow(cabin: 8, client: 'Fit Style', presenter: 'Marina P.', viewers: 892, gmv: 6240, duration: '1h 02min'),
    ],
    upcoming: [
      UpcomingLive(time: '15:00', client: 'Beauty Trend', cabin: 3, presenter: 'Rafael T.', duration: '2h'),
      UpcomingLive(time: '17:00', client: 'Moda Express', cabin: 2, presenter: 'Ana Lima', duration: '90min'),
      UpcomingLive(time: '19:30', client: 'Urban Co · prime time', cabin: 7, presenter: 'Camila M.', duration: '2h'),
    ],
    ranking: [
      RankingEntry(position: 1, name: 'Camila Moura', lives: 4, orders: 1842, gmv: 38420),
      RankingEntry(position: 2, name: 'Rafael Torres', lives: 3, orders: 1108, gmv: 24180),
      RankingEntry(position: 3, name: 'Ana Lima', lives: 2, orders: 892, gmv: 18640),
      RankingEntry(position: 4, name: 'Bia Santos', lives: 2, orders: 612, gmv: 12380),
      RankingEntry(position: 5, name: 'Júlia Reis', lives: 1, orders: 408, gmv: 7920),
    ],
    alerts: [
      HomeAlert(title: 'Cabine 10 em manutenção', subtitle: 'Retorno previsto às 16:00', severity: HomeAlertSeverity.warning),
      HomeAlert(title: '4 reservas pendentes', subtitle: 'Aguardando aprovação', severity: HomeAlertSeverity.info),
      HomeAlert(title: 'Pico de tráfego em Cabine 01', subtitle: '3.8k espectadores · +120% no último 5min', severity: HomeAlertSeverity.info),
    ],
  );
}
