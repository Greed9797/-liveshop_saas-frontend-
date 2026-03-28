import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/action_button.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Tela de contrato digital com assinatura inline
class ContratoScreen extends StatelessWidget {
  const ContratoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.vendas,
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(32),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text('CONTRATO DE PARCERIA',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 1))),
                      Center(child: Text('LIVESHOP ESTÚDIO',
                        style: TextStyle(fontSize: 14, color: AppColors.primary))),
                      SizedBox(height: 32),
                      Text('CONTRATANTE: [Nome do Cliente]'),
                      SizedBox(height: 8),
                      Text('CPF/CNPJ: [Dados do Cliente]'),
                      Divider(height: 32),
                      Text(
                        'O presente contrato tem por objeto a prestação de serviços de transmissão ao vivo (LiveShop) pela CONTRATADA, conforme plano escolhido, com vigência de 12 (doze) meses a partir da data de assinatura.\n\n'
                        'Cláusula 1ª — DAS OBRIGAÇÕES DA CONTRATADA\nA CONTRATADA se compromete a disponibilizar cabine, equipamentos, apresentador e suporte técnico para realização das transmissões conforme cronograma acordado.\n\n'
                        'Cláusula 2ª — DAS OBRIGAÇÕES DO CONTRATANTE\nO CONTRATANTE se compromete ao pagamento das mensalidades nas datas acordadas e ao fornecimento dos produtos para transmissão.\n\n'
                        'Cláusula 3ª — DO VALOR\nO valor mensal acordado é de R\$ [valor], vencendo todo dia [dia] de cada mês.',
                        style: TextStyle(fontSize: 12, height: 1.6),
                      ),
                      SizedBox(height: 40),
                      Row(
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
                ActionButton(
                  label: 'ASSINAR AGORA',
                  icon: Icons.draw_outlined,
                  color: AppColors.success,
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.analise),
                ),
                const SizedBox(height: 12),
                ActionButton(
                  label: 'ENVIAR POR EMAIL',
                  icon: Icons.email_outlined,
                  outlined: true,
                  onPressed: () {},
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
