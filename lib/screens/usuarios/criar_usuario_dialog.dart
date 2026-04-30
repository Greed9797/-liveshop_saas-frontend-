import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/usuarios_provider.dart';
import '../../providers/clientes_provider.dart';
import '../../services/api_service.dart';
import '../../design_system/design_system.dart';
import '../../widgets/temp_password_dialog.dart';

class CriarUsuarioDialog extends ConsumerStatefulWidget {
  const CriarUsuarioDialog({super.key});

  @override
  ConsumerState<CriarUsuarioDialog> createState() => _CriarUsuarioDialogState();
}

class _CriarUsuarioDialogState extends ConsumerState<CriarUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String _papel = 'gerente';
  String? _clienteId;
  bool _saving = false;

  static const _papeis = [
    ('gerente', 'Gerente'),
    ('gerente_comercial', 'Gerente Comercial'),
    ('financeiro', 'Financeiro'),
    ('operacional', 'Operacional'),
    ('apresentador', 'Apresentador'),
    ('apresentadora', 'Apresentadora'),
    ('cliente_parceiro', 'Cliente Parceiro'),
  ];

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool get _precisaCliente => _papel == 'cliente_parceiro';

  @override
  Widget build(BuildContext context) {
    final clientesAsync = _precisaCliente ? ref.watch(clientesProvider) : null;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.x4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x6),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Novo Usuário', style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.x6),

                  _Label('Nome *'),
                  TextFormField(
                    controller: _nomeCtrl,
                    decoration: _dec('Nome completo'),
                    validator: (v) =>
                        (v?.trim().isEmpty ?? true) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: AppSpacing.x4),

                  _Label('E-mail *'),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _dec('email@empresa.com'),
                    validator: (v) {
                      if (v?.trim().isEmpty ?? true) return 'Obrigatório';
                      if (!v!.contains('@')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.x4),

                  _Label('Papel *'),
                  DropdownButtonFormField<String>(
                    value: _papel,
                    decoration: _dec(null),
                    items: _papeis
                        .map((p) => DropdownMenuItem(
                              value: p.$1,
                              child: Text(p.$2),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _papel = v!;
                      _clienteId = null;
                    }),
                  ),

                  if (_precisaCliente && clientesAsync != null) ...[
                    const SizedBox(height: AppSpacing.x4),
                    _Label('Cliente vinculado *'),
                    clientesAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text(
                        ApiService.extractErrorMessage(e),
                        style: TextStyle(color: AppColors.danger),
                      ),
                      data: (clientes) {
                        final ativos = clientes
                            .where((c) =>
                                c.status != 'cancelado_automaticamente' &&
                                c.status != 'arquivado')
                            .toList();
                        return DropdownButtonFormField<String>(
                          value: _clienteId,
                          decoration: _dec('Selecione o cliente'),
                          items: ativos
                              .map((c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(
                                      c.nome,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          validator: (v) =>
                              v == null ? 'Selecione o cliente' : null,
                          onChanged: (v) => setState(() => _clienteId = v),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: AppSpacing.x6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: AppSpacing.x3),
                      FilledButton(
                        onPressed: _saving ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Criar usuário'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    try {
      final payload = <String, dynamic>{
        'nome': _nomeCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'papel': _papel,
        if (_clienteId != null) 'cliente_id': _clienteId,
      };

      final result =
          await ref.read(usuariosProvider.notifier).convidar(payload);

      if (!mounted) return;
      Navigator.of(context).pop();

      await TempPasswordDialog.show(
        context,
        nome: result['nome'] as String? ?? _nomeCtrl.text.trim(),
        email: result['email'] as String? ?? _emailCtrl.text.trim(),
        senhaTemporaria: result['senha_temporaria'] as String,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractErrorMessage(e)),
        backgroundColor: AppColors.danger,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _dec(String? hint) => InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.x1),
        child: Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      );
}
