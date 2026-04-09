import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// ─── MODELS ──────────────────────────────────────────────────────────────────

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
        fatBruto: double.tryParse(j['fat_bruto']?.toString() ?? '') ?? 0.0,
        fatLiquido: double.tryParse(j['fat_liquido']?.toString() ?? '') ?? 0.0,
        totalCustos: double.tryParse(j['total_custos']?.toString() ?? '') ?? 0.0,
        periodo: j['periodo'] as String,
      );
}

class CustoCadastrado {
  final String id;
  final String descricao;
  final double valor;
  final String tipo;
  final String competencia;

  const CustoCadastrado({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.competencia,
  });

  factory CustoCadastrado.fromJson(Map<String, dynamic> j) => CustoCadastrado(
        id: j['id'] as String,
        descricao: j['descricao'] as String,
        valor: double.tryParse(j['valor']?.toString() ?? '') ?? 0.0,
        tipo: j['tipo'] as String,
        competencia: j['competencia'] as String,
      );
}

class FluxoCaixaItem {
  final DateTime dia;
  final double valor;
  const FluxoCaixaItem({required this.dia, required this.valor});
}

class FluxoCaixa {
  final List<FluxoCaixaItem> entradas;
  final List<FluxoCaixaItem> saidas;
  double get totalEntradas => entradas.fold(0, (s, e) => s + e.valor);
  double get totalSaidas => saidas.fold(0, (s, e) => s + e.valor);
  double get saldo => totalEntradas - totalSaidas;

  const FluxoCaixa({required this.entradas, required this.saidas});

  factory FluxoCaixa.fromJson(Map<String, dynamic> j) => FluxoCaixa(
        entradas: ((j['entradas'] as List?) ?? [])
            .map((e) => FluxoCaixaItem(
                  dia: DateTime.parse(e['dia'] as String),
                  valor: double.tryParse(e['valor']?.toString() ?? '') ?? 0.0,
                ))
            .toList(),
        saidas: ((j['saidas'] as List?) ?? [])
            .map((e) => FluxoCaixaItem(
                  dia: DateTime.parse(e['dia'] as String),
                  valor: double.tryParse(e['valor']?.toString() ?? '') ?? 0.0,
                ))
            .toList(),
      );
}

class ClienteFaturamento {
  final String nome;
  final String? nicho;
  final double total;
  const ClienteFaturamento(
      {required this.nome, this.nicho, required this.total});

  factory ClienteFaturamento.fromJson(Map<String, dynamic> j) =>
      ClienteFaturamento(
        nome: j['nome'] as String,
        nicho: j['nicho'] as String?,
        total: double.tryParse(j['total']?.toString() ?? '') ?? 0.0,
      );
}

// ─── RESUMO PROVIDER ─────────────────────────────────────────────────────────

class FinanceiroNotifier extends AsyncNotifier<FinanceiroResumo> {
  @override
  Future<FinanceiroResumo> build() => _fetch();

  Future<FinanceiroResumo> _fetch({int? mes, int? ano}) async {
    final params = <String, dynamic>{};
    if (mes != null) params['mes'] = mes;
    if (ano != null) params['ano'] = ano;
    final resp = await ApiService.get('/financeiro/resumo',
        params: params.isEmpty ? null : params);
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
    AsyncNotifierProvider<FinanceiroNotifier, FinanceiroResumo>(
        FinanceiroNotifier.new);

// ─── CUSTOS LIST PROVIDER ─────────────────────────────────────────────────────

class CustosNotifier extends AsyncNotifier<List<CustoCadastrado>> {
  @override
  Future<List<CustoCadastrado>> build() => _fetch();

  Future<List<CustoCadastrado>> _fetch() async {
    final mes =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    final resp =
        await ApiService.get('/financeiro/custos', params: {'mes': mes});
    return (resp.data as List)
        .map((e) => CustoCadastrado.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> adicionar(Map<String, dynamic> data) async {
    await ApiService.post('/financeiro/custos', data: data);
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> deletar(String id) async {
    await ApiService.delete('/financeiro/custos/$id');
    if (state.hasValue) {
      state = AsyncData(state.value!.where((c) => c.id != id).toList());
    }
  }
}

final custosProvider =
    AsyncNotifierProvider<CustosNotifier, List<CustoCadastrado>>(
        CustosNotifier.new);

// ─── FLUXO DE CAIXA PROVIDER ──────────────────────────────────────────────────

class FluxoCaixaNotifier extends AsyncNotifier<FluxoCaixa> {
  @override
  Future<FluxoCaixa> build() => _fetch();

  Future<FluxoCaixa> _fetch() async {
    final now = DateTime.now();
    final resp = await ApiService.get('/financeiro/fluxo-caixa',
        params: {'mes': now.month, 'ano': now.year});
    return FluxoCaixa.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final fluxoCaixaProvider =
    AsyncNotifierProvider<FluxoCaixaNotifier, FluxoCaixa>(
        FluxoCaixaNotifier.new);

// ─── FATURAMENTO POR CLIENTE PROVIDER ────────────────────────────────────────

class FaturamentoPorClienteNotifier
    extends AsyncNotifier<List<ClienteFaturamento>> {
  @override
  Future<List<ClienteFaturamento>> build() => _fetch();

  Future<List<ClienteFaturamento>> _fetch() async {
    final mes =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    final resp = await ApiService.get('/financeiro/faturamento',
        params: {'periodo': mes});
    final data = resp.data as Map<String, dynamic>;
    return ((data['por_cliente'] as List?) ?? [])
        .map((e) =>
            ClienteFaturamento.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final faturamentoPorClienteProvider =
    AsyncNotifierProvider<FaturamentoPorClienteNotifier,
        List<ClienteFaturamento>>(FaturamentoPorClienteNotifier.new);
