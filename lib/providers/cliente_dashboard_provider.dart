import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
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

class ClienteDashboard {
  final double faturamentoMes;
  final int crescimentoPct;
  final int volumeVendas;
  final double lucroEstimado;

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
    required this.lucroEstimado,
    this.liveAtiva,
    required this.maisVendidos,
    this.rankingDia,
    this.proximaReserva,
    this.benchmarkNicho,
    this.benchmarkGeral,
  });

  factory ClienteDashboard.fromJson(Map<String, dynamic> j) => ClienteDashboard(
        faturamentoMes: (j['faturamento_mes'] ?? 0).toDouble(),
        crescimentoPct: (j['crescimento_pct'] ?? 0).toInt(),
        volumeVendas: int.tryParse(j['volume_vendas']?.toString() ?? '') ?? 0,
        lucroEstimado: (j['lucro_estimado'] ?? 0).toDouble(),
        liveAtiva: j['live_ativa'] != null
            ? LiveAtiva.fromJson(j['live_ativa'])
            : null,
        maisVendidos: (j['mais_vendidos'] as List?)
                ?.map((e) => ProdutoVendido.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        rankingDia: j['ranking_dia'] != null
            ? RankingDia.fromJson(j['ranking_dia'])
            : null,
        proximaReserva: j['proxima_reserva'] != null
            ? ProximaReserva.fromJson(j['proxima_reserva'])
            : null,
        benchmarkNicho: j['benchmark_nicho'] != null
            ? BenchmarkResumo.fromJson(j['benchmark_nicho'])
            : null,
        benchmarkGeral: j['benchmark_geral'] != null
            ? BenchmarkResumo.fromJson(j['benchmark_geral'])
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
