import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/action_button.dart';
import '../../providers/recomendacoes_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

/// Painel de recomendações com símbolo lilás
class RecomendacoesScreen extends ConsumerWidget {
  const RecomendacoesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recomendacoesProvider);

    return AppScaffold(
      currentRoute: AppRoutes.recomendacoes,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recomendações',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                ActionButton(
                  label: 'ADICIONAR',
                  icon: Icons.add,
                  color: AppColors.lilac,
                  onPressed: () => _showAddDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: recsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('Erro: $e'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(recomendacoesProvider.notifier).refresh(),
                      child: const Text('Tentar novamente'),
                    ),
                  ]),
                ),
                data: (recs) => recs.isEmpty
                    ? const Center(
                        child: Text('Nenhuma recomendação ainda.',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
                        itemCount: recs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final r = recs[i];
                          return ListTile(
                            leading: const Icon(Icons.diamond_outlined, color: AppColors.lilac),
                            title: Text(r.nomeIndicado,
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text('Indicado por: ${r.recomendante}'),
                            trailing: r.status == 'pendente'
                                ? TextButton(
                                    onPressed: () => _converter(context, ref, r.id),
                                    child: const Text('INICIAR NEGOCIAÇÃO',
                                        style: TextStyle(fontSize: 11)),
                                  )
                                : Chip(
                                    label: Text(r.status.toUpperCase(),
                                        style: const TextStyle(fontSize: 10)),
                                    backgroundColor: r.status == 'convertido'
                                        ? AppColors.success.withValues(alpha: 0.15)
                                        : Colors.grey.shade200,
                                    labelStyle: TextStyle(
                                      color: r.status == 'convertido'
                                          ? AppColors.success
                                          : Colors.grey,
                                    ),
                                  ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final indicadoCtrl = TextEditingController();
    final recomendanteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Adicionar Recomendação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: indicadoCtrl,
              decoration: const InputDecoration(labelText: 'Nome do Potencial Cliente'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: recomendanteCtrl,
              decoration: const InputDecoration(labelText: 'Quem está recomendando'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              if (indicadoCtrl.text.isEmpty) return;
              Navigator.pop(context);
              try {
                await ref.read(recomendacoesProvider.notifier).criar({
                  'nome_indicado': indicadoCtrl.text,
                  'recomendante': recomendanteCtrl.text,
                });
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao salvar: $e')),
                  );
                }
              }
            },
            child: const Text('SALVAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _converter(BuildContext context, WidgetRef ref, String id) async {
    try {
      final clienteId = await ref.read(recomendacoesProvider.notifier).converter(id);
      if (context.mounted) {
        Navigator.pushNamed(context, AppRoutes.cadastroCliente,
            arguments: {'clienteId': clienteId});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao converter: $e')),
        );
      }
    }
  }
}
