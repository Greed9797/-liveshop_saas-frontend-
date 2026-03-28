import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/metric_card.dart';
import '../../mock/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Painel master do franqueador — visão de todas as unidades
class FranqueadoScreen extends StatelessWidget {
  const FranqueadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ativas = mockFranqueados.where((f) => f['status'] == 'ativo').length;

    return AppScaffold(
      currentRoute: AppRoutes.franqueado,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Painel do Franqueador',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            const Text('Visão geral de todas as unidades',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: MetricCard(
                  label: 'UNIDADES ATIVAS',
                  value: '$ativas',
                  icon: Icons.store_outlined,
                  iconColor: AppColors.success,
                )),
                const SizedBox(width: 12),
                const Expanded(
                    child: MetricCard(
                  label: 'FAT. CONSOLIDADO',
                  value: 'R\$ 89.320,00',
                  icon: Icons.attach_money,
                  iconColor: AppColors.primary,
                )),
                const SizedBox(width: 12),
                const Expanded(
                    child: MetricCard(
                  label: 'CONTRATOS PENDENTES',
                  value: '3',
                  icon: Icons.pending_outlined,
                  iconColor: AppColors.warning,
                )),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Unidades Franqueadas',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: mockFranqueados.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final f = mockFranqueados[i];
                  return ListTile(
                    title: Text(f['nome'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                        'Clientes: ${f['clientes']} • Fat: R\$ ${(f['fat'] as double).toStringAsFixed(0)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge(status: f['status'] as String),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Ver detalhes'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
