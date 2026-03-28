import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/action_button.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Formulário de cadastro de novo cliente
class CadastroClienteScreen extends StatefulWidget {
  const CadastroClienteScreen({super.key});
  @override
  State<CadastroClienteScreen> createState() => _CadastroClienteScreenState();
}

class _CadastroClienteScreenState extends State<CadastroClienteScreen> {
  bool _jaVendeTikTok = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.vendas,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cadastrar Novo Cliente',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 24),
                    _field('Nome Completo'),
                    _field('CPF'),
                    _field('CNPJ'),
                    _field('Razão Social'),
                    _field('Email', type: TextInputType.emailAddress),
                    _field('Celular (WhatsApp)', type: TextInputType.phone),
                    _field('Faturamento Atual (ano) R\$', type: TextInputType.number),
                    _field('Nicho'),
                    _field('Site'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Já vende no TikTok Live?'),
                        const SizedBox(width: 12),
                        Switch(
                          value: _jaVendeTikTok,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) => setState(() => _jaVendeTikTok = v),
                        ),
                        Text(_jaVendeTikTok ? 'Sim' : 'Não'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        ActionButton(
                          label: 'GERAR CONTRATO',
                          icon: Icons.description_outlined,
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.contrato),
                        ),
                        const SizedBox(width: 12),
                        ActionButton(
                          label: 'SALVAR RASCUNHO',
                          icon: Icons.save_outlined,
                          outlined: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
