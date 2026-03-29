import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/action_button.dart';
import '../../providers/clientes_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

/// Formulário de cadastro de novo cliente
class CadastroClienteScreen extends ConsumerStatefulWidget {
  const CadastroClienteScreen({super.key});
  @override
  ConsumerState<CadastroClienteScreen> createState() => _CadastroClienteScreenState();
}

class _CadastroClienteScreenState extends ConsumerState<CadastroClienteScreen> {
  final _nomeCtrl     = TextEditingController();
  final _celularCtrl  = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _cpfCtrl      = TextEditingController();
  final _cnpjCtrl     = TextEditingController();
  final _razaoCtrl    = TextEditingController();
  final _fatCtrl      = TextEditingController();
  final _nichoCtrl    = TextEditingController();
  bool _jaVendeTikTok = false;
  bool _loading = false;

  @override
  void dispose() {
    _nomeCtrl.dispose(); _celularCtrl.dispose(); _emailCtrl.dispose();
    _cpfCtrl.dispose(); _cnpjCtrl.dispose(); _razaoCtrl.dispose();
    _fatCtrl.dispose(); _nichoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar({required bool gerarContrato}) async {
    if (_nomeCtrl.text.isEmpty || _celularCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e celular são obrigatórios')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final cliente = await ref.read(clientesProvider.notifier).criar({
        'nome': _nomeCtrl.text,
        'celular': _celularCtrl.text,
        if (_emailCtrl.text.isNotEmpty) 'email': _emailCtrl.text,
        if (_nichoCtrl.text.isNotEmpty) 'nicho': _nichoCtrl.text,
        'fat_anual': double.tryParse(_fatCtrl.text.replaceAll(',', '.')) ?? 0,
      });
      if (!mounted) return;
      if (gerarContrato) {
        Navigator.pushNamed(context, AppRoutes.contrato,
            arguments: {'clienteId': cliente.id});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rascunho salvo!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
                    _field('Nome Completo *', _nomeCtrl),
                    _field('CPF', _cpfCtrl),
                    _field('CNPJ', _cnpjCtrl),
                    _field('Razão Social', _razaoCtrl),
                    _field('Email', _emailCtrl, type: TextInputType.emailAddress),
                    _field('Celular (WhatsApp) *', _celularCtrl, type: TextInputType.phone),
                    _field('Faturamento Atual (ano) R\$', _fatCtrl, type: TextInputType.number),
                    _field('Nicho', _nichoCtrl),
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
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Row(
                        children: [
                          ActionButton(
                            label: 'GERAR CONTRATO',
                            icon: Icons.description_outlined,
                            onPressed: () => _salvar(gerarContrato: true),
                          ),
                          const SizedBox(width: 12),
                          ActionButton(
                            label: 'SALVAR RASCUNHO',
                            icon: Icons.save_outlined,
                            outlined: true,
                            onPressed: () => _salvar(gerarContrato: false),
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

  Widget _field(String label, TextEditingController ctrl, {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
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
