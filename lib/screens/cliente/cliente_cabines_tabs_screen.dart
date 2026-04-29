import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../design_system/app_colors.dart' as ds_colors;
import '../../design_system/app_colors_theme.dart';
import '../../design_system/app_tokens.dart' as ds_tokens;
import '../../design_system/app_typography.dart' as ds_typography;
import '../../routes/app_routes.dart';
import '../../widgets/app_scaffold.dart';
import 'cliente_agenda_screen.dart';
import 'cliente_lives_screen.dart';
import 'cliente_reservas_screen.dart';

class ClienteCabinesTabsScreen extends ConsumerStatefulWidget {
  const ClienteCabinesTabsScreen({super.key});

  @override
  ConsumerState<ClienteCabinesTabsScreen> createState() =>
      _ClienteCabinesTabsScreenState();
}

class _ClienteCabinesTabsScreenState
    extends ConsumerState<ClienteCabinesTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.colors;

    return AppScaffold(
      currentRoute: AppRoutes.clienteCabinesTabs,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  ds_tokens.AppSpacing.x6,
                  ds_tokens.AppSpacing.x6,
                  ds_tokens.AppSpacing.x6,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CABINES',
                      style: ds_typography.AppTypography.caption.copyWith(
                        color: t.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Minhas Lives',
                      style: ds_typography.AppTypography.h2.copyWith(
                        color: t.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // TabBar
              TabBar(
                controller: _tab,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: ds_colors.AppColors.primary,
                unselectedLabelColor: t.textSecondary,
                indicatorColor: ds_colors.AppColors.primary,
                indicatorWeight: 2,
                padding: const EdgeInsets.symmetric(
                    horizontal: ds_tokens.AppSpacing.x6),
                tabs: [
                  Tab(
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.videoCamera(), size: 16),
                        const SizedBox(width: 6),
                        const Text('Lives'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.calendarBlank(), size: 16),
                        const SizedBox(width: 6),
                        const Text('Agenda'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.plusCircle(), size: 16),
                        const SizedBox(width: 6),
                        const Text('Solicitar'),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: const [
                    ClienteLivesBody(),
                    ClienteReservasBody(),
                    ClienteAgendaBody(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
