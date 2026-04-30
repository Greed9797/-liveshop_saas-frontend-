import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lead.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class LeadsNotifier extends AsyncNotifier<List<Lead>> {
  @override
  Future<List<Lead>> build() async {
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) {
      throw Exception('Não autenticado');
    }
    return _fetch();
  }

  Future<List<Lead>> _fetch() async {
    final resp = await ApiService.get('/leads');
    return (resp.data as List)
        .map((e) => Lead.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> pegar(String id) async {
    await ApiService.post('/leads/$id/pegar');
    // Remove localmente para feedback imediato
    state = AsyncData(
      state.valueOrNull?.where((l) => l.id != id).toList() ?? [],
    );
    // Recarrega para pegar com dados atualizados
    state = await AsyncValue.guard(_fetch);
  }

  Future<Lead> criar(Map<String, dynamic> data) async {
    final resp = await ApiService.post('/leads', data: data);
    final lead = Lead.fromJson(resp.data as Map<String, dynamic>);
    state = AsyncData([lead, ...state.valueOrNull ?? []]);
    return lead;
  }

  Future<Lead> atualizar(String id, Map<String, dynamic> data) async {
    final resp = await ApiService.patch('/leads/$id', data: data);
    final updated = Lead.fromJson(resp.data as Map<String, dynamic>);
    state = AsyncData(
      (state.valueOrNull ?? [])
          .map((lead) => lead.id == id ? updated : lead)
          .toList(),
    );
    return updated;
  }

  Future<Lead> moverEtapa(
    String id,
    String etapa, {
    String? motivoPerda,
  }) async {
    final resp = await ApiService.patch('/leads/$id/etapa', data: {
      'crm_etapa': etapa,
      if (motivoPerda != null) 'motivo_perda': motivoPerda,
    });
    final updated = Lead.fromJson(resp.data as Map<String, dynamic>);
    state = AsyncData(
      (state.valueOrNull ?? [])
          .map((lead) => lead.id == id ? updated : lead)
          .toList(),
    );
    return updated;
  }

  Future<void> ganhar(String id, Map<String, dynamic> data) async {
    await ApiService.post('/leads/$id/ganhar', data: data);
    state = AsyncData(
      (state.valueOrNull ?? []).where((lead) => lead.id != id).toList(),
    );
  }
}

final leadsProvider =
    AsyncNotifierProvider<LeadsNotifier, List<Lead>>(LeadsNotifier.new);
