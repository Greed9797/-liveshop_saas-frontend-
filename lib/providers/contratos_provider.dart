import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contrato.dart';
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

  // Legado — mantido para compatibilidade
  Future<Map<String, dynamic>> assinar(String id) async {
    final resp = await ApiService.post('/contratos/$id/assinar');
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> analisar(String id) async {
    final resp = await ApiService.post('/contratos/$id/analisar');
    return resp.data as Map<String, dynamic>;
  }

  /// Novo fluxo: assina + calcula score + auto-aprova se score >= 60
  Future<Map<String, dynamic>> assinarDigital({
    required String id,
    required String signatureBase64,
  }) async {
    final resp = await ApiService.post('/contratos/$id/assinar-digital', data: {
      'signatureImageBase64': signatureBase64,
      'acceptedTerms': true,
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<void> assumirRisco(String id) async {
    await ApiService.patch('/contratos/$id/assumir-risco');
  }

  Future<void> cancelar(String id) async {
    await ApiService.patch('/contratos/$id/cancelar');
  }

  // Backoffice — Análise de Crédito
  Future<void> aprovar(String id) async {
    await ApiService.patch('/contratos/$id/aprovar');
  }

  Future<void> arquivar(String id, {String? motivo}) async {
    await ApiService.patch('/contratos/$id/arquivar', data: {'motivo': motivo});
  }

  Future<void> sinalizarRisco(String id) async {
    await ApiService.patch('/contratos/$id/sinalizar-risco');
  }
}

final contratosProvider =
    NotifierProvider<ContratosNotifier, void>(ContratosNotifier.new);

// Provider para a tela de Análise de Crédito
final analiseCreditoProvider = FutureProvider<List<Contrato>>((ref) async {
  final resp = await ApiService.get('/analise-credito');
  return (resp.data as List)
      .map((e) => Contrato.fromJson(e as Map<String, dynamic>))
      .toList();
});
