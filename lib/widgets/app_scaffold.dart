import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final String? userName;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
    this.userName = 'FVC PROMOCOES DE VENDAS LTDA',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LIVESHOP', // Logo placeholder
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Faixa Amarela de Saudação (Estilo Referência)
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oi, $userName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Franqueado LiveShop',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Área de Conteúdo
          Expanded(
            child: Row(
              children: [
                // No iPad Landscape da referência, o menu é persistente ou um Drawer largo
                // Vou manter o LayoutBuilder para suportar Desktop/Tablet com menu fixo
                LayoutBuilder(builder: (context, constraints) {
                  if (MediaQuery.of(context).size.width >= 1000) {
                    return _buildPermanentMenu(context);
                  }
                  return const SizedBox.shrink();
                }),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: _MenuContent(currentRoute: currentRoute),
    );
  }

  Widget _buildPermanentMenu(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.black12)),
      ),
      child: _MenuContent(currentRoute: currentRoute),
    );
  }
}

class _MenuContent extends StatelessWidget {
  final String currentRoute;
  const _MenuContent({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _MenuItem(
            icon: Icons.home_rounded,
            label: 'HOME',
            route: AppRoutes.home,
            isSelected: currentRoute == AppRoutes.home),
        _MenuItem(
            icon: Icons.description_outlined,
            label: 'VENDAS EM ANDAMENTO',
            route: AppRoutes.vendas,
            isSelected: currentRoute == AppRoutes.vendas),
        _MenuItem(
            icon: Icons.analytics_outlined,
            label: 'ANÁLISE DE VENDAS',
            route: AppRoutes.analise,
            isSelected: currentRoute == AppRoutes.analise),
        const _MenuItem(
            icon: Icons.emoji_events_outlined,
            label: 'RECONHECIMENTOS',
            route: null,
            isSelected: false),
        _MenuItem(
            icon: Icons.receipt_outlined,
            label: 'MEUS BOLETOS',
            route: AppRoutes.boletos,
            isSelected: currentRoute == AppRoutes.boletos,
            badge: '1'),
        _MenuItem(
            icon: Icons.person_search_outlined,
            label: 'LEADS',
            route: AppRoutes.leads,
            isSelected: currentRoute == AppRoutes.leads),
        _MenuItem(
            icon: Icons.menu_book_outlined,
            label: 'MANUAIS',
            route: AppRoutes.manuais,
            isSelected: currentRoute == AppRoutes.manuais),
        _MenuItem(
            icon: Icons.group_outlined,
            label: 'RECOMENDAÇÕES',
            route: AppRoutes.recomendacoes,
            isSelected: currentRoute == AppRoutes.recomendacoes),
        const Spacer(),
        const _MenuItem(
            icon: Icons.logout,
            label: 'Sair',
            route: AppRoutes.login,
            isSelected: false),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? route;
  final bool isSelected;
  final String? badge;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.route,
    required this.isSelected,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.black : Colors.black54),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.black : Colors.black54,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: AppColors.danger, shape: BoxShape.circle),
              child: Text(badge!,
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
            )
          : null,
      onTap: () {
        if (route != null) Navigator.pushReplacementNamed(context, route!);
      },
    );
  }
}
