import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class ContratosNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<String> criar({
    required String clienteId,
    required double valorFixo,
    required double comissaoPct,
  }) async {
    final resp = await ApiService.post('/contratos', data: {
      'cliente_id':   clienteId,
      'valor_fixo':   valorFixo,
      'comissao_pct': comissaoPct,
    });
    return (resp.data as Map<String, dynamic>)['id'] as String;
  }

  Future<Map<String, dynamic>> assinar(String id) async {
    final resp = await ApiService.post('/contratos/$id/assinar');
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> analisar(String id) async {
    final resp = await ApiService.post('/contratos/$id/analisar');
    return resp.data as Map<String, dynamic>;
  }

  Future<void> assumirRisco(String id) async {
    await ApiService.patch('/contratos/$id/assumir-risco');
  }

  Future<void> cancelar(String id) async {
    await ApiService.patch('/contratos/$id/cancelar');
  }
}

final contratosProvider =
    NotifierProvider<ContratosNotifier, void>(ContratosNotifier.new);
