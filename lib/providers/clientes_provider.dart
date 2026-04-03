import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cliente.dart';
import '../services/api_service.dart';

class ClientesNotifier extends AsyncNotifier<List<Cliente>> {
  @override
  Future<List<Cliente>> build() => _fetch();

  Future<List<Cliente>> _fetch() async {
    final resp = await ApiService.get('/clientes');
    return (resp.data as List)
        .map((e) => Cliente.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<Cliente> criar(Map<String, dynamic> data) async {
    final resp = await ApiService.post('/clientes', data: data);
    final cliente = Cliente.fromJson(resp.data as Map<String, dynamic>);
    state = AsyncData([cliente, ...state.valueOrNull ?? []]);
    return cliente;
  }

  Future<Map<String, dynamic>> buscarCep(String cep) async {
    final resp = await ApiService.get('/cep/$cep');
    return resp.data as Map<String, dynamic>;
  }
}

final clientesProvider =
    AsyncNotifierProvider<ClientesNotifier, List<Cliente>>(ClientesNotifier.new);
