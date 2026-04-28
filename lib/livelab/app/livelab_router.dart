import 'package:go_router/go_router.dart';
import '../features/cabines/cabines_repository.dart';
import '../features/cabines/cabines_screen.dart';
import '../features/home/home_repository.dart';
import '../features/home/home_screen.dart';
import 'livelab_shell.dart';

/// GoRouter setup for the Livelab feature pack.
/// Plug into your existing router tree, or use as the app's root router.
class LivelabRouter {
  LivelabRouter({CabinesRepository? cabines, HomeRepository? home})
      : cabinesRepo = cabines ?? MockCabinesRepository(),
        homeRepo = home ?? MockHomeRepository();

  final CabinesRepository cabinesRepo;
  final HomeRepository homeRepo;

  GoRouter build() {
    return GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (c, state, child) => LivelabShell(
            currentPath: state.uri.path,
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/home',
              builder: (c, s) => HomeScreen(repository: homeRepo),
            ),
            GoRoute(
              path: '/cabines',
              builder: (c, s) => CabinesScreen(repository: cabinesRepo),
            ),
            // Other routes (Solicitações, Financeiro, Analytics) go here.
          ],
        ),
      ],
    );
  }
}
