import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// ──────────────────────────────────────────────────────────────
// Models
// ──────────────────────────────────────────────────────────────

class ClienteCabineBasic {
  final String id;
  final int numero;
  final String status;

  const ClienteCabineBasic({
    required this.id,
    required this.numero,
    required this.status,
  });

  factory ClienteCabineBasic.fromJson(Map<String, dynamic> j) =>
      ClienteCabineBasic(
        id:     j['id'] as String,
        numero: j['numero'] as int,
        status: j['status'] as String,
      );
}

class ClienteLiveAtual {
  final String liveId;
  final int viewerCount;
  final double gmvAtual;
  final int totalOrders;
  final int duracaoMinutos;
  final String? apresentadorNome;
  final DateTime iniciadoEm;
  final int likesCount;
  final int commentsCount;
  final String? topProduto;

  const ClienteLiveAtual({
    required this.liveId,
    required this.viewerCount,
    required this.gmvAtual,
    required this.totalOrders,
    required this.duracaoMinutos,
    this.apresentadorNome,
    required this.iniciadoEm,
    required this.likesCount,
    required this.commentsCount,
    this.topProduto,
  });

  factory ClienteLiveAtual.fromJson(Map<String, dynamic> j) => ClienteLiveAtual(
        liveId:           j['live_id'] as String,
        viewerCount:      (j['viewer_count'] as num? ?? 0).toInt(),
        gmvAtual:         (j['gmv_atual'] as num? ?? 0).toDouble(),
        totalOrders:      (j['total_orders'] as num? ?? 0).toInt(),
        duracaoMinutos:   (j['duracao_minutos'] as num? ?? 0).toInt(),
        apresentadorNome: j['apresentador_nome'] as String?,
        iniciadoEm:       DateTime.parse(j['iniciado_em'] as String),
        likesCount:       (j['likes_count'] as num? ?? 0).toInt(),
        commentsCount:    (j['comments_count'] as num? ?? 0).toInt(),
        topProduto:       j['top_produto'] as String?,
      );
}

class ClienteHistoricoLive {
  final String id;
  final String iniciadoEm;
  final String? encerradoEm;
  final String status;
  final double fatGerado;
  final double comissaoCalculada;
  final int duracaoMin;

  const ClienteHistoricoLive({
    required this.id,
    required this.iniciadoEm,
    this.encerradoEm,
    required this.status,
    required this.fatGerado,
    required this.comissaoCalculada,
    required this.duracaoMin,
  });

  factory ClienteHistoricoLive.fromJson(Map<String, dynamic> j) =>
      ClienteHistoricoLive(
        id:                 j['id'] as String,
        iniciadoEm:         j['iniciado_em'] as String,
        encerradoEm:        j['encerrado_em'] as String?,
        status:             j['status'] as String,
        fatGerado:          (j['fat_gerado'] as num? ?? 0).toDouble(),
        comissaoCalculada:  (j['comissao_calculada'] as num? ?? 0).toDouble(),
        duracaoMin:         (j['duracao_min'] as num? ?? 0).toInt(),
      );
}

class ClienteCabineDetailState {
  final ClienteCabineBasic cabine;
  final ClienteLiveAtual? liveAtual;
  final List<ClienteHistoricoLive> historicoLives;

  const ClienteCabineDetailState({
    required this.cabine,
    required this.liveAtual,
    required this.historicoLives,
  });

  factory ClienteCabineDetailState.fromJson(Map<String, dynamic> j) =>
      ClienteCabineDetailState(
        cabine: ClienteCabineBasic.fromJson(
            j['cabine'] as Map<String, dynamic>),
        liveAtual: j['live_atual'] != null
            ? ClienteLiveAtual.fromJson(
                j['live_atual'] as Map<String, dynamic>)
            : null,
        historicoLives: (j['historico_lives'] as List? ?? [])
            .map((e) => ClienteHistoricoLive.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );

  ClienteCabineDetailState copyWith({
    ClienteLiveAtual? liveAtual,
    bool clearLive = false,
  }) =>
      ClienteCabineDetailState(
        cabine:        cabine,
        liveAtual:     clearLive ? null : (liveAtual ?? this.liveAtual),
        historicoLives: historicoLives,
      );
}

// ──────────────────────────────────────────────────────────────
// Notifier
// ──────────────────────────────────────────────────────────────

class ClienteCabineDetailNotifier
    extends FamilyAsyncNotifier<ClienteCabineDetailState, String> {
  @override
  Future<ClienteCabineDetailState> build(String cabineId) async {
    final resp = await ApiService.get('/cliente/cabines/$cabineId');
    return ClienteCabineDetailState.fromJson(
        resp.data as Map<String, dynamic>);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }

  /// Atualiza apenas os dados da live ativa sem mostrar loading na tela.
  Future<void> refreshLiveOnly() async {
    if (!state.hasValue) return;
    try {
      final resp = await ApiService.get('/cliente/cabines/$arg');
      final fresh =
          ClienteCabineDetailState.fromJson(resp.data as Map<String, dynamic>);
      state = AsyncValue.data(
        state.value!.copyWith(liveAtual: fresh.liveAtual, clearLive: fresh.liveAtual == null),
      );
    } catch (_) {
      // Mantém último estado estável se o refresh parcial falhar.
    }
  }
}

final clienteCabineDetailProvider = AsyncNotifierProviderFamily<
    ClienteCabineDetailNotifier, ClienteCabineDetailState, String>(
  ClienteCabineDetailNotifier.new,
);
