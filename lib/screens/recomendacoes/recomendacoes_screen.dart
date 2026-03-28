import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/action_button.dart';
import '../../mock/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Painel de recomendações com símbolo lilás
class RecomendacoesScreen extends StatefulWidget {
  const RecomendacoesScreen({super.key});
  @override
  State<RecomendacoesScreen> createState() => _RecomendacoesScreenState();
}

class _RecomendacoesScreenState extends State<RecomendacoesScreen> {
  late List<Map<String, dynamic>> _recomendacoes;

  @override
  void initState() {
    super.initState();
    _recomendacoes = List<Map<String, dynamic>>.from(
      mockRecomendacoes.map((r) => Map<String, dynamic>.from(r as Map)),
    );
  }

  void _showAddDialog() {
    final indicadoCtrl    = TextEditingController();
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
            onPressed: () {
              if (indicadoCtrl.text.isNotEmpty) {
                setState(() => _recomendacoes.add({
                  'indicado':     indicadoCtrl.text,
                  'recomendante': recomendanteCtrl.text,
                }));
              }
              Navigator.pop(context);
            },
            child: const Text('SALVAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: _showAddDialog,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _recomendacoes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final r = _recomendacoes[i];
                  return ListTile(
                    leading: const Icon(Icons.diamond_outlined, color: AppColors.lilac),
                    title: Text(r['indicado'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('Indicado por: ${r['recomendante']}'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
