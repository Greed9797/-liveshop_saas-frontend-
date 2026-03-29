import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cabine_card.dart';
import '../../widgets/action_button.dart';
import '../../providers/cabines_provider.dart';
import '../../providers/clientes_provider.dart';
import '../../models/cabine.dart';
import '../../models/cliente.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Tela expandida de gerenciamento de cabines
class CabinesScreen extends ConsumerWidget {
  const CabinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinesAsync = ref.watch(cabinesProvider);

    return AppScaffold(
      currentRoute: AppRoutes.cabines,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gerenciamento de Cabines',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(cabinesProvider.notifier).refresh(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: cabinesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('Erro: $e'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(cabinesProvider.notifier).refresh(),
                      child: const Text('Tentar novamente'),
                    ),
                  ]),
                ),
                data: (cabines) => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: cabines.length,
                  itemBuilder: (_, i) => _CabineExpandedCard(cabine: cabines[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card expandido de cabine com botões de ação
class _CabineExpandedCard extends ConsumerWidget {
  final Cabine cabine;
  const _CabineExpandedCard({required this.cabine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLive = cabine.status == 'ao_vivo';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CabineCard(cabine: cabine.toCardMap()),
            const Spacer(),
            if (isLive)
              ActionButton(
                label: 'ENCERRAR',
                outlined: true,
                color: AppColors.danger,
                onPressed: () => _showEncerrarDialog(context, ref),
              )
            else if (cabine.status == 'disponivel')
              ActionButton(
                label: 'INICIAR LIVE',
                icon: Icons.play_arrow,
                onPressed: () => _showIniciarDialog(context, ref),
              )
            else
              ActionButton(
                label: 'MANUTENÇÃO',
                outlined: true,
                color: Colors.grey,
                onPressed: null,
              ),
          ],
        ),
      ),
    );
  }

  void _showEncerrarDialog(BuildContext context, WidgetRef ref) {
    final fatCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Encerrar Live'),
        content: TextField(
          controller: fatCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Faturamento gerado (R\$)',
            prefixText: 'R\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              final fat = double.tryParse(fatCtrl.text.replaceAll(',', '.')) ?? 0;
              Navigator.pop(context);
              try {
                await ref.read(cabinesProvider.notifier)
                    .encerrarLive(cabine.liveAtualId!, fat);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao encerrar: $e')),
                  );
                }
              }
            },
            child: const Text('ENCERRAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showIniciarDialog(BuildContext context, WidgetRef ref) {
    final clientes = ref.read(clientesProvider).valueOrNull ?? [];
    Cliente? clienteSelecionado;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Iniciar Live — Cabine ${cabine.numero}'),
          content: clientes.isEmpty
              ? const Text('Nenhum cliente ativo disponível.')
              : DropdownButtonFormField<Cliente>(
                  value: clienteSelecionado,
                  hint: const Text('Selecionar cliente'),
                  items: clientes
                      .where((c) => c.status == 'ativo')
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.nome),
                          ))
                      .toList(),
                  onChanged: (c) => setState(() => clienteSelecionado = c),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: clienteSelecionado == null
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      try {
                        await ref.read(cabinesProvider.notifier).iniciarLive(
                          cabineId: cabine.id,
                          clienteId: clienteSelecionado!.id,
                          apresentadorId: clienteSelecionado!.id,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao iniciar: $e')),
                          );
                        }
                      }
                    },
              child: const Text('INICIAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
