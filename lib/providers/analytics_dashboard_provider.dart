import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_dashboard.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// ─────────────────────────────────────────
// Filtros (estado síncrono)
// ─────────────────────────────────────────

String _currentMesAno() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
}

class DashboardFiltrosNotifier extends Notifier<AnalyticsFiltros> {
  @override
  AnalyticsFiltros build() => AnalyticsFiltros(
        clienteId: null,
        mesAno: _currentMesAno(),
      );

  void setClienteId(String? id) {
    state = state.copyWith(clienteId: id);
  }

  void setMesAno(String mesAno) {
    state = state.copyWith(mesAno: mesAno);
  }

  void reset() {
    state = AnalyticsFiltros(clienteId: null, mesAno: _currentMesAno());
  }
}

final dashboardFiltrosProvider =
    NotifierProvider<DashboardFiltrosNotifier, AnalyticsFiltros>(
  DashboardFiltrosNotifier.new,
);

// ─────────────────────────────────────────
// Dados (estado assíncrono — re-fetch automático ao mudar filtros)
// ─────────────────────────────────────────

class AnalyticsDashboardNotifier
    extends AsyncNotifier<AnalyticsDashboardData> {
  @override
  Future<AnalyticsDashboardData> build() {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) {
      throw Exception('Não autenticado');
    }
    // ref.watch garante re-fetch automático quando os filtros mudam
    final filtros = ref.watch(dashboardFiltrosProvider);
    return _fetch(filtros);
  }

  Future<AnalyticsDashboardData> _fetch(AnalyticsFiltros filtros) async {
    final params = <String, dynamic>{'mesAno': filtros.mesAno};
    if (filtros.clienteId != null) params['cliente_id'] = filtros.clienteId;

    final resp = await ApiService.get('/analytics/dashboard', params: params);
    return AnalyticsDashboardData.fromJson(
      Map<String, dynamic>.from(resp.data as Map),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final filtros = ref.read(dashboardFiltrosProvider);
    state = await AsyncValue.guard(() => _fetch(filtros));
  }
}

final analyticsDashboardProvider =
    AsyncNotifierProvider<AnalyticsDashboardNotifier, AnalyticsDashboardData>(
  AnalyticsDashboardNotifier.new,
);
