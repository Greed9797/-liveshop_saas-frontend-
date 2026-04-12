import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/action_button.dart';
import '../../providers/recomendacoes_provider.dart';
import '../../providers/clientes_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../theme/theme.dart';
import '../../widgets/app_card.dart';

class RecomendacoesScreen extends ConsumerWidget {
  const RecomendacoesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recomendacoesProvider);

    return AppScaffold(
      currentRoute: AppRoutes.recomendacoes,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recomendações', style: AppTypography.h2),
                          const SizedBox(height: 4),
                          Text(
                            'Gerencie indicações de potenciais clientes',
                            style: AppTypography.caption
                                .copyWith(color: context.colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    ActionButton(
                      label: 'ADICIONAR',
                      icon: Icons.add,
                      color: context.colors.primary,
                      onPressed: () => _showAddDialog(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x2l),
                Expanded(
                  child: recsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Erro: $e'),
                            const SizedBox(height: AppSpacing.md),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(recomendacoesProvider.notifier)
                                  .refresh(),
                              child: const Text('Tentar novamente'),
                            ),
                          ]),
                    ),
                    data: (recs) => recs.isEmpty
                        ? Center(
                            child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.diamond_outlined,
                                  size: 48, color: context.colors.divider),
                              const SizedBox(height: 12),
                              Text('Nenhuma recomendação ainda.',
                                  style: AppTypography.bodySmall
                                      .copyWith(color: context.colors.textSecondary)),
                            ],
                          ))
                        : AppCard(
                            padding: EdgeInsets.zero,
                            child: ListView.separated(
                              itemCount: recs.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1, indent: 56),
                              itemBuilder: (_, i) {
                                final r = recs[i];
                                return _RecomendacaoTile(
                                  recomendacao: r,
                                  onConverter: () =>
                                      _converter(context, ref, r),
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final indicadoCtrl = TextEditingController();
    final recomendanteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Text('Adicionar Recomendação'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: indicadoCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nome do Potencial Cliente'),
                validator: (v) {
                  if (v == null || v.trim().length < 3) {
                    return 'Nome deve ter pelo menos 3 caracteres';
                  }
                  if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(v.trim())) {
                    return 'Nome deve conter apenas letras';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: recomendanteCtrl,
                decoration: const InputDecoration(
                    labelText: 'Quem está recomendando'),
                validator: (v) {
                  if (v == null || v.trim().length < 3) {
                    return 'Nome deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              try {
                await ref.read(recomendacoesProvider.notifier).criar({
                  'nome_indicado': indicadoCtrl.text.trim(),
                  'recomendante': recomendanteCtrl.text.trim(),
                });
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao salvar: $e')),
                  );
                }
              }
            },
            child: Text('SALVAR',
                style:
                    AppTypography.bodyMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _converter(
      BuildContext context, WidgetRef ref, Recomendacao r) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _NegociarDialog(recomendacao: r),
    );
    if (result == null || !context.mounted) return;

    try {
      final resp = await ref.read(recomendacoesProvider.notifier).converter(
        r.id,
        dados: result,
      );
      if (!context.mounted) return;

      final altoRisco = resp['alto_risco'] == true;
      final score = resp['score'] as int? ?? 0;
      final clienteId = resp['cliente_id'] as String?;

      ref.invalidate(clientesProvider);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(altoRisco
            ? 'Cliente convertido (Score: $score — alto risco). Iniciando contrato...'
            : 'Cliente convertido com sucesso! (Score: $score). Iniciando contrato...'),
        backgroundColor: altoRisco ? context.colors.error : context.colors.success,
      ));

      Navigator.pushNamed(
        context,
        AppRoutes.contrato,
        arguments: {'clienteId': clienteId},
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao converter: $e')),
        );
      }
    }
  }
}

// ─── Item da lista de recomendações ──────────────────────────────────────────

class _RecomendacaoTile extends StatelessWidget {
  final Recomendacao recomendacao;
  final VoidCallback onConverter;

