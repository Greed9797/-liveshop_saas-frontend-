import 'package:flutter/material.dart';
import '../theme/livelab_theme.dart';
import '../theme/theme_controller.dart';
import 'livelab_router.dart';

/// Standalone runnable. If you're embedding inside an existing MaterialApp,
/// import LivelabRouter().build() and use ShellRoute / nest manually instead.
class LivelabApp extends StatefulWidget {
  const LivelabApp({super.key});

  @override
  State<LivelabApp> createState() => _LivelabAppState();
}

class _LivelabAppState extends State<LivelabApp> {
  final _theme = LlThemeController(initial: ThemeMode.dark);
  late final _router = LivelabRouter().build();

  @override
  Widget build(BuildContext context) {
    return LlThemeScope(
      notifier: _theme,
      child: AnimatedBuilder(
        animation: _theme,
        builder: (c, _) => MaterialApp.router(
          title: 'Livelab',
          debugShowCheckedModeBanner: false,
          theme: LivelabTheme.light(),
          darkTheme: LivelabTheme.dark(),
          themeMode: _theme.mode,
          routerConfig: _router,
        ),
      ),
    );
  }
}
