import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/lead_card.dart';
import '../../providers/leads_provider.dart';
import '../../routes/app_routes.dart';

/// Painel de leads disponíveis da franqueadora
class LeadsScreen extends ConsumerWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadsProvider);

    return AppScaffold(
      currentRoute: AppRoutes.leads,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Leads Disponíveis',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(leadsProvider.notifier).refresh(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            leadsAsync.when(
              loading: () => const Text('Carregando...', style: TextStyle(color: Colors.grey)),
              error: (_, __) => const Text('Erro ao carregar leads', style: TextStyle(color: Colors.grey)),
              data: (leads) => Text('${leads.length} leads disponíveis para você',
                  style: const TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: leadsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('Erro: $e'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(leadsProvider.notifier).refresh(),
                      child: const Text('Tentar novamente'),
                    ),
                  ]),
                ),
                data: (leads) => leads.isEmpty
                    ? const Center(
                        child: Text('Nenhum lead disponível no momento.',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
                        itemCount: leads.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final lead = leads[i];
                          return LeadCard(
                            lead: {
                              'id':           lead.id,
                              'nome':         lead.nome,
                              'nicho':        lead.nicho ?? '',
                              'cidade':       lead.cidade ?? '',
                              'fat_estimado': lead.fatEstimado,
                              'status':       lead.status,
                              'novo':         lead.isNovo,
                              'expira_em':    lead.expiraEm?.toIso8601String(),
                            },
                            onPegar: lead.status == 'disponivel'
                                ? () => ref.read(leadsProvider.notifier).pegar(lead.id)
                                : null,
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
}
