import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../design_system/design_system.dart' hide AppCard;
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
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final authError = _localError ?? authState.error;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFEAEAEA)),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFF1EFEE), Color(0xFFFCD1BE)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x6),
                child: AppCard(
                  boxShadow: AppShadows.lg,
                  borderColor: Colors.transparent,
                  backgroundColor: Colors.white,
                  borderRadius: AppRadius.xl,
                  padding: const EdgeInsets.all(AppSpacing.x10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: SizedBox(
                          width: 230,
                          child: Image.asset('assets/images/logo.png'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x3),
                      Text(
                        'Gestão de Franquias',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x8),
                      AppTextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        hint: 'E-mail',
                        prefixIcon: PhosphorIcons.envelopeSimple(),
                      ),
                      const SizedBox(height: AppSpacing.x4),
                      AppTextField(
                        controller: _senhaCtrl,
                        obscureText: _obscure,
                        hint: 'Senha',
                        prefixIcon: PhosphorIcons.lockKey(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? PhosphorIcons.eyeSlash()
                                : PhosphorIcons.eye(),
                            color: AppColors.textMuted,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        onSubmitted: (_) => _login(),
                      ),
                      if (authError != null) ...[
                        const SizedBox(height: AppSpacing.x4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.x3),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            authError,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.danger),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.x8),
                      AppPrimaryButton(
                        onPressed: isLoading ? () {} : _login,
                        isLoading: isLoading,
                        label: 'Entrar',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
