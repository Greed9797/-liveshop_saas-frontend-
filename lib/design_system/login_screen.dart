import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

/// 🔐 Exemplo: Tela de Login Livelab
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _loading = false);
    // TODO: navegação
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.x6),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.x8),
                shadow: AppShadows.lg,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      _LivelabLogo(),
                      const SizedBox(height: AppSpacing.x2),
                      Text(
                        'Gestão de Franquias',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x8),

                      // Email
                      AppTextField(
                        hint: 'E-mail',
                        prefixIcon: Icons.mail_outline,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Digite seu e-mail'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.x4),

                      // Senha
                      AppTextField(
                        hint: 'Senha',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        controller: _passCtrl,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Digite sua senha'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.x6),

                      // Botão entrar
                      AppPrimaryButton(
                        label: 'Entrar',
                        fullWidth: true,
                        isLoading: _loading,
                        onPressed: _handleLogin,
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

/// Logo Livelab — "Live/ab." com ponto laranja
class _LivelabLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -1,
        ),
        children: [
          TextSpan(text: 'Live'),
          TextSpan(
            text: '/',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          TextSpan(
            text: 'ab',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          TextSpan(
            text: '.',
            style: TextStyle(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
