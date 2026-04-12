import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/action_button.dart';
import '../../providers/manuais_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme.dart';

/// Lista de manuais e documentos da franqueadora
class ManuaisScreen extends ConsumerWidget {
  const ManuaisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manuaisAsync = ref.watch(manuaisProvider);

    return AppScaffold(
      currentRoute: AppRoutes.manuais,
      child: RefreshIndicator(
        onRefresh: () => ref.read(manuaisProvider.notifier).refresh(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manuais e Documentos',
                  style: AppTypography.h2.copyWith(fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: manuaisAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('Erro: $e'),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () => ref.read(manuaisProvider.notifier).refresh(),
                        child: const Text('Tentar novamente'),
                      ),
                    ]),
                  ),
                  data: (manuais) => manuais.isEmpty
                      ? Center(
                          child: Text('Nenhum documento disponível.',
                              style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary)))
                      : ListView.separated(
                          itemCount: manuais.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final m = manuais[i];
                            final atualStr =
                                '${m.atualizadoEm.day.toString().padLeft(2, '0')}/${m.atualizadoEm.month.toString().padLeft(2, '0')}/${m.atualizadoEm.year}';
                            return ListTile(
                              leading: Icon(Icons.picture_as_pdf,
                                  color: context.colors.error, size: 28),
                              title: Text(m.titulo,
                                  style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text('Atualizado em: $atualStr'),
                              trailing: ActionButton(
                                label: 'VER',
                                icon: Icons.open_in_new,
                                outlined: true,
                                onPressed: () async {
                                  final uri = Uri.tryParse(m.url);
                                  if (uri != null && await canLaunchUrl(uri)) {
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
