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
                                .copyWith(color: AppColors.gray500),
                          ),
                        ],
                      ),
                    ),
                    ActionButton(
                      label: 'ADICIONAR',
                      icon: Icons.add,
                      color: AppColors.lilac,
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
                              const Icon(Icons.diamond_outlined,
                                  size: 48, color: AppColors.gray200),
                              const SizedBox(height: 12),
                              Text('Nenhuma recomendação ainda.',
                                  style: AppTypography.bodySmall
                                      .copyWith(color: AppColors.gray500)),
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
                    AppTypography.bodyMedium.copyWith(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _converter(
      BuildContext context, WidgetRef ref, Recomendacao r) async {
    showDialog(
      context: context,
      builder: (ctx) => _ConverterDialog(recomendacao: r),
    ).then((result) async {
      if (result != null &&
          result is Map<String, dynamic> &&
          context.mounted) {
        try {
          final clienteId =
              await ref.read(recomendacoesProvider.notifier).converter(
                    r.id,
                    clienteIdExistente: result['clienteId'],
                  );
          if (context.mounted) {
            Navigator.pushNamed(context, AppRoutes.contrato,
                arguments: {'clienteId': clienteId});
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao iniciar negociação: $e')),
            );
          }
        }
      }
    });
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
        backgroundColor: AppColors.lilac.withValues(alpha: 0.12),
        child: const Icon(Icons.diamond_outlined,
            color: AppColors.lilac, size: 20),
      ),
      title: Text(
        recomendacao.nomeIndicado,
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Indicado por: ${recomendacao.recomendante}',
        style: AppTypography.caption.copyWith(color: AppColors.gray500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: recomendacao.status == 'pendente'
          ? ActionButton(
              label: 'NEGOCIAR',
              icon: Icons.handshake_outlined,
              color: AppColors.lilac,
              outlined: true,
              onPressed: onConverter,
            )
          : Chip(
              label: Text(
                recomendacao.status.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  color: recomendacao.status == 'convertido'
                      ? AppColors.successGreen
                      : AppColors.gray500,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
              backgroundColor: recomendacao.status == 'convertido'
                  ? AppColors.successGreen.withValues(alpha: 0.12)
                  : AppColors.gray100,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
    );
  }
}

// ─── Dialog de conversão ─────────────────────────────────────────────────────

class _ConverterDialog extends ConsumerStatefulWidget {
  final Recomendacao recomendacao;
  const _ConverterDialog({required this.recomendacao});

  @override
  ConsumerState<_ConverterDialog> createState() => _ConverterDialogState();
}

class _ConverterDialogState extends ConsumerState<_ConverterDialog> {
  String? _selectedClienteId;
  bool _createNew = true;

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl)),
      title: const Text('Iniciar Negociação'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Como deseja registrar o cliente indicado (${widget.recomendacao.nomeIndicado})?',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.x2l),
            RadioListTile<bool>(
              title: const Text('Criar como novo cliente'),
              value: true,
              groupValue: _createNew,
              activeColor: AppColors.primaryOrange,
              onChanged: (val) => setState(() {
                _createNew = true;
                _selectedClienteId = null;
              }),
            ),
            RadioListTile<bool>(
              title: const Text('Vincular a um cliente existente'),
              value: false,
              groupValue: _createNew,
              activeColor: AppColors.primaryOrange,
              onChanged: (val) => setState(() {
                _createNew = false;
              }),
            ),
            if (!_createNew) ...[
              const SizedBox(height: AppSpacing.lg),
              clientesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erro ao carregar clientes: $e'),
                data: (clientes) {
                  if (clientes.isEmpty) {
                    return Text('Nenhum cliente cadastrado.',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.dangerRed));
                  }
                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Selecione o Cliente',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedClienteId,
                    items: clientes.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.nome),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedClienteId = val);
                    },
                  );
                },
              ),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange),
          onPressed: (!_createNew && _selectedClienteId == null)
              ? null
              : () {
                  Navigator.pop(context, {
                    'createNew': _createNew,
                    'clienteId': _selectedClienteId,
                  });
                },
          child: Text('Confirmar',
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.white)),
        ),
      ],
    );
  }
}
