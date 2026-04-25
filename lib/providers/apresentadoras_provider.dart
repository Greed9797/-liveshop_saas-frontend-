import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/apresentadora.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class ApresentadorasNotifier extends AsyncNotifier<List<Apresentadora>> {
  @override
  Future<List<Apresentadora>> build() async {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) throw Exception('Não autenticado');
    return _fetch();
  }

  Future<List<Apresentadora>> _fetch() async {
    final resp = await ApiService.get('/apresentadoras');
    return (resp.data as List)
        .map((e) => Apresentadora.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> salvar(Map<String, dynamic> data, {String? id}) async {
    if (id == null) {
      await ApiService.post('/apresentadoras', data: data);
    } else {
      await ApiService.patch('/apresentadoras/$id', data: data);
    }
    state = await AsyncValue.guard(_fetch);
  }
}

final apresentadorasProvider =
    AsyncNotifierProvider<ApresentadorasNotifier, List<Apresentadora>>(
  ApresentadorasNotifier.new,
);
