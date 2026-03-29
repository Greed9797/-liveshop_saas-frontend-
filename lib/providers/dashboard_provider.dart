import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard.dart';
import '../services/api_service.dart';

class DashboardNotifier extends AsyncNotifier<DashboardData> {
  Timer? _timer;

  @override
  Future<DashboardData> build() async {
    final data = await _fetch();

    // Inicia polling de 15 segundos
    _startPolling();

    ref.onDispose(() {
      _timer?.cancel();
    });

    return data;
  }

  Future<DashboardData> _fetch() async {
    final resp = await ApiService.get('/home/dashboard');
    return DashboardData.fromJson(resp.data as Map<String, dynamic>);
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        final newData = await _fetch();
        if (state.hasValue) {
          state = AsyncValue.data(newData);
        }
      } catch (e) {
        print('Erro no polling do dashboard: $e');
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardData>(
        DashboardNotifier.new);
