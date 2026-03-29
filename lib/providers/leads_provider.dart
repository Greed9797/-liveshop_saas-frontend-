import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lead.dart';
import '../services/api_service.dart';

class LeadsNotifier extends AsyncNotifier<List<Lead>> {
  @override
  Future<List<Lead>> build() => _fetch();

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
}

final leadsProvider =
    AsyncNotifierProvider<LeadsNotifier, List<Lead>>(LeadsNotifier.new);
