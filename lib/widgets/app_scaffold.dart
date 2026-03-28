import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Layout base: drawer fixo à esquerda + área de conteúdo à direita
/// Otimizado para iPad landscape (1024x768+)
class AppScaffold extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _SideMenu(currentRoute: currentRoute),
          const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SideMenu extends StatelessWidget {
  final String currentRoute;
  const _SideMenu({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _MenuItem(icon: Icons.home_rounded,           label: 'HOME',                route: AppRoutes.home),
      const _MenuItem(icon: Icons.description_outlined,   label: 'Vendas em Andamento', route: AppRoutes.vendas),
      const _MenuItem(icon: Icons.map_outlined,           label: 'Carteira de Clientes',route: AppRoutes.vendas),
      _MenuItem(icon: Icons.emoji_events_outlined,        label: 'Reconhecimentos',     route: null, onTap: () => _showEmBreve(context)),
      const _MenuItem(icon: Icons.receipt_outlined,       label: 'Meus Boletos',        route: AppRoutes.boletos),
      const _MenuItem(icon: Icons.person_search_outlined, label: 'Leads',               route: AppRoutes.leads),
      const _MenuItem(icon: Icons.menu_book_outlined,     label: 'Manuais',             route: AppRoutes.manuais),
      const _MenuItem(icon: Icons.star_outline_rounded,   label: 'Recomendações',       route: AppRoutes.recomendacoes),
    ];

    return Container(
      width: 200,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.primary,
            alignment: Alignment.centerLeft,
            child: const Text(
              'LiveShop',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: items.map((item) => _MenuTile(
                item: item,
                isSelected: item.route == currentRoute,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmBreve(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Em Breve'),
        content: const Text('Novidades chegando! Fique atento às atualizações.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? route;
  final VoidCallback? onTap;
  const _MenuItem({required this.icon, required this.label, this.route, this.onTap});
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  final bool isSelected;
  const _MenuTile({required this.item, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(
        item.icon,
        color: isSelected ? AppColors.primary : Colors.grey[600],
        size: 20,
      ),
      title: Text(
        item.label,
        style: TextStyle(
          fontSize: 13,
          color: isSelected ? AppColors.primary : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
      tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      onTap: item.onTap ?? () {
        if (item.route != null) {
          Navigator.pushReplacementNamed(context, item.route!);
        }
      },
    );
  }
}
