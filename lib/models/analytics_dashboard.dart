class AnalyticsFiltros {
  final String? clienteId;
  final String mesAno;

  const AnalyticsFiltros({this.clienteId, required this.mesAno});

  AnalyticsFiltros copyWith({Object? clienteId = _sentinel, String? mesAno}) {
    return AnalyticsFiltros(
      clienteId: clienteId == _sentinel ? this.clienteId : clienteId as String?,
      mesAno: mesAno ?? this.mesAno,
    );
  }
}

const Object _sentinel = Object();

// ─────────────────────────────────────────
// Sub-models
// ─────────────────────────────────────────

class KpiResumo {
  final double faturamentoTotal;
  final int totalVendas;
  final double ticketMedio;

  const KpiResumo({
    required this.faturamentoTotal,
    required this.totalVendas,
    required this.ticketMedio,
  });

  factory KpiResumo.fromJson(Map<String, dynamic> j) => KpiResumo(
        faturamentoTotal: (j['faturamento_total'] as num? ?? 0).toDouble(),
        totalVendas: (j['total_vendas'] as num? ?? 0).toInt(),
        ticketMedio: (j['ticket_medio'] as num? ?? 0).toDouble(),
      );
}

class FaturamentoMensal {
  final String mes;
  final double gmv;

  const FaturamentoMensal({required this.mes, required this.gmv});

  factory FaturamentoMensal.fromJson(Map<String, dynamic> j) => FaturamentoMensal(
        mes: j['mes'] as String,
        gmv: (j['gmv'] as num? ?? 0).toDouble(),
      );
}

class VendasMensal {
  final String mes;
  final int totalVendas;

  const VendasMensal({required this.mes, required this.totalVendas});

  factory VendasMensal.fromJson(Map<String, dynamic> j) => VendasMensal(
        mes: j['mes'] as String,
        totalVendas: (j['total_vendas'] as num? ?? 0).toInt(),
      );
}

class HorasLiveDia {
  final String dia; // "YYYY-MM-DD"
  final double horas;

  const HorasLiveDia({required this.dia, required this.horas});

  factory HorasLiveDia.fromJson(Map<String, dynamic> j) => HorasLiveDia(
        dia: j['dia'] as String,
        horas: (j['horas'] as num? ?? 0).toDouble(),
      );
}

class RankingApresentador {
  final String apresentadorId;
  final String apresentadorNome;
  final int totalLives;
  final double gmvTotal;

  const RankingApresentador({
    required this.apresentadorId,
    required this.apresentadorNome,
    required this.totalLives,
    required this.gmvTotal,
  });

  factory RankingApresentador.fromJson(Map<String, dynamic> j) => RankingApresentador(
        apresentadorId: j['apresentador_id'] as String,
        apresentadorNome: j['apresentador_nome'] as String,
        totalLives: (j['total_lives'] as num? ?? 0).toInt(),
        gmvTotal: (j['gmv_total'] as num? ?? 0).toDouble(),
      );
}

// ─────────────────────────────────────────
// Aggregator
// ─────────────────────────────────────────

class AnalyticsDashboardData {
  final KpiResumo kpis;
  final List<FaturamentoMensal> faturamentoMensal;
  final List<VendasMensal> vendasMensal;
  final List<HorasLiveDia> horasLivePorDia;
  final List<RankingApresentador> rankingApresentadores;

  const AnalyticsDashboardData({
    required this.kpis,
    required this.faturamentoMensal,
    required this.vendasMensal,
    required this.horasLivePorDia,
    required this.rankingApresentadores,
  });

  factory AnalyticsDashboardData.fromJson(Map<String, dynamic> j) =>
      AnalyticsDashboardData(
        kpis: KpiResumo.fromJson(
          Map<String, dynamic>.from(j['kpis'] as Map? ?? const {}),
        ),
        faturamentoMensal: (j['faturamento_mensal'] as List? ?? const [])
            .map((e) => FaturamentoMensal.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        vendasMensal: (j['vendas_mensal'] as List? ?? const [])
            .map((e) => VendasMensal.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        horasLivePorDia: (j['horas_live_por_dia'] as List? ?? const [])
            .map((e) => HorasLiveDia.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        rankingApresentadores: (j['ranking_apresentadores'] as List? ?? const [])
            .map((e) => RankingApresentador.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
