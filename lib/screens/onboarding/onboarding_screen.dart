import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/design_system.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _page = 0; // 0=welcome, 1=form, 2=success

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: _page == 0
              ? _WelcomePage(onStart: () => setState(() => _page = 1))
              : _page == 1
                  ? _FormPage(onSuccess: () => setState(() => _page = 2))
                  : _SuccessPage(onDone: _finish),
        ),
      ),
    );
  }

  Future<void> _finish() async {
    await ref.read(authProvider.notifier).completeOnboarding();
  }
}

// ─── Welcome ─────────────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Center(
                child: Text(
                  'L',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x6),
            Text(
              'Bem-vindo(a) ao Livelabs!',
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              'Antes de começar, precisamos conhecer melhor o seu negócio.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  'Começar',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Form ─────────────────────────────────────────────────────────────────────

class _FormPage extends ConsumerStatefulWidget {
  const _FormPage({required this.onSuccess});
  final VoidCallback onSuccess;

  @override
  ConsumerState<_FormPage> createState() => _FormPageState();
}

class _FormPageState extends ConsumerState<_FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = <String, TextEditingController>{};
  String _liveExperience = 'none';
  bool _submitting = false;

  static const _required = [
    ('company_name', 'Nome da empresa'),
    ('responsible_name', 'Responsável principal'),
    ('main_products', 'Produtos principais'),
    ('sales_history', 'Histórico de vendas'),
    ('focus_products', 'Produtos para focar agora'),
    ('current_stock', 'Estoque disponível'),
    ('product_margin', 'Margem dos produtos (ex: 30%)'),
    ('gmv_expectation', 'Expectativa de GMV'),
    ('traffic_budget', 'Verba para GMV Max / tráfego'),
  ];

  static const _optional = [
    ('website_url', 'Site da empresa'),
    ('instagram_url', 'Instagram da empresa'),
    ('tiktok_url', 'TikTok da empresa'),
    ('tiktok_shop_url', 'TikTok Shop da empresa'),
    ('available_offers', 'Oferta, cupom, desconto ou combo'),
  ];

  static const _multiline = {
    'main_products',
    'sales_history',
    'focus_products',
    'current_stock',
    'available_offers',
  };

  @override
  void initState() {
    super.initState();
    for (final f in [..._required, ..._optional]) {
      _ctrl[f.$1] = TextEditingController();
    }
    for (final c in _ctrl.values) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _requiredFilled => _required.every((f) => _ctrl[f.$1]!.text.trim().isNotEmpty);

  double get _progress {
    final filled = _required.where((f) => _ctrl[f.$1]!.text.trim().isNotEmpty).length;
    return filled / _required.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(progress: _progress),
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.x4),
              children: [
                ..._required.map((f) => _Field(
                  key: ValueKey(f.$1),
                  ctrl: _ctrl[f.$1]!,
                  label: f.$2,
                  required: true,
                  multiline: _multiline.contains(f.$1),
                )),
                const SizedBox(height: AppSpacing.x4),
                Text(
                  'Informações opcionais',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.x2),
                ..._optional.map((f) => _Field(
                  key: ValueKey(f.$1),
                  ctrl: _ctrl[f.$1]!,
                  label: f.$2,
                  required: false,
                  multiline: _multiline.contains(f.$1),
                )),
                const SizedBox(height: AppSpacing.x4),
                _ExperienceDropdown(
                  value: _liveExperience,
                  onChanged: (v) => setState(() => _liveExperience = v!),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _SubmitBar(
          enabled: _requiredFilled && !_submitting,
          loading: _submitting,
          onSubmit: _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_requiredFilled) return;
    setState(() => _submitting = true);

    final data = <String, dynamic>{
      'live_experience': _liveExperience,
    };
    for (final f in [..._required, ..._optional]) {
      final v = _ctrl[f.$1]!.text.trim();
      data[f.$1] = v.isEmpty ? null : v;
    }

    final ok = await ref.read(onboardingProvider.notifier).submit(data);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      widget.onSuccess();
    } else {
      final err = ref.read(onboardingProvider).error ?? 'Erro ao enviar.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.danger),
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.x4, AppSpacing.x4, AppSpacing.x4, AppSpacing.x2),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: AppColors.textMuted.withOpacity(0.15)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Formulário de onboarding', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.x1),
          Text(
            'Preencha os campos obrigatórios para continuar.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.x2),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.textMuted.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    super.key,
    required this.ctrl,
    required this.label,
    required this.required,
    required this.multiline,
  });

  final TextEditingController ctrl;
  final String label;
  final bool required;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              children: required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.danger),
                      )
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          TextFormField(
            controller: ctrl,
            maxLines: multiline ? 3 : 1,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: required ? 'Obrigatório' : 'Opcional',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3,
                vertical: AppSpacing.x2,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceDropdown extends StatelessWidget {
  const _ExperienceDropdown({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Experiência anterior com live',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.danger),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x1),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x3,
              vertical: AppSpacing.x2,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'none', child: Text('Nenhuma')),
            DropdownMenuItem(value: 'low', child: Text('Pouca')),
            DropdownMenuItem(value: 'moderate', child: Text('Moderada')),
            DropdownMenuItem(value: 'advanced', child: Text('Avançada')),
          ],
        ),
      ],
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.enabled,
    required this.loading,
    required this.onSubmit,
  });
  final bool enabled;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: AppColors.textMuted.withOpacity(0.15)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: enabled ? onSubmit : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.textMuted.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Enviar informações',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Success ──────────────────────────────────────────────────────────────────

class _SuccessPage extends StatelessWidget {
  const _SuccessPage({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: AppColors.success, size: 40),
            ),
            const SizedBox(height: AppSpacing.x6),
            Text(
              'Obrigado por compartilhar suas informações!',
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              'Sua equipe LiveLabs já pode começar a trabalhar com você.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onDone,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  'Ir para o Dashboard',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
