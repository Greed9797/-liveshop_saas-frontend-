import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_mode_provider.dart';
import '../../routes/app_routes.dart';
import '../theme/tokens.dart';
import '../theme/livelab_theme.dart';

class LivelabNavItem {
  const LivelabNavItem({
    required this.label,
    required this.icon,
    required this.route,
    this.dot = false,
  });
  final String label;
  final IconData icon;
  final String route;
  final bool dot;
}

class LivelabNavSection {
  const LivelabNavSection({this.label, required this.items});
  final String? label;
  final List<LivelabNavItem> items;
}

class LivelabScaffold extends ConsumerWidget {
  const LivelabScaffold({
    super.key,
    required this.currentRoute,
    required this.child,
    this.onRefresh,
  });

  final String currentRoute;
  final Widget child;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.llTokens;
    final auth = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final sections = _navSections(auth.user?.papel ?? 'franqueado');
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 720;

    return Scaffold(
      backgroundColor: t.bgBase,
      body: Stack(
        children: [
          // Radial gradient background overlay
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -1.2),
                    radius: 0.8,
                    colors: [
                      t.primary.withValues(alpha: isDark ? 0.08 : 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isMobile)
            Column(
              children: [
                _Topbar(
                  user: auth.user,
                  isDark: isDark,
                  onToggleTheme: () => ref.read(themeModeProvider.notifier).toggle(),
                  onRefresh: onRefresh ?? () => _hardRefresh(context),
                  onBell: () => _openNotifications(context),
                ),
                Expanded(child: child),
                _BottomNav(sections: sections, currentRoute: currentRoute),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Rail(
                  sections: sections,
                  currentRoute: currentRoute,
                  onLogout: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
                    }
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      _Topbar(
                        user: auth.user,
                        isDark: isDark,
                        onToggleTheme: () => ref.read(themeModeProvider.notifier).toggle(),
                        onRefresh: onRefresh ?? () => _hardRefresh(context),
                        onBell: () => _openNotifications(context),
                      ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _hardRefresh(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? currentRoute;
    Navigator.of(context).pushReplacementNamed(route);
  }

  void _openNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sem notificações no momento.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<LivelabNavSection> _navSections(String papel) {
    final isMaster = papel == 'franqueador_master';
    final isCliente = papel == 'cliente_parceiro';
    final isApresentador = papel == 'apresentador';

    if (isCliente) {
      return [
        LivelabNavSection(items: [
          LivelabNavItem(label: 'Home', icon: PhosphorIcons.house(), route: AppRoutes.cliente),
          LivelabNavItem(label: 'Lives', icon: PhosphorIcons.videoCamera(), route: AppRoutes.clienteLives),
          LivelabNavItem(label: 'Histórico', icon: PhosphorIcons.clockCounterClockwise(), route: AppRoutes.clienteHistorico),
          LivelabNavItem(label: 'Configurações', icon: PhosphorIcons.gear(), route: AppRoutes.clienteConfiguracoes),
        ]),
      ];
    }

    if (isApresentador) {
      return [
        LivelabNavSection(items: [
          LivelabNavItem(label: 'Cabines', icon: PhosphorIcons.videoCamera(), route: AppRoutes.cabines),
          LivelabNavItem(label: 'Base', icon: PhosphorIcons.book(), route: AppRoutes.manuais),
        ]),
      ];
    }

    if (isMaster) {
      return [
        LivelabNavSection(items: [
          LivelabNavItem(label: 'Home', icon: PhosphorIcons.house(), route: AppRoutes.masterDashboard),
          LivelabNavItem(label: 'Unidades', icon: PhosphorIcons.buildings(), route: AppRoutes.masterUnits),
          LivelabNavItem(label: 'Consolidado', icon: PhosphorIcons.chartBar(), route: AppRoutes.masterConsolidated),
          LivelabNavItem(label: 'CRM', icon: PhosphorIcons.shoppingCart(), route: AppRoutes.masterCrm),
        ]),
      ];
    }

    // franqueado / gerente default
    return [
      LivelabNavSection(items: [
        LivelabNavItem(label: 'Home', icon: PhosphorIcons.house(), route: AppRoutes.home),
      ]),
      LivelabNavSection(label: 'Comercial', items: [
        LivelabNavItem(label: 'CRM', icon: PhosphorIcons.shoppingCart(), route: AppRoutes.leads),
        LivelabNavItem(label: 'Clientes', icon: PhosphorIcons.users(), route: AppRoutes.clientes),
      ]),
      LivelabNavSection(label: 'Cabines', items: [
        LivelabNavItem(label: 'Cabines', icon: PhosphorIcons.videoCamera(), route: AppRoutes.cabines, dot: true),
      ]),
      LivelabNavSection(label: 'Pessoas', items: [
        LivelabNavItem(label: 'Apresentadoras', icon: PhosphorIcons.microphone(), route: AppRoutes.apresentadoras),
        LivelabNavItem(label: 'Financeiro', icon: PhosphorIcons.wallet(), route: AppRoutes.financeiro, dot: true),
        LivelabNavItem(label: 'Analytics', icon: PhosphorIcons.chartLine(), route: AppRoutes.analyticsDashboard),
        LivelabNavItem(label: 'Base', icon: PhosphorIcons.book(), route: AppRoutes.manuais),
        LivelabNavItem(label: 'Config', icon: PhosphorIcons.gear(), route: AppRoutes.configuracoes),
      ]),
    ];
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.sections, required this.currentRoute, required this.onLogout});
  final List<LivelabNavSection> sections;
  final String currentRoute;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: t.bgElev1,
        border: Border(right: BorderSide(color: t.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // brand mark
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [t.primary, const Color(0xFFFF8A3C)],
              ),
              boxShadow: [
                BoxShadow(color: t.primary.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'L',
              style: GoogleFonts.instrumentSerif(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final s in sections) ..._section(t, s),
                ],
              ),
            ),
          ),
          _RailItem(
            icon: PhosphorIcons.signOut(),
            label: 'Sair',
            active: false,
            dot: false,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  List<Widget> _section(LlTokens t, LivelabNavSection s) {
    return [
      if (s.label != null)
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 4),
          child: Text(
            s.label!.toUpperCase(),
            style: TextStyle(
              color: t.textFaint,
              fontSize: 9,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      for (final it in s.items)
        Builder(builder: (ctx) {
          return _RailItem(
            icon: it.icon,
            label: it.label,
            active: it.route == _activeMatch(it.route),
            dot: it.dot,
            onTap: () {
              if (ModalRoute.of(ctx)?.settings.name != it.route) {
                Navigator.of(ctx).pushReplacementNamed(it.route);
              }
            },
          );
        }),
    ];
  }

  String _activeMatch(String route) {
    return currentRoute == route ? route : '';
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({required this.icon, required this.label, required this.active, required this.dot, required this.onTap});
  final IconData icon;
  final String label;
  final bool active;
  final bool dot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (active)
            Positioned(
              left: -16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 3,
                  height: 24,
                  decoration: BoxDecoration(
                    color: t.primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          Tooltip(
            message: label,
            waitDuration: const Duration(milliseconds: 600),
            child: Material(
              color: active ? t.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onTap,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          icon,
                          size: 22,
                          color: active ? t.primary : t.textMuted,
                        ),
                      ),
                      if (dot)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: t.danger,
                              shape: BoxShape.circle,
                              border: Border.all(color: t.bgElev1, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Topbar extends StatelessWidget {
  const _Topbar({
    required this.user,
    required this.isDark,
    required this.onToggleTheme,
    required this.onRefresh,
    required this.onBell,
  });

  final dynamic user; // User?
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback? onRefresh;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bom dia' : (hour < 18 ? 'Boa tarde' : 'Boa noite');
    final nome = (user?.nome ?? '').toString();
    final firstName = nome.split(' ').isNotEmpty ? nome.split(' ').first : 'Usuário';
    final papel = (user?.papel ?? '').toString();
    final papelLabel = switch (papel) {
      'franqueador_master' || 'admin_master' => 'Master',
      'franqueado' => 'Franquia',
      'gerente' => 'Gerente',
      'gerente_comercial' => 'Comercial',
      'financeiro' => 'Financeiro',
      'operacional' => 'Operações',
      'cliente_parceiro' => 'Cliente',
      'apresentador' || 'apresentadora' => 'Apresentador',
      _ => 'Livelab',
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
      child: Row(
        children: [
          // greeting block
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [t.primary, const Color(0xFFFF8A3C)],
              ),
              boxShadow: [
                BoxShadow(color: t.primary.withValues(alpha: 0.5), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(nome),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$greeting, ',
                        style: TextStyle(color: t.textPrimary, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4, height: 1.1),
                      ),
                      TextSpan(
                        text: firstName,
                        style: TextStyle(color: t.textSecondary, fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: -0.4, height: 1.1),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: papelLabel,
                        style: GoogleFonts.instrumentSerif(
                          color: t.primary,
                          fontStyle: FontStyle.italic,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.4,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _subDate(),
                  style: TextStyle(color: t.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          _ThemeToggle(isDark: isDark, onTap: onToggleTheme),
          const SizedBox(width: 10),
          if (onRefresh != null)
            _IconButton(icon: PhosphorIcons.arrowsClockwise(), onTap: onRefresh!),
          const SizedBox(width: 10),
          _IconButton(icon: PhosphorIcons.bell(), onTap: onBell, dot: true),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _subDate() {
    const dias = ['Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];
    const meses = ['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'];
    final now = DateTime.now();
    final dia = dias[now.weekday % 7];
    final mes = meses[now.month - 1];
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$dia, ${now.day} de $mes · $hh:$mm';
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.isDark, required this.onTap});
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    return Material(
      color: t.bgElev1,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 96,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: t.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 14,
                child: Icon(Icons.wb_sunny_outlined, size: 16, color: isDark ? t.textMuted : Colors.transparent),
              ),
              Positioned(
                right: 14,
                child: Icon(Icons.nightlight_outlined, size: 16, color: isDark ? Colors.transparent : t.textMuted),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.primary,
                    boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Icon(
                    isDark ? Icons.nightlight_outlined : Icons.wb_sunny_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap, this.dot = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    return Material(
      color: t.bgElev1,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.border),
          ),
          child: Stack(
            children: [
              Center(child: Icon(icon, size: 20, color: t.textSecondary)),
              if (dot)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.primary,
                      border: Border.all(color: t.bgElev1, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.sections, required this.currentRoute});
  final List<LivelabNavSection> sections;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final t = context.llTokens;
    final items = sections.expand((s) => s.items).take(5).toList();
    return Container(
      decoration: BoxDecoration(
        color: t.bgElev1,
        border: Border(top: BorderSide(color: t.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          for (final it in items)
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (ModalRoute.of(context)?.settings.name != it.route) {
                      Navigator.of(context).pushReplacementNamed(it.route);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          it.icon,
                          size: 22,
                          color: it.route == currentRoute ? t.primary : t.textMuted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          it.label.split(' ').first,
                          style: TextStyle(
                            color: it.route == currentRoute ? t.primary : t.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
