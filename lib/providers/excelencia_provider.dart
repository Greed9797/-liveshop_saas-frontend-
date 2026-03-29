import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/excelencia.dart';
import '../services/api_service.dart';

class ExcelenciaNotifier extends AsyncNotifier<ExcelenciaData> {
  @override
  Future<ExcelenciaData> build() => _fetch();

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
