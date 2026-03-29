import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

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
        cabineNumero: j['cabine_numero'] as int,
        viewerCount: j['viewer_count'] ?? 0,
        gmvAtual: (j['gmv_atual'] ?? 0).toDouble(),
        comissaoProjetada: (j['comissao_projetada'] ?? 0).toDouble(),
        duracaoMin: j['duracao_min'] ?? 0,
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

class ClienteDashboard {
  final double faturamentoMes;
  final int crescimentoPct;
  final int volumeVendas;
  final double lucroEstimado;

  final LiveAtiva? liveAtiva;
  final List<ProdutoVendido> maisVendidos;
  final RankingDia? rankingDia;

  const ClienteDashboard({
    required this.faturamentoMes,
    required this.crescimentoPct,
    required this.volumeVendas,
    required this.lucroEstimado,
    this.liveAtiva,
    required this.maisVendidos,
    this.rankingDia,
  });

  factory ClienteDashboard.fromJson(Map<String, dynamic> j) => ClienteDashboard(
        faturamentoMes: (j['faturamento_mes'] ?? 0).toDouble(),
        crescimentoPct: (j['crescimento_pct'] ?? 0).toInt(),
        volumeVendas: j['volume_vendas'] ?? 0,
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
      );
}

class ClienteDashboardNotifier extends AsyncNotifier<ClienteDashboard> {
  Timer? _timer;

  @override
  Future<ClienteDashboard> build() async {
    final data = await _fetch();

    // Polling de 30 segundos (conforme Mindmap)
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final newData = await _fetch();
        if (state.hasValue) {
          state = AsyncValue.data(newData); // Atualiza silenciosamente
        }
      } catch (e) {
        debugPrint('Erro no polling do cliente: $e');
      }
    });

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
  }
}

final clienteDashboardProvider =
    AsyncNotifierProvider<ClienteDashboardNotifier, ClienteDashboard>(
        ClienteDashboardNotifier.new);
