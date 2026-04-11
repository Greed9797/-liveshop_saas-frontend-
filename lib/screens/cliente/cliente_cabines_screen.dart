import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/cabine.dart';
import '../../providers/cliente_cabines_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cabine_card.dart';

class ClienteCabinesScreen extends ConsumerWidget {
  const ClienteCabinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinesAsync = ref.watch(clienteCabinesProvider);

    return AppScaffold(
      currentRoute: AppRoutes.clienteCabines,
      child: cabinesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.dangerRed),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Erro ao carregar cabines:\n$error',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                  onPressed: () =>
                      ref.read(clienteCabinesProvider.notifier).refresh(),
                ),
              ],
            ),
          ),
        ),
        data: (cabines) => _CabinesContent(cabines: cabines),
      ),
    );
  }
}

class _CabinesContent extends StatelessWidget {
  final List<Cabine> cabines;

  const _CabinesContent({required this.cabines});

  @override
  Widget build(BuildContext context) {
    if (cabines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined,
                size: 64, color: AppColors.gray300),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nenhuma cabine vinculada',
              style: AppTypography.h3.copyWith(color: AppColors.gray500),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Suas cabines aparecerão aqui assim que\nhouver um contrato ativo.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.gray400),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 600
                ? 3
                : 2;

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: AppSpacing.cardGap,
            mainAxisSpacing: AppSpacing.cardGap,
            childAspectRatio: 0.78,
          ),
          itemCount: cabines.length,
          itemBuilder: (ctx, i) => CabineCard(
            cabine: cabines[i],
            onTap: () => Navigator.pushNamed(
              ctx,
              AppRoutes.clienteCabineDetail,
              arguments: cabines[i],
            ),
          ),
        );
      },
    );
  }
}
