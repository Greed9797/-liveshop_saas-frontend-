import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/tenant.dart';
import '../../providers/tenants_provider.dart';
import '../../services/api_service.dart';
import '../../design_system/design_system.dart';
import '../../widgets/app_scaffold.dart';
import '../../routes/app_routes.dart';
import 'criar_franquia_dialog.dart';

class MasterFranqueadosScreen extends ConsumerWidget {
  const MasterFranqueadosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTenants = ref.watch(tenantsProvider);

    return AppScaffold(
      currentRoute: AppRoutes.masterFranqueados,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          Expanded(
            child: asyncTenants.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.danger, size: 48),
                    const SizedBox(height: AppSpacing.x3),
                    Text(ApiService.extractErrorMessage(e),
                        style:
                            TextStyle(color: AppColors.danger)),
                    const SizedBox(height: AppSpacing.x3),
                    TextButton(
                      onPressed: () =>
                          ref.refresh(tenantsProvider),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              data: (tenants) {
                if (tenants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(PhosphorIcons.buildings(),
                            size: 48, color: AppColors.textMuted),
                        const SizedBox(height: AppSpacing.x3),
                        Text(
                          'Nenhuma franquia cadastrada ainda.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        Builder(
                          builder: (ctx) => FilledButton.icon(
                            onPressed: () => _abrirDialog(ctx),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Nova Franquia'),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.x4),
                  itemCount: tenants.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.x2),
                  itemBuilder: (_, i) =>
                      _FranquiaCard(tenant: tenants[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _abrirDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const CriarFranquiaDialog(),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x6, AppSpacing.x6, AppSpacing.x6, AppSpacing.x4),
      color: AppColors.bgCard,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Franquias', style: AppTypography.h2),
                Text(
                  'Gerencie todas as unidades da rede Livelab.',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Builder(
            builder: (ctx) => FilledButton.icon(
              onPressed: () => showDialog<void>(
                context: ctx,
                builder: (_) => const CriarFranquiaDialog(),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nova Franquia'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FranquiaCard extends ConsumerWidget {
  const _FranquiaCard({required this.tenant});
  final Tenant tenant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: AppRadius.lgR,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.mdR,
            ),
            child: Center(
              child: Text(
                tenant.nome.isNotEmpty
                    ? tenant.nome[0].toUpperCase()
                    : 'F',
                style: AppTypography.h3
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenant.nome,
                  style: AppTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                if (tenant.ownerEmail != null)
                  Text(
                    tenant.ownerEmail!,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          _StatusChip(ativo: tenant.ativo),
          const SizedBox(width: AppSpacing.x2),
          _AcoesFranquia(tenant: tenant),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.ativo});
  final bool ativo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2, vertical: AppSpacing.x1),
      decoration: BoxDecoration(
        color: ativo ? AppColors.successBg : AppColors.dangerBg,
        borderRadius: AppRadius.fullR,
      ),
      child: Text(
        ativo ? 'Ativa' : 'Inativa',
        style: AppTypography.caption.copyWith(
          color: ativo ? AppColors.success : AppColors.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AcoesFranquia extends ConsumerWidget {
  const _AcoesFranquia({required this.tenant});
  final Tenant tenant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
      onSelected: (v) => _handle(context, ref, v),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: tenant.ativo ? 'desativar' : 'ativar',
          child: Row(children: [
            Icon(
              tenant.ativo
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(tenant.ativo ? 'Desativar franquia' : 'Ativar franquia'),
          ]),
        ),
      ],
    );
  }

  Future<void> _handle(
      BuildContext context, WidgetRef ref, String acao) async {
    try {
      await ref
          .read(tenantsProvider.notifier)
          .alternarStatus(tenant.id, acao == 'ativar');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          acao == 'ativar'
              ? 'Franquia ativada'
              : 'Franquia desativada (usuários revogados)',
        ),
      ));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractErrorMessage(e)),
        backgroundColor: AppColors.danger,
      ));
    }
  }
}
