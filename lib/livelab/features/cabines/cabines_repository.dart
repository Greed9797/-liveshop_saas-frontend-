// Replace bodies with Supabase / FastAPI calls — keep return types.

import '../../../services/api_service.dart';
import 'cabines_models.dart';

abstract class CabinesRepository {
  Future<List<Cabin>> fetchAll();
  Stream<List<Cabin>>? watchAll() => null;
  List<QueueEntry> get queue => const [];
}

/// Real implementation — fetches from GET /v1/cabines.
class ApiCabinesRepository extends CabinesRepository {
  @override
  Future<List<Cabin>> fetchAll() async {
    final raw = (await ApiService.get<List<dynamic>>('/cabines')).data!;
    return raw.map((c) => _mapCabin(c as Map<String, dynamic>)).toList();
  }

  static CabinStatus _mapStatus(String? s) {
    switch (s) {
      case 'ao_vivo':
        return CabinStatus.live;
      case 'reservada':
      case 'ocupada':
        return CabinStatus.busy;
      case 'manutencao':
        return CabinStatus.maint;
      default:
        return CabinStatus.free;
    }
  }

  static Cabin _mapCabin(Map<String, dynamic> c) {
    return Cabin(
      number: (c['numero'] as num? ?? 0).toInt(),
      status: _mapStatus(c['status'] as String?),
      client: c['cliente_nome'] as String?,
      presenter: c['apresentador_nome'] as String?,
      contract: c['contrato'] as String?,
      views: (c['viewer_count'] as num? ?? 0).toInt(),
      gmv: (c['gmv_atual'] as num? ?? 0).toDouble(),
      orders: (c['total_orders'] as num? ?? 0).toInt(),
    );
  }
}

