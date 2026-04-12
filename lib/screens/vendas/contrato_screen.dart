import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/action_button.dart';
import '../../models/cliente.dart';
import '../../providers/contratos_provider.dart';
import '../../providers/clientes_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

class ContratoScreen extends ConsumerStatefulWidget {
  const ContratoScreen({super.key});
  @override
  ConsumerState<ContratoScreen> createState() => _ContratoScreenState();
}

class _ContratoScreenState extends ConsumerState<ContratoScreen> {
  bool _loading = false;
  String? _contratoId;

  String? get _clienteId {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    return args?['clienteId'] as String?;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _criarContrato());
  }

  Future<void> _criarContrato() async {
    final clienteId = _clienteId;
    if (clienteId == null || _contratoId != null) return;
    try {
      final id = await ref.read(contratosProvider.notifier).criar(
        clienteId: clienteId,
        valorFixo: 2990,
        comissaoPct: 5,
      );
      if (mounted) setState(() => _contratoId = id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar contrato: $e')));
      }
    }
  }

  Future<void> _abrirPadAssinatura() async {
    final contratoId = _contratoId;
    if (contratoId == null) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SignatureDialog(
        onConfirm: (base64) async {
          Navigator.of(ctx).pop();
          await _assinarDigital(contratoId, base64);
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Future<void> _assinarDigital(String contratoId, String base64) async {
    setState(() => _loading = true);
    try {
      final result = await ref.read(contratosProvider.notifier).assinarDigital(
        id: contratoId,
        signatureBase64: base64,
      );
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.analiseCredito, arguments: {
        'contratoId': contratoId,
        'aprovadoAutomatico': result['aprovado'] == true,
        'requerBackoffice': result['requer_backoffice'] == true,
        'score': result['score'],
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao assinar: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _enviarWhatsApp() async {
    final clienteId = _clienteId ?? '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link copiado: https://liveshop.app/assinar/$clienteId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clienteId = _clienteId;
    final clientes  = ref.watch(clientesProvider).valueOrNull ?? const <Cliente>[];
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
              padding: const EdgeInsets.all(AppSpacing.x3l),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.x4l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text('CONTRATO DE PARCERIA',
                          style: AppTypography.h3.copyWith(fontWeight: FontWeight.w500, letterSpacing: 1))),
                      Center(child: Text('LIVELAB ESTÚDIO',
                          style: AppTypography.bodySmall.copyWith(color: context.colors.primary))),
                      const SizedBox(height: AppSpacing.x3l),
                      Text('CONTRATANTE: ${cliente?.nome ?? '[Nome do Cliente]'}'),
                      if (cliente?.email != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text('EMAIL: ${cliente!.email}'),
                      ],
                      if (cliente?.cidade != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text('CIDADE: ${cliente!.cidade}/${cliente.estado ?? ''}'),
                      ],
                      const Divider(height: AppSpacing.x3l),
                      Text(
                        'O presente contrato tem por objeto a prestação de serviços de transmissão ao vivo (Livelab) pela CONTRATADA, conforme plano escolhido, com vigência de 12 (doze) meses a partir da data de assinatura.\n\n'
                        'Cláusula 1ª — DAS OBRIGAÇÕES DA CONTRATADA\nA CONTRATADA se compromete a disponibilizar cabine, equipamentos, apresentador e suporte técnico para realização das transmissões conforme cronograma acordado.\n\n'
                        'Cláusula 2ª — DAS OBRIGAÇÕES DO CONTRATANTE\nO CONTRATANTE se compromete ao pagamento das mensalidades nas datas acordadas e ao fornecimento dos produtos para transmissão.\n\n'
                        'Cláusula 3ª — DO VALOR\nO valor mensal acordado é de R\$ 2.990,00, vencendo todo dia 10 de cada mês.',
                        style: AppTypography.caption.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: AppSpacing.x4l),
                      Text('Assinatura do Contratante:', style: AppTypography.caption.copyWith(color: context.colors.textSecondary)),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: 240, height: 64,
                        decoration: BoxDecoration(
                          border: Border.all(color: context.colors.textTertiary),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Center(
                          child: Text('(clique em "Assinar Agora" →)', style: AppTypography.labelSmall.copyWith(color: context.colors.textSecondary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 220,
            color: context.colors.cardBackground,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Ações', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: AppSpacing.xl),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_contratoId == null)
                  const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                else ...[
                  ActionButton(
                    label: 'ASSINAR AGORA',
                    icon: Icons.draw_outlined,
                    color: context.colors.success,
                    onPressed: _abrirPadAssinatura,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ActionButton(
                    label: 'ENVIAR POR WHATSAPP',
                    icon: Icons.send_outlined,
                    outlined: true,
                    onPressed: _enviarWhatsApp,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignatureDialog extends StatefulWidget {
  final void Function(String base64) onConfirm;
  final VoidCallback onCancel;
  const _SignatureDialog({required this.onConfirm, required this.onCancel});

  @override
  State<_SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<_SignatureDialog> {
  late final SignatureController _ctrl;
  bool _acceptedTerms = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = SignatureController(
      penStrokeWidth: 2.5,
      penColor: Colors.black, // intentional: black ink on white canvas
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (_ctrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Desenhe sua assinatura antes de confirmar')),
      );
      return;
    }
    setState(() => _saving = true);
    final bytes = await _ctrl.toPngBytes();
    if (bytes == null) {
      setState(() => _saving = false);
      return;
    }
    final base64Str = base64Encode(bytes);
    widget.onConfirm(base64Str);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assinar Contrato'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Desenhe sua assinatura abaixo:', style: AppTypography.labelLarge.copyWith(color: context.colors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.textTertiary),
                borderRadius: BorderRadius.circular(AppRadius.md),
                color: context.colors.background,
              ),
              child: Signature(
                controller: _ctrl,
                height: 180,
                backgroundColor: context.colors.background,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _ctrl.clear(),
                icon: const Icon(Icons.refresh, size: 14),
                label: Text('Limpar', style: AppTypography.caption),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                ),
                Expanded(
                  child: Text('Li e aceito os termos do contrato de parceria Livelab',
                      style: AppTypography.caption),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: (_acceptedTerms && !_saving) ? _confirmar : null,
          style: ElevatedButton.styleFrom(backgroundColor: context.colors.success),
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Confirmar Assinatura', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
