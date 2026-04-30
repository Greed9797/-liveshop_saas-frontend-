import 'package:flutter/material.dart';
import '../core/ll_theme.dart';
import '../widgets/ll_components.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  String section = 'conta';
  bool showCurrent = false;
  bool showNew = false;
  bool showConfirm = false;

  final website = TextEditingController();

  @override
  void dispose() {
    website.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navItems = const [
      _ConfigNav('conta', 'Minha Conta', 'Logo, senha e perfil', Icons.person_outline),
      _ConfigNav('plano', 'Meu Plano', 'Assinatura e contrato', Icons.credit_card_outlined),
      _ConfigNav('suporte', 'Suporte', 'Fale com a equipe', Icons.notifications_none_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: LLScreenHeader(label: 'Minha Conta', italic: 'Configurações', subtitle: 'Gerencie sua conta, plano e preferências'),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 240,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(border: Border(right: BorderSide(color: context.llBorder))),
                child: Column(children: [
                  for (final item in navItems) _ConfigNavButton(item: item, active: section == item.id, onTap: () => setState(() => section = item.id)),
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Align(alignment: Alignment.topLeft, child: _content()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _content() {
    return switch (section) {
      'plano' => const _PlanoSection(),
      'suporte' => const _SuporteSection(),
      _ => _ContaSection(
          website: website,
          showCurrent: showCurrent,
          showNew: showNew,
          showConfirm: showConfirm,
          onToggleCurrent: () => setState(() => showCurrent = !showCurrent),
          onToggleNew: () => setState(() => showNew = !showNew),
          onToggleConfirm: () => setState(() => showConfirm = !showConfirm),
        ),
    };
  }
}

class _ConfigNavButton extends StatelessWidget {
  const _ConfigNavButton({required this.item, required this.active, required this.onTap});
  final _ConfigNav item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(color: active ? LL.accentSoft : Colors.transparent, borderRadius: BorderRadius.circular(9)),
          child: Stack(children: [
            if (active)
              Positioned(left: -12, top: 3, bottom: 3, child: Container(width: 3, decoration: const BoxDecoration(color: LL.accent, borderRadius: BorderRadius.horizontal(right: Radius.circular(2))))),
            Row(children: [
              Icon(item.icon, size: 16, color: active ? LL.accent : context.llTextMuted),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.label, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w900 : FontWeight.w700, color: active ? context.llTextPrimary : context.llTextSecond)),
                const SizedBox(height: 1),
                Text(item.desc, style: LL.caption.copyWith(fontSize: 10.5)),
              ])),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _ContaSection extends StatelessWidget {
  const _ContaSection({
    required this.website,
    required this.showCurrent,
    required this.showNew,
    required this.showConfirm,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onToggleConfirm,
  });

  final TextEditingController website;
  final bool showCurrent;
  final bool showNew;
  final bool showConfirm;
  final VoidCallback onToggleCurrent;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 620,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        LLCard(
          padding: const EdgeInsets.all(20),
          borderColor: context.llBorderMid,
          child: Row(children: [
            const LLAvatar(initials: 'LP', size: 56),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Loja Parceira Teste', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: context.llTextPrimary, letterSpacing: -0.4)),
              const SizedBox(height: 2),
              Text('cliente@lojaparceira.com.br · Cliente desde abr/2026', style: TextStyle(fontSize: 12, color: context.llTextMuted, fontWeight: FontWeight.w500)),
            ])),
            const LLBadge(label: 'Ativa', color: LL.success, background: LL.successSoft),
          ]),
        ),
        const SizedBox(height: 14),
        LLCard(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('Logo da Empresa', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.llTextPrimary))),
              Text('Buscamos automaticamente do seu site', style: LL.caption),
            ]),
            const SizedBox(height: 4),
            Text('O logo aparecerá nas suas lives e no painel', style: LL.caption.copyWith(fontSize: 11.5)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: TextField(controller: website, decoration: const InputDecoration(hintText: 'https://minhaempresa.com.br'))),
              const SizedBox(width: 10),
              LLButton(label: 'Buscar logo', icon: Icons.search_rounded, onTap: () {}),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        LLCard(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Alterar Senha', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.llTextPrimary)),
            const SizedBox(height: 4),
            Text('Mínimo 8 caracteres com letras e números', style: LL.caption.copyWith(fontSize: 11.5)),
            const SizedBox(height: 14),
            _PasswordField(hint: 'Senha atual', visible: showCurrent, onToggle: onToggleCurrent),
            const SizedBox(height: 10),
            _PasswordField(hint: 'Nova senha', visible: showNew, onToggle: onToggleNew),
            const SizedBox(height: 10),
            _PasswordField(hint: 'Confirmar nova senha', visible: showConfirm, onToggle: onToggleConfirm),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerRight, child: LLButton(label: 'Salvar nova senha', onTap: () {})),
          ]),
        ),
      ]),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.hint, required this.visible, required this.onToggle});
  final String hint;
  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: !visible,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(visible ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: context.llTextMuted),
        ),
      ),
    );
  }
}

