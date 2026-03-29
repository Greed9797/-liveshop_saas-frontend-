import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';

// --- Models simplificados para a tela de detalhe ---

class CabineLiveAtual {
  final int viewerCount;
  final double gmvAtual;
  final int totalOrders;
  final int duracaoMinutos;
  final String clienteNome;
  final String apresentadorNome;
  final DateTime iniciadoEm;
  final Map<String, dynamic>? topProduto;

  CabineLiveAtual({
    required this.viewerCount,
    required this.gmvAtual,
    required this.totalOrders,
    required this.duracaoMinutos,
    required this.clienteNome,
    required this.apresentadorNome,
    required this.iniciadoEm,
    this.topProduto,
  });

  factory CabineLiveAtual.fromJson(Map<String, dynamic> json) {
    return CabineLiveAtual(
      viewerCount: json['viewer_count'] ?? 0,
      gmvAtual: (json['gmv_atual'] ?? 0).toDouble(),
      totalOrders: json['total_orders'] ?? 0,
      duracaoMinutos: json['duracao_minutos'] ?? 0,
      clienteNome: json['cliente_nome'] ?? '',
      apresentadorNome: json['apresentador_nome'] ?? '',
      iniciadoEm: DateTime.parse(json['iniciado_em']),
      topProduto: json['top_produto'],
    );
  }
}

class CabineHistorico {
  final List<dynamic> topClientes;
  final List<dynamic> melhoresHorarios;
  final Map<String, dynamic> desempenhoMensal;
  final Map<String, dynamic> totais;

  CabineHistorico({
    required this.topClientes,
    required this.melhoresHorarios,
    required this.desempenhoMensal,
    required this.totais,
  });

  factory CabineHistorico.fromJson(Map<String, dynamic> json) {
    return CabineHistorico(
      topClientes: json['top_clientes'] ?? [],
      melhoresHorarios: json['melhores_horarios'] ?? [],
      desempenhoMensal: json['desempenho_mensal'] ?? {},
      totais: json['totais'] ?? {},
    );
  }
}

class CabineDetailState {
  final CabineLiveAtual? liveAtual;
  final CabineHistorico? historico;

  CabineDetailState({this.liveAtual, this.historico});

  CabineDetailState copyWith({
    CabineLiveAtual? liveAtual,
    CabineHistorico? historico,
  }) {
    return CabineDetailState(
      liveAtual: liveAtual ?? this.liveAtual,
      historico: historico ?? this.historico,
    );
  }
}

// --- Provider com Polling ---

class CabineDetailNotifier
    extends AutoDisposeAsyncNotifierFamily<CabineDetailState, String> {
  Timer? _timer;

  // Parâmetro arg é o cabine_id que o Family injeta
  @override
  Future<CabineDetailState> build(String arg) async {
    // 1. Ao construir, cancela timer prévio (se existir na recriação)
    _timer?.cancel();

    // 2. Busca o Histórico e a Live Atual (se houver)
    final historico = await _fetchHistorico(arg);
    final liveAtual = await _fetchLiveAtual(arg);

    // 3. Se a cabine estiver ao vivo, inicia o polling a cada 15 segundos
    if (liveAtual != null) {
      _startPolling(arg);
    }

    // Limpeza ao destruir o provider
    ref.onDispose(() {
      _timer?.cancel();
    });

    return CabineDetailState(liveAtual: liveAtual, historico: historico);
  }

  Future<CabineHistorico> _fetchHistorico(String cabineId) async {
    final response =
        await ApiService.get('/cabines/$cabineId/historico?dias=90');
    return CabineHistorico.fromJson(response.data);
  }

  Future<CabineLiveAtual?> _fetchLiveAtual(String cabineId) async {
    try {
      final response = await ApiService.get('/cabines/$cabineId/live-atual');
      return CabineLiveAtual.fromJson(response.data);
    } catch (e) {
      // Retorna nulo se der erro ou se não estiver ao vivo (API retorna 400 ou 404 nesses casos)
      return null;
    }
  }

  void _startPolling(String cabineId) {
    _timer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        final liveAtual = await _fetchLiveAtual(cabineId);

        // Se a live caiu ou encerrou, cancela o timer
        if (liveAtual == null) {
          _timer?.cancel();
        }

        // Atualiza apenas a live_atual silenciosamente (sem loading de recarga)
        if (state.hasValue) {
          state = AsyncValue.data(state.value!.copyWith(liveAtual: liveAtual));
        }
      } catch (e) {
        print('Erro no polling do detalhe da cabine $cabineId: $e');
      }
    });
  }

  // Usado para forçar um refresh manual
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

// Injeção do Provider
final cabineDetailProvider = AsyncNotifierProvider.autoDispose
    .family<CabineDetailNotifier, CabineDetailState, String>(
  CabineDetailNotifier.new,
);
