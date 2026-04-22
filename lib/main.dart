import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_mode_provider.dart';
import 'design_system/design_system.dart';
import 'routes/app_navigator.dart';
import 'routes/app_routes.dart';
import 'services/api_service.dart';
import 'config/e2e_bootstrap.dart';

const bool isE2ETesting = bool.fromEnvironment(
  'E2E_TESTING',
  defaultValue: false,
);

const String e2eRole = String.fromEnvironment(
  'E2E_ROLE',
  defaultValue: 'franqueador_master',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await ApiService.init();

  final container = ProviderContainer();

  ApiService.setUnauthorizedHandler(() async {
    await container.read(authProvider.notifier).expireSession();
  });

  await container.read(authProvider.notifier).restoreSession();

  if (isE2ETesting) {
    WidgetsBinding.instance.ensureSemantics();
    await bootstrapE2EAuth(container, role: e2eRole);
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const LiveShopApp(),
  ));
}

class LiveShopApp extends ConsumerWidget {
  const LiveShopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (_) => false,
        );
      }
    });

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Livelab SaaS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      initialRoute: authState.isAuthenticated
          ? AppRoutes.routeForRole(authState.user?.papel)
          : AppRoutes.login,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
