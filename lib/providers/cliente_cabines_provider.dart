import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cabine.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class ClienteCabinesNotifier extends AsyncNotifier<List<Cabine>> {
  @override
  Future<List<Cabine>> build() async {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) {
      throw Exception('Não autenticado');
    }
    return _fetch();
  }

  Future<List<Cabine>> _fetch() async {
    final resp = await ApiService.get('/cliente/cabines');
    return (resp.data as List)
        .map((e) => Cabine.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final clienteCabinesProvider =
    AsyncNotifierProvider<ClienteCabinesNotifier, List<Cabine>>(
  ClienteCabinesNotifier.new,
);
