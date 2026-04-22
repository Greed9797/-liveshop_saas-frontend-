import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/franqueado_analytics_resumo.dart';
import '../models/analytics_dashboard.dart';
import 'auth_provider.dart';

const _clienteLivePolling = Duration(seconds: 30);
const _clienteIdlePolling = Duration(minutes: 10);

class LiveAtiva {
  final int cabineNumero;
  final int viewerCount;
  final double gmvAtual;
  final double comissaoProjetada;
  final int duracaoMin;
  final String iniciouEm;

  const LiveAtiva({
    required this.cabineNumero,
    required this.viewerCount,
    required this.gmvAtual,
    required this.comissaoProjetada,
    required this.duracaoMin,
    required this.iniciouEm,
  });

  factory LiveAtiva.fromJson(Map<String, dynamic> j) => LiveAtiva(
        cabineNumero: int.tryParse(j['cabine_numero']?.toString() ?? '') ?? 0,
        viewerCount: int.tryParse(j['viewer_count']?.toString() ?? '') ?? 0,
        gmvAtual: double.tryParse(j['gmv_atual']?.toString() ?? '') ?? 0.0,
        comissaoProjetada: double.tryParse(j['comissao_projetada']?.toString() ?? '') ?? 0.0,
        duracaoMin: int.tryParse(j['duracao_min']?.toString() ?? '') ?? 0,
        iniciouEm: j['iniciou_em'] as String,
      );
}

class ProdutoVendido {
  final String produto;
  final int qty;
  final double valor;

  const ProdutoVendido({
    required this.produto,
    required this.qty,
    required this.valor,
  });

  factory ProdutoVendido.fromJson(Map<String, dynamic> j) => ProdutoVendido(
        produto: j['produto'] as String,
        qty: j['qty'] as int,
        valor: (j['valor'] ?? 0).toDouble(),
      );
}

class RankingDia {
  final int posicao;
  final double gmvDia;
  final int totalParticipantes;

  const RankingDia({
    required this.posicao,
    required this.gmvDia,
    required this.totalParticipantes,
  });

  factory RankingDia.fromJson(Map<String, dynamic> j) => RankingDia(
        posicao: j['posicao'] as int,
        gmvDia: (j['gmv_dia'] ?? 0).toDouble(),
        totalParticipantes: j['total_participantes'] as int,
      );
}

class ProximaReserva {
  final String cabineId;
  final int cabineNumero;
  final String status;
  final String contratoId;
  final DateTime? ativadoEm;
  final DateTime? assinadoEm;

  const ProximaReserva({
    required this.cabineId,
    required this.cabineNumero,
    required this.status,
    required this.contratoId,
    this.ativadoEm,
    this.assinadoEm,
  });

  factory ProximaReserva.fromJson(Map<String, dynamic> j) => ProximaReserva(
        cabineId: j['cabine_id'] as String,
        cabineNumero: j['cabine_numero'] as int,
        status: j['status'] as String,
        contratoId: j['contrato_id'] as String,
        ativadoEm: j['ativado_em'] is String
            ? DateTime.tryParse(j['ativado_em'])
            : null,
        assinadoEm: j['assinado_em'] is String
            ? DateTime.tryParse(j['assinado_em'])
            : null,
      );
}

class BenchmarkResumo {
  final String? nicho;
  final double meuGmv;
  final double mediaGmv;
  final double percentualDaMedia;
  final double? percentil;
  final int amostra;
  final bool acimaDaMedia;

  const BenchmarkResumo({
    this.nicho,
    required this.meuGmv,
    required this.mediaGmv,
    required this.percentualDaMedia,
    this.percentil,
    required this.amostra,
    required this.acimaDaMedia,
  });

  factory BenchmarkResumo.fromJson(Map<String, dynamic> j) => BenchmarkResumo(
        nicho: j['nicho'] as String?,
        meuGmv: (j['meu_gmv'] ?? 0).toDouble(),
        mediaGmv: (j['media_gmv'] ?? 0).toDouble(),
        percentualDaMedia: (j['percentual_da_media'] ?? 0).toDouble(),
        percentil:
            j['percentil'] == null ? null : (j['percentil'] as num).toDouble(),
        amostra: ((j['amostra'] ?? 0) as num).toInt(),
        acimaDaMedia: (j['acima_da_media'] ?? false) as bool,
      );
}

class PacoteInfo {
  final double valor;
  final double horasIncluidas;
  final double valorFixoContrato;

  const PacoteInfo({
    required this.valor,
    required this.horasIncluidas,
    required this.valorFixoContrato,
  });

  factory PacoteInfo.fromJson(Map<String, dynamic> j) => PacoteInfo(
        valor: (j['valor'] as num? ?? 0).toDouble(),
        horasIncluidas: (j['horas_incluidas'] as num? ?? 0).toDouble(),
        valorFixoContrato: (j['valor_fixo_contrato'] as num? ?? 0).toDouble(),
      );
}

class TopDiaSemana {
  final int diaSemana; // 0=Dom .. 6=Sab
  final double gmvTotal;
  final int totalLives;