class MockCabinesRepository extends CabinesRepository {
  @override
  Future<List<Cabin>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _seed;
  }

  @override
  List<QueueEntry> get queue => _queue;

  static const _queue = <QueueEntry>[
    QueueEntry(name: 'Bamboo Decor', contract: '#5512-B1', location: 'São Paulo · SP', fee: 1800),
    QueueEntry(name: 'Outlet Fashion', contract: '#5513-C2', location: 'Rio de Janeiro · RJ', fee: 2200),
    QueueEntry(name: 'Tech Acessórios', contract: '#5514-D3', location: 'Belo Horizonte · MG', fee: 1500),
  ];

  static const _seed = <Cabin>[
    Cabin(
      number: 1,
      status: CabinStatus.live,
      client: 'Loja Fashion Demo',
      presenter: 'Camila Moura',
      contract: '#4821-A3',
      views: 3842,
      gmv: 18290,
      orders: 142,
      duration: '1h 24min',
      agenda: [
        CabinScheduleEntry(time: '16:30', name: 'Loja Fashion Demo', presenter: 'Camila M.', duration: '2h'),
        CabinScheduleEntry(time: '19:00', name: 'Urban Co', presenter: 'Bia S.', duration: '90min'),
      ],
      history: [
        CabinHistoryEntry(time: 'Hoje 13:08', name: 'Loja Fashion Demo', gmv: 18290, views: 3842),
        CabinHistoryEntry(time: 'Ontem 19:30', name: 'Beauty Trend', gmv: 14820, views: 2104),
        CabinHistoryEntry(time: 'Ontem 14:00', name: 'Loja Fashion Demo', gmv: 22140, views: 4128),
      ],
    ),
    Cabin(
      number: 2,
      status: CabinStatus.live,
      client: 'Beauty Trend',
      presenter: 'Rafael Torres',
      contract: '#4822-B1',
      views: 1208,
      gmv: 9420,
      orders: 78,
      duration: '42min',
      agenda: [CabinScheduleEntry(time: '17:00', name: 'Moda Express', presenter: 'Ana L.', duration: '90min')],
      history: [
        CabinHistoryEntry(time: 'Hoje 13:50', name: 'Beauty Trend', gmv: 9420, views: 1208),
        CabinHistoryEntry(time: 'Ontem 17:00', name: 'Glow Beauty', gmv: 6840, views: 1402),
      ],
    ),
    Cabin(
      number: 3,
      status: CabinStatus.busy,
      client: 'Moda Express',
      presenter: 'Ana Lima',
      contract: '#4823-C2',
      startsIn: '15min',
      agenda: [
        CabinScheduleEntry(time: '15:00', name: 'Beauty Trend', presenter: 'Rafael T.', duration: '2h'),
        CabinScheduleEntry(time: '18:00', name: 'Tech Mode', presenter: 'Setup', duration: '90min'),
      ],
      history: [
        CabinHistoryEntry(time: 'Ontem 16:00', name: 'Moda Express', gmv: 11280, views: 1842),
        CabinHistoryEntry(time: 'Anteontem', name: 'Urban Co', gmv: 8920, views: 1604),
      ],
    ),
    Cabin(
      number: 4,
      status: CabinStatus.live,
      client: 'Urban Co',
      presenter: 'Bia Santos',
      contract: '#4824-D1',
      views: 612,
      gmv: 4180,
      orders: 32,
      duration: '18min',
      agenda: [CabinScheduleEntry(time: '17:30', name: 'Fit Style', presenter: 'Marina P.', duration: '2h')],
      history: [
        CabinHistoryEntry(time: 'Hoje 14:14', name: 'Urban Co', gmv: 4180, views: 612),
        CabinHistoryEntry(time: 'Ontem 20:00', name: 'Glow Beauty', gmv: 12420, views: 2310),
      ],
    ),
    Cabin(
      number: 5,
      status: CabinStatus.free,
      agenda: [
        CabinScheduleEntry(time: '16:30', name: 'Loja Fashion Demo', presenter: 'Camila M.', duration: '2h'),
        CabinScheduleEntry(time: '19:00', name: 'Beauty Trend', presenter: 'Rafael T.', duration: '2h'),
      ],
      history: [CabinHistoryEntry(time: 'Ontem 18:00', name: 'Tech Mode', gmv: 5240, views: 924)],
    ),
    Cabin(
      number: 6,
      status: CabinStatus.live,
      client: 'Glow Beauty',
      presenter: 'Júlia Reis',
      contract: '#4826-E2',
      views: 408,
      gmv: 2890,
      orders: 21,
      duration: '12min',
      agenda: [CabinScheduleEntry(time: '16:00', name: 'Loja Fashion Demo', presenter: 'Camila M.', duration: '90min')],
      history: [
        CabinHistoryEntry(time: 'Hoje 14:20', name: 'Glow Beauty', gmv: 2890, views: 408),
        CabinHistoryEntry(time: 'Ontem 19:30', name: 'Fit Style', gmv: 9180, views: 1622),
      ],
    ),
    Cabin(
      number: 7,
      status: CabinStatus.free,
      agenda: [CabinScheduleEntry(time: '17:00', name: 'Disponível para reserva')],
      history: [CabinHistoryEntry(time: 'Ontem 15:00', name: 'Moda Express', gmv: 7820, views: 1208)],
    ),
    Cabin(
      number: 8,
      status: CabinStatus.live,
      client: 'Fit Style',
      presenter: 'Marina P.',
      contract: '#4828-F1',
      views: 892,
      gmv: 6240,
      orders: 51,
      duration: '1h 02min',
      agenda: [CabinScheduleEntry(time: '18:30', name: 'Tech Mode', presenter: 'Setup', duration: '2h')],
      history: [
        CabinHistoryEntry(time: 'Hoje 13:30', name: 'Fit Style', gmv: 6240, views: 892),
        CabinHistoryEntry(time: 'Ontem 17:30', name: 'Loja Fashion Demo', gmv: 14620, views: 2840),
      ],
    ),
    Cabin(
      number: 9,
      status: CabinStatus.busy,
      client: 'Tech Mode',
      presenter: 'Marcos R.',
      contract: '#4829-G3',
      startsIn: '30min',
      agenda: [
        CabinScheduleEntry(time: '15:30', name: 'Tech Mode', presenter: 'Marcos R.', duration: '90min'),
        CabinScheduleEntry(time: '18:00', name: 'Beauty Trend', presenter: 'Rafael T.', duration: '2h'),
      ],
      history: [CabinHistoryEntry(time: 'Ontem 14:00', name: 'Tech Mode', gmv: 6420, views: 1108)],
    ),
    Cabin(
      number: 10,
      status: CabinStatus.maint,
      maintenanceReason: 'Troca de luz frontal',
      maintenanceEta: '16:00',
      agenda: [
        CabinScheduleEntry(time: '16:30', name: 'Disponível após manutenção'),
        CabinScheduleEntry(time: '18:00', name: 'Glow Beauty', presenter: 'Júlia R.', duration: '2h'),
      ],
      history: [CabinHistoryEntry(time: 'Anteontem', name: 'Urban Co', gmv: 9420, views: 1842)],
    ),
    Cabin(
      number: 11,
      status: CabinStatus.free,
      agenda: [],
      history: [
        CabinHistoryEntry(time: 'Ontem 16:00', name: 'Beauty Trend', gmv: 4280, views: 720),
        CabinHistoryEntry(time: 'Anteontem', name: 'Moda Express', gmv: 3920, views: 612),
      ],
    ),
  ];
}
