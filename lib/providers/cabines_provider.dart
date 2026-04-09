import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cabine.dart';
import '../models/fila_ativacao_item.dart';
import '../services/api_service.dart';
import 'dashboard_provider.dart';

class CabinesNotifier extends AsyncNotifier<List<Cabine>> {
  Timer? _timer;

  @override
  Future<List<Cabine>> build() {
    // Polling a cada 15 segundos
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _reload());
    ref.onDispose(() => _timer?.cancel());
    return _fetch();
  }

  Future<List<Cabine>> _fetch() async {
    final resp = await ApiService.get('/cabines');
    final raw = resp.data;
    if (raw is! List) return [];
    return raw
        .map((e) => Cabine.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _reload() async {
    state = await AsyncValue.guard(_fetch);
  }

  void _invalidateOperationalProviders() {
    ref.invalidate(dashboardProvider);
    ref.invalidate(filaAtivacaoProvider);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
    _invalidateOperationalProviders();
  }

  Future<void> reservarCabine({
    required String cabineId,
    required String contratoId,
  }) async {
    await ApiService.patch('/cabines/$cabineId/reservar', data: {
      'contrato_id': contratoId,
    });
    await refresh();
  }

  Future<void> liberarCabine(String cabineId) async {
    await ApiService.patch('/cabines/$cabineId/liberar');
    await refresh();
  }

  Future<void> iniciarLive({
    required String cabineId,
  }) async {
    await ApiService.post('/lives', data: {
      'cabine_id': cabineId,
    });
    await refresh();
  }

  Future<void> encerrarLive(String liveId, double fatGerado) async {
    await ApiService.patch('/lives/$liveId/encerrar',
        data: {'fat_gerado': fatGerado});
    await refresh();
  }
}

final cabinesProvider =
    AsyncNotifierProvider<CabinesNotifier, List<Cabine>>(CabinesNotifier.new);

final filaAtivacaoProvider =
    FutureProvider<List<FilaAtivacaoItem>>((ref) async {
  final response = await ApiService.get('/cabines/fila-ativacao');
  final data = response.data;
  if (data is! List) return [];
  return data
      .map((item) => FilaAtivacaoItem.fromJson(item as Map<String, dynamic>))
      .toList();
});
