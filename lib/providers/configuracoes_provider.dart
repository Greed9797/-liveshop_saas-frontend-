import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/configuracoes.dart';
import '../services/api_service.dart';

class ConfiguracoesNotifier extends AsyncNotifier<ConfiguracoesFranquia> {
  @override
  Future<ConfiguracoesFranquia> build() => _fetch();

  Future<ConfiguracoesFranquia> _fetch() async {
    final resp = await ApiService.get('/configuracoes');
    return ConfiguracoesFranquia.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> atualizar(Map<String, dynamic> payload) async {
    await ApiService.patch('/configuracoes', data: payload);
    await refresh();
  }
}

final configuracoesProvider =
    AsyncNotifierProvider<ConfiguracoesNotifier, ConfiguracoesFranquia>(ConfiguracoesNotifier.new);
