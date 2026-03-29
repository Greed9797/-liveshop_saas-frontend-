import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class FinanceiroResumo {
  final double fatBruto;
  final double fatLiquido;
  final double totalCustos;
  final String periodo;

  const FinanceiroResumo({
    required this.fatBruto,
    required this.fatLiquido,
    required this.totalCustos,
    required this.periodo,
  });

  factory FinanceiroResumo.fromJson(Map<String, dynamic> j) => FinanceiroResumo(
    fatBruto:    (j['fat_bruto'] as num).toDouble(),
    fatLiquido:  (j['fat_liquido'] as num).toDouble(),
    totalCustos: (j['total_custos'] as num).toDouble(),
    periodo:     j['periodo'] as String,
  );
}

class FinanceiroNotifier extends AsyncNotifier<FinanceiroResumo> {
  @override
  Future<FinanceiroResumo> build() => _fetch();

  Future<FinanceiroResumo> _fetch({int? mes, int? ano}) async {
    final params = <String, dynamic>{};
    if (mes != null) params['mes'] = mes;
    if (ano != null) params['ano'] = ano;
    final resp = await ApiService.get('/financeiro/resumo', params: params.isEmpty ? null : params);
    return FinanceiroResumo.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> carregarPeriodo(int mes, int ano) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(mes: mes, ano: ano));
  }

  Future<void> adicionarCusto(Map<String, dynamic> data) async {
    await ApiService.post('/financeiro/custos', data: data);
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> deletarCusto(String id) async {
    await ApiService.delete('/financeiro/custos/$id');
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final financeiroProvider =
    AsyncNotifierProvider<FinanceiroNotifier, FinanceiroResumo>(FinanceiroNotifier.new);
