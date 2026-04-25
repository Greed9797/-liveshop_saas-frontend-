import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design_system/design_system.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final _meuContratoProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final resp = await ApiService.get<Map<String, dynamic>>('/contratos/meu');
  return resp.data;
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class ClienteConfiguracoesScreen extends ConsumerStatefulWidget {
  const ClienteConfiguracoesScreen({super.key});

  @override
  ConsumerState<ClienteConfiguracoesScreen> createState() =>
      _ClienteConfiguracoesScreenState();
}

class _ClienteConfiguracoesScreenState
    extends ConsumerState<ClienteConfiguracoesScreen> {
  int _selectedSection = 0;

  // Password controllers
  final _senhaAtualCtrl = TextEditingController();
  final _novaSenhaCtrl = TextEditingController();
  final _confirmaSenhaCtrl = TextEditingController();

  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    _novaSenhaCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _senhaAtualCtrl.dispose();
    _novaSenhaCtrl.dispose();
    _confirmaSenhaCtrl.dispose();
    super.dispose();
  }

  PasswordStrength _strength(String pwd) {
    final hasUpper = pwd.contains(RegExp(r'[A-Z]'));
    final hasNumber = pwd.contains(RegExp(r'[0-9]'));
    final hasSpecial =
        pwd.contains(RegExp(r'[!@#$%^&*()\-_=+\[\]{};:,.<>?/\\|`~]'));
    if (pwd.length >= 10 && hasUpper && hasNumber && hasSpecial) {
      return PasswordStrength.forte;
    }
    if (pwd.length >= 8 && hasNumber) {
      return PasswordStrength.media;
    }
    return PasswordStrength.fraca;
  }

  Future<void> _salvarSenha() async {
    final atual = _senhaAtualCtrl.text.trim();
    final nova = _novaSenhaCtrl.text.trim();
    final confirma = _confirmaSenhaCtrl.text.trim();

    if (atual.isEmpty) {
      _snack('Informe sua senha atual.');
      return;
    }
    if (nova.isEmpty) {
      _snack('Informe a nova senha.');
      return;
    }
    if (nova != confirma) {
      _snack('As senhas não coincidem.');
      return;
    }

    setState(() => _savingPassword = true);
    try {
      await ApiService.patch('/auth/senha', data: {
        'senha_atual': atual,
        'nova_senha': nova,
      });
      if (!mounted) return;
      _snack('Senha alterada com sucesso!');
      _senhaAtualCtrl.clear();
      _novaSenhaCtrl.clear();
      _confirmaSenhaCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      _snack(ApiService.extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AppScreenScaffold(
      currentRoute: AppRoutes.clienteConfiguracoes,
      eyebrow: 'MINHA CONTA',
      titleSerif: true,
      title: 'Configurações',
      subtitle: 'Gerencie sua conta e plano.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 700;

          if (isNarrow) {
            return _buildMobileLayout();
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left sidebar nav (200px)
              Container(
                width: 200,
                decoration: BoxDecoration(
                  color: context.colors.bgPage,
                  border: Border(
                    right: BorderSide(color: context.colors.borderSubtle),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.x5),
                    _NavItem(
                      icon: Icons.lock_outline_rounded,
                      label: 'Minha Conta',
                      isActive: _selectedSection == 0,
                      onTap: () => setState(() => _selectedSection = 0),
                    ),
                    _NavItem(
                      icon: Icons.workspace_premium_outlined,
                      label: 'Meu Plano',
                      isActive: _selectedSection == 1,
                      onTap: () => setState(() => _selectedSection = 1),
                    ),
                    _NavItem(
                      icon: Icons.support_agent_outlined,
                      label: 'Suporte',
                      isActive: _selectedSection == 2,
                      onTap: () => setState(() => _selectedSection = 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.x6),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(
                    key: ValueKey(_selectedSection),
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.x4),
      children: [
        _SectionCard(
          icon: Icons.lock_outline_rounded,
          title: 'Minha Conta',
          child: _buildMinhaConta(),
        ),
        const SizedBox(height: AppSpacing.x4),
        _SectionCard(
          icon: Icons.workspace_premium_outlined,
          title: 'Meu Plano',
          child: _buildMeuPlano(),
        ),
        const SizedBox(height: AppSpacing.x4),
        _SectionCard(
          icon: Icons.support_agent_outlined,
          title: 'Suporte',
          child: _buildSuporte(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_selectedSection) {
      case 0:
        return _buildMinhaConta();
      case 1:
        return _buildMeuPlano();
      case 2:
        return _buildSuporte();
      default:
        return _buildMinhaConta();
    }
  }

  // ─── Minha Conta ────────────────────────────────────────────────────────────

  Widget _buildMinhaConta() {
    return _PanelScaffold(
      title: 'Alterar Senha',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PasswordField(
            controller: _senhaAtualCtrl,
            hint: 'Senha atual *',
          ),
          const SizedBox(height: AppSpacing.x3),
          _PasswordField(
            controller: _novaSenhaCtrl,
            hint: 'Nova senha *',
          ),
          if (_novaSenhaCtrl.text.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.x2),
            _PasswordStrengthBar(strength: _strength(_novaSenhaCtrl.text)),
            const SizedBox(height: AppSpacing.x3),
          ] else ...[
            const SizedBox(height: AppSpacing.x3),
          ],
          _PasswordField(
            controller: _confirmaSenhaCtrl,
            hint: 'Confirmar nova senha *',
          ),
          const SizedBox(height: AppSpacing.x6),
          Align(
            alignment: Alignment.centerRight,
            child: AppPrimaryButton(
              label: 'Salvar senha',
              isLoading: _savingPassword,
              onPressed: _salvarSenha,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Meu Plano ──────────────────────────────────────────────────────────────

  Widget _buildMeuPlano() {
    final contratoAsync = ref.watch(_meuContratoProvider);

    return _PanelScaffold(
      title: 'Meu Plano',
      child: contratoAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.x6),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, __) => _EmptyPlan(),
        data: (contrato) {
          if (contrato == null) return _EmptyPlan();

          final currFmt = NumberFormat.currency(
              locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
          final pacote = contrato['pacote'] as Map<String, dynamic>?;
          final pacoteNome =
              (pacote?['nome'] ?? contrato['nome'] ?? '—') as String;
          final valorFixo =
              (contrato['valor_fixo'] as num? ?? pacote?['valor_fixo'] as num? ?? 0)
                  .toDouble();
          final comissaoPct =
              (contrato['comissao_pct'] as num? ?? pacote?['comissao_pct'] as num? ?? 0)
                  .toDouble();
          final horasContratadas =
              (contrato['horas_contratadas'] as num? ?? pacote?['horas_incluidas'] as num? ?? 0)
                  .toDouble();
          final horasUsadas =
              (contrato['horas_usadas'] as num? ?? 0).toDouble();
          final horasRestantes =
              (horasContratadas - horasUsadas).clamp(0.0, horasContratadas);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReadOnlyRow(label: 'Pacote', value: pacoteNome),
              const SizedBox(height: AppSpacing.x3),
              _ReadOnlyRow(
                  label: 'Valor fixo', value: currFmt.format(valorFixo)),
              const SizedBox(height: AppSpacing.x3),
              _ReadOnlyRow(
                  label: 'Comissão',
                  value: '${comissaoPct.toStringAsFixed(1)}%'),
              const SizedBox(height: AppSpacing.x3),
              _ReadOnlyRow(
                  label: 'Horas contratadas',
                  value: '${horasContratadas.toStringAsFixed(0)}h'),
              const SizedBox(height: AppSpacing.x3),
              _ReadOnlyRow(
                  label: 'Horas restantes',
                  value: '${horasRestantes.toStringAsFixed(0)}h'),
              const SizedBox(height: AppSpacing.x4),
              Container(
                padding: const EdgeInsets.all(AppSpacing.x3),
                decoration: BoxDecoration(
                  color: context.colors.bgMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: context.colors.textMuted),
                    const SizedBox(width: AppSpacing.x2),
                    Expanded(
                      child: Text(
                        'Para alterações no plano, entre em contato com a unidade.',
                        style: AppTypography.caption.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Suporte ────────────────────────────────────────────────────────────────

  Widget _buildSuporte() {
    return _PanelScaffold(
      title: 'Suporte',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(PhosphorIcons.headset(),
                  size: 20, color: context.colors.textMuted),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Text(
                  'Para suporte, entre em contato com a equipe da unidade.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(PhosphorIcons.whatsappLogo(), size: 18),
              label: const Text('Abrir WhatsApp'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFF25D366)),
                foregroundColor: const Color(0xFF25D366),
              ),
              onPressed: () async {
                final uri = Uri.parse(
                    'https://wa.me/?text=Olá, preciso de suporte');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _EmptyPlan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x6),
      child: Column(
        children: [
          Icon(Icons.workspace_premium_outlined,
              size: 40, color: context.colors.textMuted),
          const SizedBox(height: AppSpacing.x3),
          Text(
            'Nenhum contrato ativo encontrado.',
            style:
                AppTypography.bodySmall.copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.caption
                .copyWith(color: context.colors.textMuted)),
        const SizedBox(height: AppSpacing.x1),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4, vertical: AppSpacing.x3),
          decoration: BoxDecoration(
            color: context.colors.bgPage,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: context.colors.borderSubtle),
          ),
          child: Text(
            value.isNotEmpty ? value : '—',
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;

  const _PasswordField({required this.controller, required this.hint});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      hint: widget.hint,
      obscureText: _obscure,
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          size: 18,
          color: context.colors.textMuted,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}

// ─── Panel Scaffold ───────────────────────────────────────────────────────────

class _PanelScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const _PanelScaffold({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x6),
            child: AppCard(
              radius: AppRadius.xl,
              borderColor: context.colors.borderSubtle,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: AppTypography.h3),
                    const Divider(height: 32),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section Card (mobile) ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.xl,
      borderColor: context.colors.borderSubtle,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.x2),
                Text(title, style: AppTypography.h3),
              ],
            ),
            const Divider(height: 28),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4, vertical: AppSpacing.x3),
        decoration: BoxDecoration(
          color: isActive ? context.colors.primarySoftBg : Colors.transparent,
          border: isActive
              ? const Border(left: BorderSide(color: AppColors.primary, width: 3))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color:
                    isActive ? AppColors.primary : context.colors.textMuted),
            const SizedBox(width: AppSpacing.x3),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isActive
                    ? AppColors.primary
                    : context.colors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Password Strength ────────────────────────────────────────────────────────

enum PasswordStrength { fraca, media, forte }

class _PasswordStrengthBar extends StatelessWidget {
  final PasswordStrength strength;

  const _PasswordStrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    final (value, color, label) = switch (strength) {
      PasswordStrength.fraca => (0.33, AppColors.danger, 'Senha fraca'),
      PasswordStrength.media => (0.66, AppColors.warning, 'Senha média'),
      PasswordStrength.forte => (1.0, AppColors.success, 'Senha forte'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 4,
            backgroundColor: context.colors.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: AppSpacing.x1),
        Text(label, style: AppTypography.caption.copyWith(color: color)),
      ],
    );
  }
}
