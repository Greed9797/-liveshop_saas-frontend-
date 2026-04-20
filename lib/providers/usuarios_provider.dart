import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';

class UsuariosNotifier extends AsyncNotifier<List<Usuario>> {
  @override
  Future<List<Usuario>> build() async {
    return _fetch();
  }

  Future<List<Usuario>> _fetch() async {
    final resp = await ApiService.get('/usuarios');
    return (resp.data as List)
        .map((j) => Usuario.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<Map<String, dynamic>> convidar(Map<String, dynamic> payload) async {
    final resp = await ApiService.post('/usuarios/convidar', data: payload);
    await refresh();
    return resp.data as Map<String, dynamic>;
  }

  Future<void> remover(String id) async {
    await ApiService.delete('/usuarios/$id');
    state = AsyncData(state.valueOrNull?.where((u) => u.id != id).toList() ?? []);
  }
}

final usuariosProvider =
    AsyncNotifierProvider<UsuariosNotifier, List<Usuario>>(UsuariosNotifier.new);
