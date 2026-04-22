import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class ClienteLiveDetalhe {
  final String id;
  final String iniciadoEm;
  final String? encerradoEm;
  final int cabineNumero;
  final int duracaoMin;
  final int viewerCount;
  final int commentsCount;
  final int likesCount;
  final int sharesCount;
  final int totalOrders;
  final double fatGerado;
  final String? topProduto;

  const ClienteLiveDetalhe({
    required this.id,
    required this.iniciadoEm,
    this.encerradoEm,
    required this.cabineNumero,
    required this.duracaoMin,
    required this.viewerCount,
    required this.commentsCount,
    required this.likesCount,
    required this.sharesCount,
    required this.totalOrders,
    required this.fatGerado,
    this.topProduto,
  });

  factory ClienteLiveDetalhe.fromJson(Map<String, dynamic> j) => ClienteLiveDetalhe(
        id: j['id'] as String,
        iniciadoEm: j['iniciado_em'] as String,
        encerradoEm: j['encerrado_em'] as String?,
        cabineNumero: (j['cabine_numero'] as num? ?? 0).toInt(),
        duracaoMin: (j['duracao_min'] as num? ?? 0).toInt(),
        viewerCount: (j['viewer_count'] as num? ?? 0).toInt(),
        commentsCount: (j['comments_count'] as num? ?? 0).toInt(),
        likesCount: (j['likes_count'] as num? ?? 0).toInt(),
        sharesCount: (j['shares_count'] as num? ?? 0).toInt(),
        totalOrders: (j['total_orders'] as num? ?? 0).toInt(),
        fatGerado: (j['fat_gerado'] as num? ?? 0).toDouble(),
        topProduto: j['top_produto'] as String?,
      );
}

class ClienteLivesNotifier
    extends FamilyAsyncNotifier<List<ClienteLiveDetalhe>, ({int mes, int ano})> {
  @override
  Future<List<ClienteLiveDetalhe>> build(({int mes, int ano}) arg) async {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) throw Exception('Não autenticado');
    return _fetch(arg.mes, arg.ano);
  }

  Future<List<ClienteLiveDetalhe>> _fetch(int mes, int ano) async {
    final resp = await ApiService.get('/cliente/lives', params: {'mes': mes, 'ano': ano});
    final data = resp.data as Map<String, dynamic>;
    return (data['lives'] as List? ?? [])
        .map((e) => ClienteLiveDetalhe.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(arg.mes, arg.ano));
  }
}

final clienteLivesProvider = AsyncNotifierProvider.family<
    ClienteLivesNotifier,
    List<ClienteLiveDetalhe>,
    ({int mes, int ano})>(ClienteLivesNotifier.new);
