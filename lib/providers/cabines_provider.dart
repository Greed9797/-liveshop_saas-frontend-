import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cabine.dart';
import '../services/api_service.dart';

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
    return (resp.data as List)
        .map((e) => Cabine.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _reload() async {
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> iniciarLive({
    required String cabineId,
    required String clienteId,
    required String apresentadorId,
  }) async {
    await ApiService.post('/lives', data: {
      'cabine_id':       cabineId,
      'cliente_id':      clienteId,
      'apresentador_id': apresentadorId,
    });
    await refresh();
  }

  Future<void> encerrarLive(String liveId, double fatGerado) async {
    await ApiService.patch('/lives/$liveId/encerrar', data: {'fat_gerado': fatGerado});
    await refresh();
  }
}

final cabinesProvider =
    AsyncNotifierProvider<CabinesNotifier, List<Cabine>>(CabinesNotifier.new);
