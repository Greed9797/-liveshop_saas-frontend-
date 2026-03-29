import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/action_button.dart';
import '../../models/cliente.dart';
import '../../providers/contratos_provider.dart';
import '../../providers/clientes_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

/// Tela de contrato digital com assinatura inline
class ContratoScreen extends ConsumerStatefulWidget {
  const ContratoScreen({super.key});
  @override
  ConsumerState<ContratoScreen> createState() => _ContratoScreenState();
}

class _ContratoScreenState extends ConsumerState<ContratoScreen> {
  bool _assinando = false;
  bool _enviando  = false;

  String? get _clienteId {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    return args?['clienteId'] as String?;
  }

  Future<void> _assinar() async {
    final clienteId = _clienteId;
    if (clienteId == null) return;
    setState(() => _assinando = true);
    try {
      // Cria contrato se não existir e assina
      final contratoId = await ref.read(contratosProvider.notifier).criar(
        clienteId: clienteId,
        valorFixo: 2990,
        comissaoPct: 5,
      );
      await ref.read(contratosProvider.notifier).assinar(contratoId);
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.analise,
          arguments: {'contratoId': contratoId});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao assinar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _assinando = false);
    }
  }

  Future<void> _enviarEmail() async {
    final clienteId = _clienteId;
    if (clienteId == null) return;
    setState(() => _enviando = true);
    try {
      final contratoId = await ref.read(contratosProvider.notifier).criar(
        clienteId: clienteId,
        valorFixo: 2990,
        comissaoPct: 5,
      );
      await ref.read(contratosProvider.notifier).assinar(contratoId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contrato enviado por email!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clienteId = _clienteId;
    final clientes = ref.watch(clientesProvider).valueOrNull ?? const <Cliente>[];
    Cliente? cliente;
    if (clienteId != null) {
      for (final c in clientes) {
        if (c.id == clienteId) { cliente = c; break; }
      }
    }

    return AppScaffold(
      currentRoute: AppRoutes.vendas,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(child: Text('CONTRATO DE PARCERIA',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 1))),
                      const Center(child: Text('LIVESHOP ESTÚDIO',
                          style: TextStyle(fontSize: 14, color: AppColors.primary))),
                      const SizedBox(height: 32),
                      Text('CONTRATANTE: ${cliente?.nome ?? '[Nome do Cliente]'}'),
                      const SizedBox(height: 8),
                      Text('EMAIL: ${cliente?.email ?? '[Email]'}'),
                      const Divider(height: 32),
                      const Text(
                        'O presente contrato tem por objeto a prestação de serviços de transmissão ao vivo (LiveShop) pela CONTRATADA, conforme plano escolhido, com vigência de 12 (doze) meses a partir da data de assinatura.\n\n'
                        'Cláusula 1ª — DAS OBRIGAÇÕES DA CONTRATADA\nA CONTRATADA se compromete a disponibilizar cabine, equipamentos, apresentador e suporte técnico para realização das transmissões conforme cronograma acordado.\n\n'
                        'Cláusula 2ª — DAS OBRIGAÇÕES DO CONTRATANTE\nO CONTRATANTE se compromete ao pagamento das mensalidades nas datas acordadas e ao fornecimento dos produtos para transmissão.\n\n'
                        'Cláusula 3ª — DO VALOR\nO valor mensal acordado é de R\$ 2.990,00, vencendo todo dia 10 de cada mês.',
                        style: TextStyle(fontSize: 12, height: 1.6),
                      ),
                      const SizedBox(height: 40),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SignatureField(label: 'Assinatura do Contratante'),
                          _SignatureField(label: 'Assinatura da Contratada'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 220,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Ações',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                const SizedBox(height: 20),
                _assinando
                    ? const Center(child: CircularProgressIndicator())
                    : ActionButton(
                        label: 'ASSINAR AGORA',
                        icon: Icons.draw_outlined,
                        color: AppColors.success,
                        onPressed: _assinar,
                      ),
                const SizedBox(height: 12),
                _enviando
                    ? const Center(child: CircularProgressIndicator())
                    : ActionButton(
                        label: 'ENVIAR POR EMAIL',
                        icon: Icons.email_outlined,
                        outlined: true,
                        onPressed: _enviarEmail,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignatureField extends StatelessWidget {
  final String label;
  const _SignatureField({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 200, height: 60,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}
