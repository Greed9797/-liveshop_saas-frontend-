import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import '../theme/livelab_theme.dart';
import '../core/responsive.dart';
import '../widgets/ll_sidebar.dart';
import '../theme/theme_controller.dart';

class LivelabShell extends StatelessWidget {
  const LivelabShell({super.key, required this.child, required this.currentPath});
  final Widget child;
  final String currentPath;

  static const _items = [
    LlNavItem(label: 'Visão geral', icon: Icons.dashboard_outlined, path: '/home'),
    LlNavItem(label: 'Cabines', icon: Icons.videocam_outlined, path: '/cabines'),
    LlNavItem(label: 'Solicitações', icon: Icons.assignment_outlined, path: '/requests'),
    LlNavItem(label: 'Financeiro', icon: Icons.payments_outlined, path: '/finance'),
    LlNavItem(label: 'Analytics', icon: Icons.bar_chart, path: '/analytics'),
  ];

  @override
  Widget build(BuildContext context) {
    final r = LlResponsive.of(context);
    final t = context.llTokens;
    final mobile = r.isMobile;

    return Scaffold(
      backgroundColor: t.bgBase,
      body: SafeArea(
        child: mobile
            ? Column(children: [Expanded(child: child), _bottomNav(context, t)])
            : Row(
                children: [
                  LlSidebar(
                    items: _items,
                    currentPath: currentPath,
                    onSelect: (p) => context.go(p),
                  ),
                  Expanded(child: child),
                ],
              ),
      ),
    );
  }

  Widget _bottomNav(BuildContext context, LlTokens t) {
    final theme = LlThemeScope.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.bgElev1,
        border: Border(top: BorderSide(color: t.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          for (final it in _items.take(4))
            Expanded(
              child: Material(
                color: it.path == currentPath ? t.primarySoft : Colors.transparent,
                borderRadius: BorderRadius.circular(LlRadius.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(LlRadius.md),
                  onTap: () => context.go(it.path),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(it.icon, size: 20, color: it.path == currentPath ? t.primary : t.textMuted),
                        const SizedBox(height: 4),
                        Text(
                          it.label.split(' ').first,
                          style: TextStyle(
                            color: it.path == currentPath ? t.primary : t.textMuted,
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
          IconButton(
            onPressed: theme.toggle,
            icon: Icon(theme.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, size: 20),
            color: t.textMuted,
          ),
        ],
      ),
    );
  }
}
