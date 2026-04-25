import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../design_system/design_system.dart';
import '../../models/apresentadora.dart';
import '../../providers/apresentadoras_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

class ApresentadorasScreen extends ConsumerWidget {
  const ApresentadorasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(apresentadorasProvider);
    return AppScreenScaffold(
      currentRoute: AppRoutes.apresentadoras,
      eyebrow: 'Pessoas',
      title: 'Apresentadoras',
      titleSerif: true,
      subtitle: 'Controle de pessoas vinculadas à operação de lives.',
      actions: [
        AppPrimaryButton(
          label: 'Nova',
          icon: Icons.add_rounded,
          onPressed: () => _openForm(context, ref),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(ApiService.extractErrorMessage(error)),
          ),
          data: (items) => items.isEmpty
              ? Center(
                  child: Text(
                    'Nenhuma apresentadora cadastrada.',
                    style: AppTypography.bodyMedium
                        .copyWith(color: context.colors.textSecondary),
                  ),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.x3),
                  itemBuilder: (context, index) => _ApresentadoraCard(
                    item: items[index],
                    onEdit: () => _openForm(context, ref, items[index]),
                  ),
                ),
        ),
      ),
    );
  }

  void _openForm(BuildContext context, WidgetRef ref, [Apresentadora? item]) {
    final nomeCtrl = TextEditingController(text: item?.nome ?? '');
    final telefoneCtrl = TextEditingController(text: item?.telefone ?? '');
    final cargoCtrl = TextEditingController(text: item?.cargo ?? '');
    final emailCtrl = TextEditingController(text: item?.email ?? '');
    final cpfCtrl = TextEditingController(text: item?.cpfCnpj ?? '');
    final cidadeCtrl = TextEditingController(text: item?.cidade ?? '');
    final fixoCtrl =
        TextEditingController(text: item?.fixo.toStringAsFixed(2) ?? '');
    final comissaoCtrl =
        TextEditingController(text: item?.comissaoPct.toStringAsFixed(2) ?? '');
    final metaCtrl = TextEditingController(
        text: item?.metaDiariaGmv.toStringAsFixed(2) ?? '');
    final obsCtrl = TextEditingController(text: item?.observacoes ?? '');
    final linkContratoCtrl =
        TextEditingController(text: item?.linkContrato ?? '');
    final aniversarioCtrl =
        TextEditingController(text: item?.dataAniversario ?? '');
    final dataInicioCtrl =
        TextEditingController(text: item?.dataInicio ?? '');
    final dataFimCtrl = TextEditingController(text: item?.dataFim ?? '');
    var ativo = item?.ativo ?? true;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.colors.bgCard,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.x5,
              right: AppSpacing.x5,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.x5,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      item == null
                          ? 'Nova apresentadora'
                          : 'Editar apresentadora',
                      style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.x4),
                  AppTextField(controller: nomeCtrl, hint: 'Nome *'),
                  const SizedBox(height: AppSpacing.x3),
                  Row(
                    children: [
                      Expanded(
                          child: AppTextField(
                              controller: telefoneCtrl, hint: 'Telefone')),
                      const SizedBox(width: AppSpacing.x3),
                      Expanded(
                          child: AppTextField(
                              controller: cargoCtrl, hint: 'Cargo')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  Row(
                    children: [
                      Expanded(
                          child: AppTextField(
                              controller: emailCtrl, hint: 'E-mail')),
                      const SizedBox(width: AppSpacing.x3),
                      Expanded(
                          child: AppTextField(
                              controller: cpfCtrl, hint: 'CPF/CNPJ')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  AppTextField(controller: cidadeCtrl, hint: 'Cidade'),
                  const SizedBox(height: AppSpacing.x3),
                  Row(
                    children: [
                      Expanded(
                          child: AppTextField(
                              controller: fixoCtrl, hint: 'Fixo R\$')),
                      const SizedBox(width: AppSpacing.x3),
                      Expanded(
                          child: AppTextField(
                              controller: comissaoCtrl, hint: 'Comissão %')),
                      const SizedBox(width: AppSpacing.x3),
                      Expanded(
                          child: AppTextField(
                              controller: metaCtrl, hint: 'Meta diária GMV')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ativa'),
                    value: ativo,
                    onChanged: (value) => setState(() => ativo = value),
                  ),
                  AppTextField(
                    controller: obsCtrl,
                    hint: 'Observações',
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  AppTextField(
                    controller: linkContratoCtrl,
                    hint: 'Link do contrato (URL)',
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  AppTextField(
                    controller: aniversarioCtrl,
                    hint: 'Aniversário (YYYY-MM-DD)',
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: dataInicioCtrl,
                          hint: 'Data início (YYYY-MM-DD)',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x3),
                      Expanded(
                        child: AppTextField(
                          controller: dataFimCtrl,
                          hint: 'Data fim (YYYY-MM-DD)',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppSecondaryButton(
                        label: 'Cancelar',
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                      const SizedBox(width: AppSpacing.x2),
                      AppPrimaryButton(
                        label: 'Salvar',
                        onPressed: () async {
                          final nome = nomeCtrl.text.trim();
                          if (nome.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Informe o nome.')),
                            );
                            return;
                          }
                          final data = {
                            'nome': nome,
                            'telefone': _emptyToNull(telefoneCtrl.text),
                            'cargo': _emptyToNull(cargoCtrl.text),
                            'email': _emptyToNull(emailCtrl.text),
                            'cpf_cnpj': _emptyToNull(cpfCtrl.text),
                            'cidade': _emptyToNull(cidadeCtrl.text),
                            'ativo': ativo,
                            'fixo': _toDouble(fixoCtrl.text),
                            'comissao_pct': _toDouble(comissaoCtrl.text),
                            'meta_diaria_gmv': _toDouble(metaCtrl.text),
                            'observacoes': _emptyToNull(obsCtrl.text),
                            'link_contrato':
                                _emptyToNull(linkContratoCtrl.text),
                            'data_aniversario':
                                _emptyToNull(aniversarioCtrl.text),
                            'data_inicio': _emptyToNull(dataInicioCtrl.text),
                            'data_fim': _emptyToNull(dataFimCtrl.text),
                          };
                          try {
                            await ref
                                .read(apresentadorasProvider.notifier)
                                .salvar(data, id: item?.id);
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text(ApiService.extractErrorMessage(error)),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double _toDouble(String value) =>
      double.tryParse(value.replaceAll(',', '.')) ?? 0;
}

class _ApresentadoraCard extends StatelessWidget {
  final Apresentadora item;
  final VoidCallback onEdit;

  const _ApresentadoraCard({required this.item, required this.onEdit});

  static final _money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final _moneyInt =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.x4),
      borderColor: context.colors.borderSubtle,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: item.ativo
                ? AppColors.primary.withValues(alpha: 0.12)
                : context.colors.bgMuted,
            child: Text(
              item.nome.isEmpty ? '?' : item.nome[0].toUpperCase(),
              style: TextStyle(
                color:
                    item.ativo ? AppColors.primary : context.colors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nome,
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.x1),
                Text(
                  [
                    if ((item.cargo ?? '').isNotEmpty) item.cargo!,
                    if ((item.cidade ?? '').isNotEmpty) item.cidade!,
                    if ((item.telefone ?? '').isNotEmpty) item.telefone!,
                  ].join(' • '),
                  style: AppTypography.caption
                      .copyWith(color: context.colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.x2),
                Text(
                  'Fixo ${_money.format(item.fixo)} • ${item.comissaoPct.toStringAsFixed(1)}% • Meta ${_money.format(item.metaDiariaGmv)}',
                  style: AppTypography.caption
                      .copyWith(color: context.colors.textSecondary),
                ),
                if (item.totalLives > 0) ...[
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    'Lives: ${item.totalLives} • Horas: ${item.totalHoras.toStringAsFixed(1)}h • Fat: ${_moneyInt.format(item.totalFaturamento)}',
                    style: AppTypography.caption
                        .copyWith(color: context.colors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          AppBadge(
            label: item.ativo ? 'ATIVA' : 'INATIVA',
            type: item.ativo ? AppBadgeType.success : AppBadgeType.neutral,
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: context.colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
