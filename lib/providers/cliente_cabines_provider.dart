import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cabine.dart';
import '../services/api_service.dart';

class ClienteCabinesNotifier extends AsyncNotifier<List<Cabine>> {
  @override
  Future<List<Cabine>> build() => _fetch();

  Future<List<Cabine>> _fetch() async {
    final res = await ApiService.get<Map<String, dynamic>>('/cabines/minhas');
    final list = (res.data?['cabines'] as List? ?? []);
    return list.map((e) => Cabine.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final clienteCabinesProvider =
    AsyncNotifierProvider<ClienteCabinesNotifier, List<Cabine>>(
  ClienteCabinesNotifier.new,
);
