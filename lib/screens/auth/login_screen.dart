import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../widgets/app_card.dart';

/// Tela de login — ponto de entrada do sistema
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _obscure = true;
  String? _localError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text;

    // Validação local — sem chamada de rede
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() => _localError = 'Email inválido.');
      return;
    }
    if (senha.isEmpty) {
      setState(() => _localError = 'Informe a senha.');
      return;
    }
    setState(() => _localError = null);

    final auth = ref.read(authProvider.notifier);
    final ok = await auth.login(email, senha);
    if (!mounted) return;

    if (ok) {
      final user = ref.read(authProvider).user!;
      final route = AppRoutes.routeForRole(user.papel);
      Navigator.pushReplacementNamed(context, route);
    }
    // Erro do backend exibido pelo bloco inline via authState.error
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final authError = _localError ?? authState.error;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AppCard(
            boxShadow: AppShadows.xl,
            padding: const EdgeInsets.all(AppSpacing.x4l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 120,
                  child: Image.asset('assets/images/logo.png'),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Livelab',
                    style: AppTypography.h2.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: AppSpacing.xs),
                Text('Gestão de Franquias',
                    style: AppTypography.labelLarge.copyWith(color: context.colors.textSecondary)),
                const SizedBox(height: AppSpacing.x3l),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _senhaCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: AppSpacing.x2l),
                if (authError != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: context.colors.error.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      authError,
                      style: TextStyle(color: context.colors.error),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: context.colors.cardBackground, strokeWidth: 2))
                        : Text('ENTRAR',
                            style: TextStyle(
                                color: context.colors.cardBackground,
                                fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
