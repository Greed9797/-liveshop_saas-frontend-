import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/excelencia.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class ExcelenciaNotifier extends AsyncNotifier<ExcelenciaData> {
  @override
  Future<ExcelenciaData> build() async {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) {
      throw Exception('Não autenticado');
    }
    return _fetch();
  }

  Future<ExcelenciaData> _fetch() async {
    final resp = await ApiService.get('/excelencia/metricas');
    return ExcelenciaData.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final excelenciaProvider =
    AsyncNotifierProvider<ExcelenciaNotifier, ExcelenciaData>(ExcelenciaNotifier.new);
