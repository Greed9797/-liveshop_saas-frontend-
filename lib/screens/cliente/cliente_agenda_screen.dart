import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../design_system/app_colors_theme.dart';
import '../../design_system/app_screen_scaffold.dart';
import '../../design_system/app_tokens.dart' as ds_tokens;
import '../../design_system/app_typography.dart' as ds_typography;
import '../../routes/app_routes.dart';

class ClienteAgendaScreen extends ConsumerWidget {
  const ClienteAgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScreenScaffold(
      currentRoute: AppRoutes.clienteAgenda,
      eyebrow: 'AGENDA',
      title: 'Minha Agenda',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(ds_tokens.AppSpacing.x8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.calendarBlank(),
                size: 64,
                color: context.colors.textMuted,
              ),
              const SizedBox(height: ds_tokens.AppSpacing.x4),
              Text(
                'Agenda em breve',
                style: ds_typography.AppTypography.h3.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: ds_tokens.AppSpacing.x2),
              Text(
                'Aqui você poderá visualizar e solicitar lives',
                style: ds_typography.AppTypography.bodyMedium.copyWith(
                  color: context.colors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
