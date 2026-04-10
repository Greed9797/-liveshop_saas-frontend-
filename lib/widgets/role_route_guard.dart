import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';

class RoleRouteGuard extends ConsumerStatefulWidget {
  final Set<String> allowedRoles;
  final Widget child;
  final String fallbackRoute;
  final String unauthenticatedRoute;

  const RoleRouteGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    required this.fallbackRoute,
    required this.unauthenticatedRoute,
  });

  @override
  ConsumerState<RoleRouteGuard> createState() => _RoleRouteGuardState();
}

class _RoleRouteGuardState extends ConsumerState<RoleRouteGuard> {
  bool _redirectScheduled = false;

  void _scheduleRedirect(String route) {
    if (_redirectScheduled) return;
    _redirectScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = authState.user;

    if (user == null) {
      // Não redireciona aqui — o listener em main.dart cuida do
      // pushNamedAndRemoveUntil para evitar tela dupla de login.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!widget.allowedRoles.contains(user.papel)) {
      final roleRoute = AppRoutes.routeForRole(user.papel);
      _scheduleRedirect(roleRoute);
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return widget.child;
  }
}
