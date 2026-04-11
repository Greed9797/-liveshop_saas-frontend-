import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});
  bool get isAuthenticated => user != null;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> restoreSession() async {
    try {
      final token = await ApiService.getAccessToken();
      final userJson = await ApiService.getSavedUser();

      if (token == null || userJson == null) {
        if (token != null || userJson != null) {
          await ApiService.clearTokens();
        }
        state = const AuthState();
        return;
      }

      // Usa o token armazenado diretamente. Se expirado,
      // o interceptor de 401 fará refresh automaticamente na primeira chamada.
      // Isso evita destruir a sessão quando o backend está temporariamente offline.
      state = AuthState(user: User.fromJson(userJson));
    } catch (_) {
      await ApiService.clearTokens();
      state = const AuthState();
    }
  }

  Future<bool> login(String email, String senha) async {
    state = const AuthState(isLoading: true);
    try {
      final resp = await ApiService.post('/auth/login', data: {
        'email': email,
        'senha': senha,
      });
      final data = resp.data as Map<String, dynamic>;
      await ApiService.saveTokens(
        data['access_token'] as String,
        data['refresh_token'] as String,
      );
      final userJson = Map<String, dynamic>.from(data['user'] as Map);
      await ApiService.saveUser(userJson);
      final user = User.fromJson(userJson);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(error: ApiService.extractErrorMessage(e));
      return false;
    }
  }

  Future<void> logout() async {
    // Revogar sessão no servidor ANTES de limpar tokens locais.
    // Garante que o refresh_token seja invalidado mesmo se a limpeza local falhar.
    try {
      await ApiService.post('/auth/logout');
    } catch (_) {
      // Ignora falhas de rede — limpa tokens localmente de qualquer forma.
    }
    await ApiService.clearTokens();
    state = const AuthState();
  }

  Future<void> expireSession([
    String message = 'Sessão expirada. Faça login novamente.',
  ]) async {
    await ApiService.clearTokens();
    state = AuthState(error: message);
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
