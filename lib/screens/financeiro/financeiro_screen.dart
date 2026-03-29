import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/roleta_widget.dart';
import '../../widgets/metric_card.dart';
import '../../providers/financeiro_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Controle financeiro com 3 abas
class FinanceiroScreen extends ConsumerWidget {
  const FinanceiroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      currentRoute: AppRoutes.financeiro,
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Operacional'),
                  Tab(text: 'Faturamento Detalhado'),
                  Tab(text: 'Roleta do Franqueado'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _OperacionalTab(),
                  _FaturamentoTab(),
                  _RoletaTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperacionalTab extends ConsumerWidget {
  const _OperacionalTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeiroAsync = ref.watch(financeiroProvider);

    return financeiroAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Erro: $e'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => ref.read(financeiroProvider.notifier).carregarPeriodo(
              DateTime.now().month, DateTime.now().year),
            child: const Text('Tentar novamente'),
          ),
        ]),
      ),
      data: (resumo) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Controle Operacional',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                Text(resumo.periodo,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: [
                SizedBox(width: 200, child: MetricCard(
                  label: 'CUSTOS OPERACIONAIS',
                  value: 'R\$ ${resumo.totalCustos.toStringAsFixed(2).replaceAll('.', ',')}',
                  icon: Icons.remove_circle_outline,
                  iconColor: AppColors.danger,
                )),
                SizedBox(width: 200, child: MetricCard(
                  label: 'FATURAMENTO BRUTO',
                  value: 'R\$ ${resumo.fatBruto.toStringAsFixed(2).replaceAll('.', ',')}',
                  icon: Icons.swap_horiz,
                  iconColor: AppColors.info,
                )),
                SizedBox(width: 200, child: MetricCard(
                  label: 'FAT LÍQUIDO',
                  value: 'R\$ ${resumo.fatLiquido.toStringAsFixed(2).replaceAll('.', ',')}',
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.success,
                )),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Custos', style: TextStyle(fontWeight: FontWeight.w500)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Adicionar'),
                  onPressed: () => _showAdicionarCusto(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAdicionarCusto(BuildContext context, WidgetRef ref) {
    final descCtrl = TextEditingController();
    final valorCtrl = TextEditingController();
    String tipo = 'fixo';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Adicionar Custo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valorCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixText: 'R\$ '),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'fixo', child: Text('Fixo')),
                  DropdownMenuItem(value: 'variavel', child: Text('Variável')),
                ],
                onChanged: (v) => setState(() => tipo = v ?? 'fixo'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (descCtrl.text.isEmpty || valorCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  await ref.read(financeiroProvider.notifier).adicionarCusto({
                    'descricao': descCtrl.text,
                    'valor': double.parse(valorCtrl.text.replaceAll(',', '.')),
                    'tipo': tipo,
                    'competencia': '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
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
      ),
    );
  }
}

class _FaturamentoTab extends ConsumerWidget {
  const _FaturamentoTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeiroAsync = ref.watch(financeiroProvider);

    return financeiroAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Erro ao carregar')),
      data: (resumo) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Faturamento Detalhado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: [
                SizedBox(width: 200, child: MetricCard(
                  label: 'FAT BRUTO',
                  value: 'R\$ ${resumo.fatBruto.toStringAsFixed(2).replaceAll('.', ',')}',
                  icon: Icons.person_outline,
                  subtitle: 'período: ${resumo.periodo}',
                )),
                SizedBox(width: 200, child: MetricCard(
                  label: 'FAT LÍQUIDO',
                  value: 'R\$ ${resumo.fatLiquido.toStringAsFixed(2).replaceAll('.', ',')}',
                  icon: Icons.percent,
                  iconColor: AppColors.primary,
                  subtitle: 'após custos',
                )),
                SizedBox(width: 200, child: MetricCard(
                  label: 'TOTAL CUSTOS',
                  value: 'R\$ ${resumo.totalCustos.toStringAsFixed(2).replaceAll('.', ',')}',
                  icon: Icons.inventory_2_outlined,
                  iconColor: AppColors.danger,
                  subtitle: 'no período',
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoletaTab extends ConsumerWidget {
  const _RoletaTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeiroAsync = ref.watch(financeiroProvider);

    return financeiroAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Erro ao carregar')),
      data: (resumo) => Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2860),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ROLETA DO FRANQUEADO',
                  style: TextStyle(color: AppColors.lilac, fontSize: 13, letterSpacing: 1)),
              const SizedBox(height: 32),
              RoletaWidget(value: resumo.fatBruto,   label: 'FAT BRUTO',   fontSize: 36),
              const SizedBox(height: 24),
              RoletaWidget(value: resumo.fatLiquido, label: 'FAT LÍQUIDO', fontSize: 28),
              const SizedBox(height: 24),
              RoletaWidget(value: resumo.totalCustos, label: 'TOTAL CUSTOS', fontSize: 22),
            ],
          ),
        ),
      ),
    );
  }
}