  const TopDiaSemana({
    required this.diaSemana,
    required this.gmvTotal,
    required this.totalLives,
  });

  factory TopDiaSemana.fromJson(Map<String, dynamic> j) => TopDiaSemana(
        diaSemana: (j['dia_semana'] as num? ?? 0).toInt(),
        gmvTotal: (j['gmv_total'] as num? ?? 0).toDouble(),
        totalLives: (j['total_lives'] as num? ?? 0).toInt(),
      );
}

class ClienteDashboard {
  final double faturamentoMes;
  final int crescimentoPct;
  final int volumeVendas;
  final double horasMes;
  final double? roasMes;
  final PacoteInfo? pacote;
  final List<FaturamentoMensal> faturamentoPorMes;
  final List<HeatmapHorarioAnalytics> topHorarios;
  final List<TopDiaSemana> topDiasSemana;

  final LiveAtiva? liveAtiva;
  final List<ProdutoVendido> maisVendidos;
  final RankingDia? rankingDia;
  final ProximaReserva? proximaReserva;
  final BenchmarkResumo? benchmarkNicho;
  final BenchmarkResumo? benchmarkGeral;

  const ClienteDashboard({
    required this.faturamentoMes,
    required this.crescimentoPct,
    required this.volumeVendas,
    required this.horasMes,
    this.roasMes,
    this.pacote,
    required this.faturamentoPorMes,
    required this.topHorarios,
    required this.topDiasSemana,
    this.liveAtiva,
    required this.maisVendidos,
    this.rankingDia,
    this.proximaReserva,
    this.benchmarkNicho,
    this.benchmarkGeral,
  });

  factory ClienteDashboard.fromJson(Map<String, dynamic> j) => ClienteDashboard(
        faturamentoMes: (j['faturamento_mes'] as num? ?? 0).toDouble(),
        crescimentoPct: (j['crescimento_pct'] as num? ?? 0).toInt(),
        volumeVendas: (j['volume_vendas'] as num? ?? 0).toInt(),
        horasMes: (j['horas_mes'] as num? ?? 0).toDouble(),
        roasMes: j['roas_mes'] == null ? null : (j['roas_mes'] as num).toDouble(),
        pacote: j['pacote'] != null ? PacoteInfo.fromJson(j['pacote']) : null,
        faturamentoPorMes: (j['faturamento_por_mes'] as List? ?? [])
            .map((e) => FaturamentoMensal.fromJson(e as Map<String, dynamic>))
            .toList(),
        topHorarios: (j['top_horarios'] as List? ?? [])
            .map((e) => HeatmapHorarioAnalytics.fromJson(e as Map<String, dynamic>))
            .toList(),
        topDiasSemana: (j['top_dias_semana'] as List? ?? [])
            .map((e) => TopDiaSemana.fromJson(e as Map<String, dynamic>))
            .toList(),
        liveAtiva: j['live_ativa'] != null
            ? LiveAtiva.fromJson(j['live_ativa'] as Map<String, dynamic>)
            : null,
        maisVendidos: (j['mais_vendidos'] as List? ?? [])
            .map((e) => ProdutoVendido.fromJson(e as Map<String, dynamic>))
            .toList(),
        rankingDia: j['ranking_dia'] != null
            ? RankingDia.fromJson(j['ranking_dia'] as Map<String, dynamic>)
            : null,
        proximaReserva: j['proxima_reserva'] != null
            ? ProximaReserva.fromJson(j['proxima_reserva'] as Map<String, dynamic>)
            : null,
        benchmarkNicho: j['benchmark_nicho'] != null
            ? BenchmarkResumo.fromJson(j['benchmark_nicho'] as Map<String, dynamic>)
            : null,
        benchmarkGeral: j['benchmark_geral'] != null
            ? BenchmarkResumo.fromJson(j['benchmark_geral'] as Map<String, dynamic>)
            : null,
      );
}

class ClienteDashboardNotifier extends AsyncNotifier<ClienteDashboard> {
  Timer? _timer;

  void _configurePolling(ClienteDashboard dashboard) {
    _timer?.cancel();
    final interval =
        dashboard.liveAtiva != null ? _clienteLivePolling : _clienteIdlePolling;

    _timer = Timer.periodic(interval, (_) async {
      try {
        final newData = await _fetch();
        if (state.hasValue) {
          state = AsyncValue.data(newData);
        }
        _configurePolling(newData);
      } catch (e) {
        debugPrint('Erro no polling do cliente: $e');
      }
    });
  }

  @override
  Future<ClienteDashboard> build() async {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) {
      _timer?.cancel();
      _timer = null;
      throw Exception('Não autenticado');
    }
    final data = await _fetch();

    _configurePolling(data);

    ref.onDispose(() => _timer?.cancel());
    return data;
  }

  Future<ClienteDashboard> _fetch() async {
    final resp = await ApiService.get('/cliente/dashboard');
    return ClienteDashboard.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
    final current = state.valueOrNull;
    if (current != null) {
      _configurePolling(current);
    }
  }
}

final clienteDashboardProvider =
    AsyncNotifierProvider<ClienteDashboardNotifier, ClienteDashboard>(
        ClienteDashboardNotifier.new);
