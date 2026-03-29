import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class Manual {
  final String id;
  final String titulo;
  final String url;
  final DateTime atualizadoEm;

  const Manual({
    required this.id,
    required this.titulo,
    required this.url,
    required this.atualizadoEm,
  });

  factory Manual.fromJson(Map<String, dynamic> j) => Manual(
    id:           j['id'] as String,
    titulo:       j['titulo'] as String,
    url:          j['url'] as String,
    atualizadoEm: DateTime.parse(j['atualizado_em'] as String),
  );
}

class ManuaisNotifier extends AsyncNotifier<List<Manual>> {
  @override
  Future<List<Manual>> build() => _fetch();

  Future<List<Manual>> _fetch() async {
    final resp = await ApiService.get<List<dynamic>>('/manuais');
    return (resp.data as List).map((e) => Manual.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final manuaisProvider =
    AsyncNotifierProvider<ManuaisNotifier, List<Manual>>(ManuaisNotifier.new);
