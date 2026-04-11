import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';

// --- Models simplificados para a tela de detalhe ---

class CabineLiveAtual {
  final String liveId;
  final int viewerCount;
  final double gmvAtual;
  final int totalOrders;
  final int duracaoMinutos;
  final String clienteNome;
  final String apresentadorNome;
  final DateTime iniciadoEm;
  final Map<String, dynamic>? topProduto;

  CabineLiveAtual({
    required this.liveId,
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
      liveId: json['live_id'] as String,
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
    bool clearLive = false,
  }) {
    return CabineDetailState(
      liveAtual: clearLive ? null : (liveAtual ?? this.liveAtual),
      historico: historico ?? this.historico,
    );
  }
}

class CabineDetailNotifier
    extends FamilyAsyncNotifier<CabineDetailState, String> {
  @override
  Future<CabineDetailState> build(String arg) async {
    final historico = await _fetchHistorico(arg);
    final liveAtual = await _fetchLiveAtual(arg);

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
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }

  Future<void> refreshLiveOnly() async {
    if (!state.hasValue) return;

    try {
      final liveAtual = await _fetchLiveAtual(arg);
      state = AsyncValue.data(
        state.value!.copyWith(
          liveAtual: liveAtual,
          clearLive: liveAtual == null,
        ),
      );
    } catch (_) {
      // Mantemos o último estado estável se o refresh parcial falhar.
    }
  }
}

// Injeção do Provider
final cabineDetailProvider = AsyncNotifierProviderFamily<CabineDetailNotifier,
    CabineDetailState, String>(
  CabineDetailNotifier.new,
);
