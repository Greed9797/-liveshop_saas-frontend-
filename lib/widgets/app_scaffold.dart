import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AppScaffold(
      {super.key, required this.child, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _getSelectedIndex(currentRoute, isDesktop),
                  onDestinationSelected: (idx) =>
                      _navigateToIndex(context, idx, isDesktop),
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme:
                      const IconThemeData(color: AppColors.primary),
                  selectedLabelTextStyle: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                  destinations: const [
                    NavigationRailDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: Text('Home')),
                    NavigationRailDestination(
                        icon: Icon(Icons.videocam_outlined),
                        selectedIcon: Icon(Icons.videocam),
                        label: Text('Cabines')),
                    NavigationRailDestination(
                        icon: Icon(Icons.description_outlined),
                        label: Text('Vendas')),
                    NavigationRailDestination(
                        icon: Icon(Icons.person_search_outlined),
                        label: Text('Leads')),
                    NavigationRailDestination(
                        icon: Icon(Icons.receipt_outlined),
                        label: Text('Boletos')),
                    NavigationRailDestination(
                        icon: Icon(Icons.map_outlined),
                        label: Text('Carteira')),
                    NavigationRailDestination(
                        icon: Icon(Icons.menu_book_outlined),
                        label: Text('Manuais')),
                    NavigationRailDestination(
                        icon: Icon(Icons.star_outline_rounded),
                        label: Text('Recomendações')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }

        // Mobile
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _getSelectedIndex(currentRoute, isDesktop),
            onTap: (idx) => _navigateToIndex(context, idx, isDesktop),
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.videocam_outlined), label: 'Cabines'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.description_outlined), label: 'Vendas'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_search_outlined), label: 'Leads'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_outlined), label: 'Boletos'),
            ],
          ),
        );
      },
    );
  }

  int _getSelectedIndex(String route, bool isDesktop) {
    if (route == AppRoutes.home) return 0;
    if (route.startsWith(AppRoutes.cabines)) return 1;
    if (route.startsWith(AppRoutes.vendas)) return 2;
    if (route == AppRoutes.leads) return 3;
    if (route == AppRoutes.boletos) return 4;

    if (isDesktop) {
      if (route == AppRoutes.carteiraClientes) return 5;
      if (route == AppRoutes.manuais) return 6;
      if (route == AppRoutes.recomendacoes) return 7;
    }

    return 0;
  }

  void _navigateToIndex(BuildContext context, int index, bool isDesktop) {
    String route = AppRoutes.home;

    if (isDesktop) {
      switch (index) {
        case 0:
          route = AppRoutes.home;
          break;
        case 1:
          route = AppRoutes.cabines;
          break;
        case 2:
          route = AppRoutes.vendas;
          break;
        case 3:
          route = AppRoutes.leads;
          break;
        case 4:
          route = AppRoutes.boletos;
          break;
        case 5:
          route = AppRoutes.carteiraClientes;
          break;
        case 6:
          route = AppRoutes.manuais;
          break;
        case 7:
          route = AppRoutes.recomendacoes;
          break;
      }
    } else {
      switch (index) {
        case 0:
          route = AppRoutes.home;
          break;
        case 1:
          route = AppRoutes.cabines;
          break;
        case 2:
          route = AppRoutes.vendas;
          break;
        case 3:
          route = AppRoutes.leads;
          break;
        case 4:
          route = AppRoutes.boletos;
          break;
      }
    }

    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}
