class CabineStatus {
  final int numero;
  final String status;
  final String? liveAtualId;
  final int viewerCount;
  final double gmvAtual;
  final String? clienteNome;
  final String? apresentador;
  final int duracaoMin;

  const CabineStatus({
    required this.numero,
    required this.status,
    this.liveAtualId,
    this.viewerCount = 0,
    this.gmvAtual = 0.0,
    this.clienteNome,
    this.apresentador,
    this.duracaoMin = 0,
  });

  factory CabineStatus.fromJson(Map<String, dynamic> j) => CabineStatus(
        numero: j['numero'] as int,
        status: j['status'] as String,
        liveAtualId: j['live_atual_id'] as String?,
        viewerCount: j['viewer_count'] ?? 0,
        gmvAtual: (j['gmv_atual'] ?? 0).toDouble(),
        clienteNome: j['cliente_nome'] as String?,
        apresentador: j['apresentador'] as String?,
        duracaoMin: j['duracao_min'] ?? 0,
      );

  Map<String, dynamic> toMockMap() => {
        'numero': numero,
        'status': status,
        'apresentador': apresentador,
        'cliente': clienteNome,
        'viewer_count': viewerCount,
        'gmv_atual': gmvAtual,
        'duracao_min': duracaoMin,
      };
}

class RankingEntry {
  final String nome;
  final double gmv;
  final int lives;

  const RankingEntry({
    required this.nome,
    required this.gmv,
    required this.lives,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> j) => RankingEntry(
        nome: j['nome'] as String,
        gmv: (j['gmv'] ?? 0).toDouble(),
        lives: j['lives'] ?? 0,
      );
}

class DashboardData {
  final double fatTotal;
  final double fatBruto;
  final double fatLiquido;

  // Array de Cabines com status real-time
  final List<CabineStatus> cabines;

  // Resumo do mês
  final int clientesAtivos;
  final int novosClientes;
  final int churnMes;
  final int livesMes;
  final double gmvLivesMes;
  final int mediaViewers;

  // Alertas
  final int contratosAnalise;
  final int boletosVencidos;
  final int leadsDisponiveis;

  // Ranking do Dia
  final List<RankingEntry> rankingDia;

  const DashboardData({
    required this.fatTotal,
    required this.fatBruto,
    required this.fatLiquido,
    required this.cabines,
    required this.clientesAtivos,
    required this.novosClientes,
    required this.churnMes,
    required this.livesMes,
    required this.gmvLivesMes,
    required this.mediaViewers,
    required this.contratosAnalise,
    required this.boletosVencidos,
    required this.leadsDisponiveis,
    required this.rankingDia,
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        fatTotal: (j['fat_total'] ?? 0).toDouble(),
        fatBruto: (j['fat_bruto'] ?? 0).toDouble(),
        fatLiquido: (j['fat_liquido'] ?? 0).toDouble(),
        clientesAtivos: j['clientes_ativos'] ?? 0,
        novosClientes: j['novos_clientes'] ?? 0,
        churnMes: j['churn_mes'] ?? 0,
        livesMes: j['lives_mes'] ?? 0,
        gmvLivesMes: (j['gmv_lives_mes'] ?? 0).toDouble(),
        mediaViewers: j['media_viewers'] ?? 0,
        contratosAnalise: j['contratos_analise'] ?? 0,
        boletosVencidos: j['boletos_vencidos'] ?? 0,
        leadsDisponiveis: j['leads_disponiveis'] ?? 0,
        cabines: (j['cabines'] as List?)
                ?.map((e) => CabineStatus.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        rankingDia: (j['ranking_dia'] as List?)
                ?.map((e) => RankingEntry.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