  const _RecomendacaoTile({
    required this.recomendacao,
    required this.onConverter,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: context.colors.primary.withValues(alpha: 0.12),
        child: Icon(Icons.diamond_outlined,
            color: context.colors.primary, size: 20),
      ),
      title: Text(
        recomendacao.nomeIndicado,
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Indicado por: ${recomendacao.recomendante}',
        style: AppTypography.caption.copyWith(color: context.colors.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: recomendacao.status == 'pendente'
          ? ActionButton(
              label: 'NEGOCIAR',
              icon: Icons.handshake_outlined,
              color: context.colors.primary,
              outlined: true,
              onPressed: onConverter,
            )
          : Chip(
              label: Text(
                recomendacao.status.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  color: recomendacao.status == 'convertido'
                      ? context.colors.success
                      : context.colors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
              backgroundColor: recomendacao.status == 'convertido'
                  ? context.colors.success.withValues(alpha: 0.12)
                  : context.colors.background,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
    );
  }
}

// ─── Dialog de negociação com mini-formulário ───────────────────────────────

class _NegociarDialog extends StatefulWidget {
  final Recomendacao recomendacao;
  const _NegociarDialog({required this.recomendacao});

  @override
  State<_NegociarDialog> createState() => _NegociarDialogState();
}

class _NegociarDialogState extends State<_NegociarDialog> {
  final _celularCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _hasCnpj = false;
  bool _highFat = false;

  String get _riscoLabel {
    int score = 0;
    if (_highFat) score += 50;
    if (_hasCnpj) score += 20;
    if (score >= 60) return 'BAIXO RISCO';
    if (score >= 20) return 'RISCO MODERADO';
    return 'ALTO RISCO';
  }

  Color _riscoColor(BuildContext context) {
    int score = 0;
    if (_highFat) score += 50;
    if (_hasCnpj) score += 20;
    if (score >= 60) return context.colors.success;
    if (score >= 20) return context.colors.warning;
    return context.colors.error;
  }

  void _updateRisco() {
    final fat = double.tryParse(_fatCtrl.text.replaceAll(',', '.')) ?? 0;
    setState(() {
      _hasCnpj = _cnpjCtrl.text.replaceAll(RegExp(r'\D'), '').length >= 14;
      _highFat = fat > 50000;
    });
  }

  @override
  void dispose() {
    _celularCtrl.dispose();
    _cnpjCtrl.dispose();
    _cepCtrl.dispose();
    _cidadeCtrl.dispose();
    _estadoCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final riscoColor = _riscoColor(context);
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.x2l),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.handshake_outlined,
                        color: context.colors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Negociar com ${widget.recomendacao.nomeIndicado}',
                          style: AppTypography.h3),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Indicador de risco
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: riscoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: riscoColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _riscoLabel == 'ALTO RISCO'
                            ? Icons.warning_amber_rounded
                            : Icons.shield_outlined,
                        color: riscoColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _riscoLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: riscoColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Preencha para melhorar o score',
                        style: AppTypography.caption
                            .copyWith(color: context.colors.textTertiary, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Campos
                TextFormField(
                  controller: _celularCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Celular (WhatsApp) *',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cnpjCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _updateRisco(),
                  decoration: InputDecoration(
                    labelText: 'CNPJ',
                    border: const OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    suffixIcon: _hasCnpj
                        ? Icon(Icons.check_circle,
                            color: context.colors.success, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fatCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _updateRisco(),
                  decoration: InputDecoration(
                    labelText: 'Faturamento Anual R\$',
                    border: const OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    suffixIcon: _highFat
                        ? Icon(Icons.check_circle,
                            color: context.colors.success, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _cepCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'CEP',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _cidadeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Cidade',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _estadoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'UF',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x2l),

                // Ações
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primary),
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          Navigator.pop(context, {
                            'celular': _celularCtrl.text.trim(),
                            if (_cnpjCtrl.text.trim().isNotEmpty)
                              'cnpj': _cnpjCtrl.text.trim(),
                            if (_fatCtrl.text.trim().isNotEmpty)
                              'fat_anual': double.tryParse(
                                      _fatCtrl.text.replaceAll(',', '.')) ??
                                  0,
                            if (_cepCtrl.text.trim().isNotEmpty)
                              'cep': _cepCtrl.text.trim(),
                            if (_cidadeCtrl.text.trim().isNotEmpty)
                              'cidade': _cidadeCtrl.text.trim(),
                            if (_estadoCtrl.text.trim().isNotEmpty)
                              'estado': _estadoCtrl.text.trim(),
                          });
                        },
                        icon: const Icon(Icons.send_rounded,
                            size: 16, color: Colors.white),
                        label: Text('Converter para Lead',
                            style: AppTypography.bodySmall
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
