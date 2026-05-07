// Perfil do cliente_parceiro autenticado: nome, logo_url, site, etc.
// Usado pra exibir logo do cliente em avatar topbar + sidebar footer.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class ClientePerfil {
  final String? id;
  final String? nome;
  final String? email;
  final String? logoUrl;
  final String? site;
  const ClientePerfil({this.id, this.nome, this.email, this.logoUrl, this.site});

  factory ClientePerfil.fromJson(Map<String, dynamic> j) => ClientePerfil(
        id: j['id'] as String?,
        nome: j['nome'] as String?,
        email: j['email'] as String?,
        logoUrl: j['logo_url'] as String?,
        site: j['site'] as String?,
      );
}

final clientePerfilProvider = FutureProvider<ClientePerfil?>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated || auth.user?.papel != 'cliente_parceiro') return null;
  try {
    final resp = await ApiService.get<Map<String, dynamic>>('/cliente/perfil');
    return ClientePerfil.fromJson(resp.data as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});