class _PlanoSection extends StatelessWidget {
  const _PlanoSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 620,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        LLCard(
          padding: const EdgeInsets.all(24),
          borderColor: context.llBorderMid,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PLANO ATUAL', style: LL.label),
            const SizedBox(height: 8),
            Text.rich(TextSpan(children: [
              TextSpan(text: 'Plano Free', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: context.llTextPrimary, letterSpacing: -0.8)),
              TextSpan(text: ' · nenhum contrato ativo', style: LL.caption.copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
            ])),
            const SizedBox(height: 8),
            Text('Faça upgrade para destravar mais cabines, prime time e métricas avançadas', style: TextStyle(fontSize: 12.5, color: context.llTextSecond, fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            LLButton(label: 'Fazer upgrade', icon: Icons.bolt_rounded, onTap: () {}),
          ]),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final cards = const [
            _PlanCard(name: 'Starter', price: 'R\$ 0', features: ['1 cabine', '4 lives/mês', 'Métricas básicas'], current: true),
            _PlanCard(name: 'Pro', price: 'R\$ 490', features: ['3 cabines', '20 lives/mês', 'Prime time'], highlight: true),
            _PlanCard(name: 'Scale', price: 'R\$ 1.290', features: ['Cabines ilimitadas', 'Lives ilimitadas', 'Suporte dedicado']),
          ];
          if (compact) {
            return Column(children: [cards[0], const SizedBox(height: 10), cards[1], const SizedBox(height: 10), cards[2]]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 10),
            Expanded(child: cards[1]),
            const SizedBox(width: 10),
            Expanded(child: cards[2]),
          ]);
        }),
      ]),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.name, required this.price, required this.features, this.current = false, this.highlight = false});
  final String name;
  final String price;
  final List<String> features;
  final bool current;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return LLCard(
      padding: const EdgeInsets.all(16),
      radius: 12,
      borderColor: highlight ? LL.accent.llOpacity(0.55) : context.llBorder,
      child: Stack(children: [
        if (highlight)
          Positioned(
            top: -8,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: LL.accent, borderRadius: BorderRadius.circular(4)),
              child: const Text('RECOMENDADO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
            ),
          ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: context.llTextPrimary)),
          const SizedBox(height: 6),
          Text.rich(TextSpan(children: [
            TextSpan(text: price, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: highlight ? LL.accent : context.llTextPrimary, letterSpacing: -0.6)),
            TextSpan(text: '/mês', style: LL.caption.copyWith(fontSize: 11)),
          ])),
          const SizedBox(height: 12),
          for (final f in features) Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Icon(Icons.check_rounded, size: 13, color: highlight ? LL.accent : LL.success),
              const SizedBox(width: 6),
              Expanded(child: Text(f, style: TextStyle(fontSize: 11.5, color: context.llTextSecond, fontWeight: FontWeight.w600))),
            ]),
          ),
          if (current) ...[
            const SizedBox(height: 6),
            const Text('✓ PLANO ATUAL', style: TextStyle(fontSize: 11, color: LL.success, fontWeight: FontWeight.w900, letterSpacing: 0.4)),
          ],
        ]),
      ]),
    );
  }
}

class _SuporteSection extends StatelessWidget {
  const _SuporteSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        LLCard(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF25D366).llOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: Color(0xFF25D366))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Suporte via WhatsApp', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.llTextPrimary)),
                const SizedBox(height: 2),
                Text('Resposta em até 30 minutos · seg-sex 9h-19h', style: LL.caption.copyWith(fontSize: 12)),
              ])),
            ]),
            const SizedBox(height: 16),
            Text('Para suporte, entre em contato com a equipe da unidade. Estamos prontos para ajudar com cabines, agendamentos e dúvidas sobre o painel.', style: TextStyle(fontSize: 12.5, color: context.llTextSecond, height: 1.5, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            const LLButton(label: 'Abrir WhatsApp', icon: Icons.chat_bubble_outline_rounded, variant: LLButtonVariant.whatsapp, expanded: true),
          ]),
        ),
        const SizedBox(height: 14),
        LLCard(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Outros canais', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: context.llTextPrimary)),
            const SizedBox(height: 12),
            _SupportItem(icon: Icons.notifications_none_rounded, label: 'Central de ajuda', desc: 'Tutoriais e perguntas frequentes'),
            _SupportItem(icon: Icons.person_outline, label: 'Falar com gerente', desc: 'Sua gerente: Camila Moura'),
          ]),
        ),
      ]),
    );
  }
}

class _SupportItem extends StatelessWidget {
  const _SupportItem({required this.icon, required this.label, required this.desc});
  final IconData icon;
  final String label;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.llBorder))),
      child: Row(children: [
        Icon(icon, size: 16, color: context.llTextMuted),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: context.llTextPrimary)),
          const SizedBox(height: 1),
          Text(desc, style: LL.caption.copyWith(fontSize: 11)),
        ])),
        Icon(Icons.chevron_right_rounded, size: 16, color: context.llTextMuted),
      ]),
    );
  }
}

class _ConfigNav {
  const _ConfigNav(this.id, this.label, this.desc, this.icon);
  final String id;
  final String label;
  final String desc;
  final IconData icon;
}
