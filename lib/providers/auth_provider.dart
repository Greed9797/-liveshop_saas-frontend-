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
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(error: _extractError(e));
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout');
    } finally {
      await ApiService.clearTokens();
      state = const AuthState();
    }
  }

  String _extractError(Object e) {
    if (e is Exception) return e.toString().replaceAll('Exception: ', '');
    return 'Erro inesperado';
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
