import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/cabine.dart';
import '../../models/pacote.dart';
import '../../models/usuario.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cabines_provider.dart';
import '../../providers/configuracoes_provider.dart';
import '../../providers/pacotes_provider.dart';
import '../../providers/tiktok_provider.dart';
import '../../providers/usuarios_provider.dart';
import '../../routes/app_routes.dart';
import '../../design_system/design_system.dart';
import '../../services/api_service.dart';
import '../../services/clipboard_service.dart';

class ConfiguracoesScreen extends ConsumerStatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  ConsumerState<ConfiguracoesScreen> createState() =>
      _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends ConsumerState<ConfiguracoesScreen> {
  int _selectedSection = 0;

  Pacote? _editingPacote;
  final _pacNomeCtrl = TextEditingController();
  final _pacDescCtrl = TextEditingController();
  final _pacValorCtrl = TextEditingController();
  final _pacHorasCtrl = TextEditingController();
  bool _pacLoading = false;

  final _nomeCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  final _metaCtrl = TextEditingController();
  final _asaasKeyCtrl = TextEditingController();
  final _asaasWalletCtrl = TextEditingController();
  bool _isConnectingTiktok = false;
  final _tiktokShopCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  bool _isEditingGeral = false;
  bool _isEditingFin = false;
  bool _isEditingTiktok = false;
  bool _isEditingSeguranca = false;

  bool _uploadingLogo = false;
  Uint8List? _pickedImageBytes;

  String _maskSecret(String value) {
    if (value.isEmpty) return 'Nao informada';
    return List.filled(value.length, '•').join();
  }

  Future<bool> _ensureSensitiveAuth({required String operationLabel}) async {
    final authState = ref.read(authProvider);
    if (authState.hasRecentSensitiveAuth) return true;

    final user = authState.user;
    if (user == null) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessao invalida. Faca login novamente.')),
      );
      return false;
    }

    final passwordCtrl = TextEditingController();
    String? errorMessage;
    bool submitting = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              title: Text('Confirmar identidade', style: AppTypography.h3),
              content: SizedBox(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Para $operationLabel, confirme a senha da conta ${user.email}.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    AppTextField(
                      controller: passwordCtrl,
                      hint: 'Senha atual',
                      obscureText: true,
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.x3),
                      Text(
                        errorMessage!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                AppSecondaryButton(
                  label: 'Cancelar',
                  onPressed: submitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                ),
                AppPrimaryButton(
                  label: 'Confirmar',
                  isLoading: submitting,
                  onPressed: () async {
                    final password = passwordCtrl.text.trim();
                    if (password.isEmpty) {
                      setDialogState(() {
                        errorMessage = 'Informe sua senha atual.';
                      });
                      return;
                    }

                    setDialogState(() {
                      submitting = true;
                      errorMessage = null;
                    });

                    final ok = await ref
                        .read(authProvider.notifier)
                        .reauthenticate(password);

                    if (!ctx.mounted) return;

                    if (ok) {
                      Navigator.of(dialogContext).pop(true);
                      return;
                    }

                    setDialogState(() {
                      submitting = false;
                      errorMessage = ref.read(authProvider).error ??
                          'Nao foi possivel confirmar sua identidade.';
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );

    passwordCtrl.dispose();
    return confirmed == true;
  }

  Future<void> _salvarFinanceiroSensivel() async {
    final payload = <String, dynamic>{
      if (_asaasKeyCtrl.text.isNotEmpty) 'asaas_api_key': _asaasKeyCtrl.text,
      if (_asaasWalletCtrl.text.isNotEmpty)
        'asaas_wallet_id': _asaasWalletCtrl.text,
    };

    if (payload.isEmpty) {
      setState(() => _isEditingFin = false);
      return;
    }

    final confirmed = await _ensureSensitiveAuth(
      operationLabel: 'alterar as credenciais financeiras',
    );
    if (!confirmed) return;

    await _salvar(payload, () => setState(() => _isEditingFin = false));
  }

  Future<void> _salvarNovaSenha() async {
    if (_senhaCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha deve ter no minimo 6 caracteres.'),
        ),
      );
      return;
    }

    final confirmed = await _ensureSensitiveAuth(
      operationLabel: 'alterar a senha da conta',
    );
    if (!confirmed) return;

    await _salvar({'nova_senha': _senhaCtrl.text}, () {
      _senhaCtrl.clear();
      setState(() => _isEditingSeguranca = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _logoCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _logoCtrl.dispose();
    _metaCtrl.dispose();
    _asaasKeyCtrl.dispose();
    _asaasWalletCtrl.dispose();
    _tiktokShopCtrl.dispose();
    _senhaCtrl.dispose();
    _pacNomeCtrl.dispose();
    _pacDescCtrl.dispose();
    _pacValorCtrl.dispose();
    _pacHorasCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar(Map<String, dynamic> payload, VoidCallback onFinish) async {
    try {
      await ref.read(configuracoesProvider.notifier).atualizar(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações atualizadas com sucesso!')),
      );
      onFinish();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService.extractErrorMessage(e))),
      );
    }
  }

  Future<void> _salvarPacote(BuildContext sheetCtx) async {
    final nome = _pacNomeCtrl.text.trim();
    final sheetMessenger = ScaffoldMessenger.of(sheetCtx);
    final sheetNav = Navigator.of(sheetCtx);

    if (nome.isEmpty) {
      sheetMessenger.showSnackBar(const SnackBar(content: Text('Nome é obrigatório')));
      return;
    }
    final valor = double.tryParse(_pacValorCtrl.text.replaceAll(',', '.'));
    final horas = double.tryParse(_pacHorasCtrl.text);
    if (valor == null || horas == null) {
      sheetMessenger.showSnackBar(const SnackBar(content: Text('Informe valor e horas válidos')));
      return;
    }

    setState(() => _pacLoading = true);
    try {
      final payload = {
        'nome': nome,
        if (_pacDescCtrl.text.isNotEmpty) 'descricao': _pacDescCtrl.text,
        'valor': valor,
        'horas_incluidas': horas,
      };
      if (_editingPacote == null) {
        await ref.read(pacotesProvider.notifier).criar(payload);
      } else {
        await ref.read(pacotesProvider.notifier).atualizar(_editingPacote!.id, payload);
      }
      if (!mounted) return;
      sheetNav.pop();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pacote salvo com sucesso!')));
    } catch (e) {
      if (!mounted) return;
      sheetMessenger.showSnackBar(SnackBar(content: Text(ApiService.extractErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _pacLoading = false);
    }
  }

  void _abrirFormPacote([Pacote? pacote]) {
    setState(() {
      _editingPacote = pacote;
      _pacNomeCtrl.text = pacote?.nome ?? '';
      _pacDescCtrl.text = pacote?.descricao ?? '';
      _pacValorCtrl.text = pacote?.valor.toStringAsFixed(2) ?? '';
      _pacHorasCtrl.text = pacote?.horasIncluidas.toStringAsFixed(0) ?? '';
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.colors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.x5, AppSpacing.x2, AppSpacing.x5,
            AppSpacing.x5 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pacote == null ? 'Novo Pacote' : 'Editar Pacote',
                  style: AppTypography.h2.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.x4),
              AppTextField(controller: _pacNomeCtrl, hint: 'Nome do pacote *'),
              const SizedBox(height: AppSpacing.x3),
              AppTextField(controller: _pacDescCtrl, hint: 'Descrição (opcional)'),
              const SizedBox(height: AppSpacing.x3),
              Row(
                children: [
                  Expanded(child: AppTextField(
                    controller: _pacValorCtrl, hint: 'Valor mensal R\$',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  )),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(child: AppTextField(
                    controller: _pacHorasCtrl, hint: 'Horas incluídas',
                    keyboardType: TextInputType.number,
                  )),
                ],
              ),
              const SizedBox(height: AppSpacing.x5),
              if (_pacLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(child: AppSecondaryButton(
                      label: 'Cancelar', fullWidth: true,
                      onPressed: () => Navigator.pop(ctx),
                    )),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(child: AppPrimaryButton(
                      label: 'Salvar', fullWidth: true,
                      onPressed: () => _salvarPacote(ctx),
                    )),
                  ],
                ),
              const SizedBox(height: AppSpacing.x2),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarFormCabine(BuildContext context) async {
    final nomeCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String? tamanhoSelecionado;
    int quantidade = 1;
    bool saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
            title: Text('Nova Cabine', style: AppTypography.h3),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(controller: nomeCtrl, hint: 'Nome da cabine *'),
                  const SizedBox(height: AppSpacing.x3),
                  AppDropdown<String>(
                    value: tamanhoSelecionado, hint: 'Tamanho *',
                    items: ['P', 'M', 'G', 'GG'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setDialogState(() => tamanhoSelecionado = v),
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  AppTextField(controller: descCtrl, hint: 'Descrição (opcional)'),
                  const SizedBox(height: AppSpacing.x3),
                  Row(
                    children: [
                      Text('Quantidade:', style: AppTypography.bodySmall),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.remove_rounded, size: 18),
                          onPressed: quantidade > 1 ? () => setDialogState(() => quantidade--) : null),
                      Text('$quantidade', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      IconButton(icon: const Icon(Icons.add_rounded, size: 18),
                          onPressed: quantidade < 10 ? () => setDialogState(() => quantidade++) : null),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              AppSecondaryButton(label: 'Cancelar', onPressed: () => Navigator.of(dialogContext).pop()),
              AppPrimaryButton(
                label: 'Salvar', isLoading: saving,
                onPressed: () async {
                  final nome = nomeCtrl.text.trim();
                  if (nome.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome da cabine')));
                    return;
                  }
                  if (tamanhoSelecionado == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione o tamanho da cabine')));
                    return;
                  }
                  setDialogState(() => saving = true);
                  final notifier = ref.read(cabinesProvider.notifier);
                  int criadas = 0;
                  String? lastError;
                  for (int i = 0; i < quantidade; i++) {
                    final nomeFinal = quantidade > 1 ? '$nome ${(i + 1).toString().padLeft(2, '0')}' : nome;
                    try {
                      await notifier.criar({
                        'nome': nomeFinal,
                        'tamanho': tamanhoSelecionado,
                        if (descCtrl.text.trim().isNotEmpty) 'descricao': descCtrl.text.trim(),
                      });
                      criadas++;
                    } catch (e) {
                      lastError = ApiService.extractErrorMessage(e);
                    }
                  }
                  await notifier.refresh();
                  if (!context.mounted) return;
                  Navigator.of(dialogContext).pop();
                  if (lastError != null && criadas < quantidade) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(criadas == 0 ? lastError : '$criadas de $quantidade cabine${quantidade > 1 ? 's' : ''} criada${criadas > 1 ? 's' : ''}. Erro: $lastError'),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('$criadas cabine${criadas > 1 ? 's' : ''} criada${criadas > 1 ? 's' : ''} com sucesso!')));
                  }
                  if (criadas == 0) setDialogState(() => saving = false);
                },
              ),
            ],
          );
        });
      },
    );

    nomeCtrl.dispose();
    descCtrl.dispose();
  }

  Future<void> _confirmarDeletar(BuildContext context, Cabine cabine) async {
    final nomeCabine = cabine.nome ?? 'Cabine ${cabine.numero.toString().padLeft(2, '0')}';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text('Deletar Cabine?', style: AppTypography.h3),
        content: Text(
          'Tem certeza que deseja deletar $nomeCabine? Esta ação não pode ser desfeita.',
          style: AppTypography.bodySmall,
        ),
        actions: [
          AppSecondaryButton(label: 'Cancelar', onPressed: () => Navigator.of(dialogContext).pop(false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md))),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await ref.read(cabinesProvider.notifier).deletar(cabine.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$nomeCabine deletada com sucesso!')));
    } catch (e) {
      if (!context.mounted) return;
      final msg = ApiService.extractErrorMessage(e);

      // Cabine tem contrato vinculado — oferecer opção de liberar e deletar
      if (msg.toLowerCase().contains('libere') || msg.toLowerCase().contains('contrato')) {
        final force = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
            title: Text('Cabine com contrato ativo', style: AppTypography.h3),
            content: Text(
              '$nomeCabine está vinculada a um contrato. Ao liberar e deletar, o vínculo será removido e a cabine ficará disponível momentaneamente antes de ser excluída.',
              style: AppTypography.bodySmall,
            ),
            actions: [
              AppSecondaryButton(label: 'Cancelar', onPressed: () => Navigator.of(dialogContext).pop(false)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md))),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Liberar e Deletar'),
              ),
            ],
          ),
        );

        if (force != true || !context.mounted) return;
        try {
          await ApiService.patch('/cabines/${cabine.id}/liberar');
          await ref.read(cabinesProvider.notifier).deletar(cabine.id);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$nomeCabine liberada e deletada com sucesso!')));
        } catch (e2) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiService.extractErrorMessage(e2))));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  Future<void> _confirmarRemoverUsuario(BuildContext context, Usuario usuario) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text('Remover Usuário?', style: AppTypography.h3),
        content: Text('Tem certeza que deseja remover ${usuario.nome}? Esta ação não pode ser desfeita.',
            style: AppTypography.bodySmall),
        actions: [
          AppSecondaryButton(label: 'Cancelar', onPressed: () => Navigator.of(dialogContext).pop(false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md))),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;
    try {
      await ref.read(usuariosProvider.notifier).remover(usuario.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${usuario.nome} removido com sucesso!')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiService.extractErrorMessage(e))));
    }
  }

  Future<void> _mostrarConviteDialog(BuildContext context) async {
    final nomeCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String? papelSelecionado;
    bool saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
            title: Text('Convidar Usuário', style: AppTypography.h3),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(controller: nomeCtrl, hint: 'Nome completo *'),
                  const SizedBox(height: AppSpacing.x3),
                  AppTextField(controller: emailCtrl, hint: 'E-mail *', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: AppSpacing.x3),
                  AppDropdown<String>(
                    value: papelSelecionado, hint: 'Papel *',
                    items: const [
                      DropdownMenuItem(value: 'gerente', child: Text('Gerente')),
                      DropdownMenuItem(value: 'apresentador', child: Text('Apresentador')),
                    ],
                    onChanged: (v) => setDialogState(() => papelSelecionado = v),
                  ),
                ],
              ),
            ),
            actions: [
              AppSecondaryButton(label: 'Cancelar', onPressed: () => Navigator.of(dialogContext).pop()),
              AppPrimaryButton(
                label: 'Convidar', isLoading: saving,
                onPressed: () async {
                  final nome = nomeCtrl.text.trim();
                  final email = emailCtrl.text.trim();
                  if (nome.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome')));
                    return;
                  }
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o e-mail')));
                    return;
                  }
                  if (papelSelecionado == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione o papel')));
                    return;
                  }
                  setDialogState(() => saving = true);
                  try {
                    final result = await ref.read(usuariosProvider.notifier).convidar({
                      'nome': nome, 'email': email, 'papel': papelSelecionado,
                    });
                    if (!context.mounted) return;
                    Navigator.of(dialogContext).pop();
                    final senhaTemp = result['senha_temporaria'] as String? ?? '';
                    if (context.mounted) {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx2) {
                          var revealPassword = false;
                          return StatefulBuilder(
                            builder: (ctx3, setRevealState) => AlertDialog(
                              title: const Text('Usuario convidado!'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'O usuario foi criado. Revele a senha temporaria apenas no momento de compartilhar com o destinatario correto.',
                                    style: AppTypography.bodySmall,
                                  ),
                                  const SizedBox(height: AppSpacing.x3),
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.x3),
                                    decoration: BoxDecoration(
                                      color: context.colors.bgMuted,
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            revealPassword
                                                ? senhaTemp
                                                : _maskSecret(senhaTemp),
                                            style: AppTypography.bodyMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            revealPassword
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            size: 18,
                                          ),
                                          tooltip: revealPassword
                                              ? 'Ocultar senha'
                                              : 'Revelar senha',
                                          onPressed: () {
                                            setRevealState(() {
                                              revealPassword = !revealPassword;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.x2),
                                  Text(
                                    'A senha nao e copiada para o clipboard por seguranca. O usuario devera altera-la no primeiro acesso.',
                                    style: AppTypography.caption.copyWith(
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                AppPrimaryButton(
                                  label: 'Entendido',
                                  onPressed: () => Navigator.pop(ctx2),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiService.extractErrorMessage(e))));
                    setDialogState(() => saving = false);
                  }
                },
              ),
            ],
          );
        });
      },
    );

    nomeCtrl.dispose();
    emailCtrl.dispose();
  }

  Widget _buildContent(dynamic conf) {
    switch (_selectedSection) {
      case 0: return _buildGeral(conf);
      case 1: return _buildFinanceiro(conf);
      case 2: return _buildIntegravel(conf);
      case 3: return _buildSeguranca();
      case 4: return _buildPacotes();
      case 5: return _buildCabines();
      default: return _buildGeral(conf);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncConf = ref.watch(configuracoesProvider);

    return AppScreenScaffold(
      currentRoute: AppRoutes.configuracoes,
      eyebrow: 'Ajustes da franquia',
      titleSerif: true,
      title: 'Configurações',
      subtitle: 'Gerencie sua franquia, integrações e segurança.',
      child: asyncConf.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(ApiService.extractErrorMessage(e))),
        data: (conf) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left sidebar nav (220px)
            Container(
              width: 220,
              decoration: BoxDecoration(
                color: context.colors.bgPage,
                border: Border(right: BorderSide(color: context.colors.borderSubtle)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.x5),
                  _NavItem(
                    icon: Icons.settings_outlined, label: 'Geral',
                    isActive: _selectedSection == 0,
                    onTap: () => setState(() => _selectedSection = 0),
                  ),
                  _NavItem(
                    icon: Icons.account_balance_wallet_outlined, label: 'Financeiro',
                    isActive: _selectedSection == 1,
                    onTap: () => setState(() => _selectedSection = 1),
                  ),
                  _NavItem(
                    icon: Icons.link, label: 'Integrações',
                    isActive: _selectedSection == 2,
                    onTap: () => setState(() => _selectedSection = 2),
                  ),
                  _NavItem(
                    icon: Icons.security_outlined, label: 'Segurança',
                    isActive: _selectedSection == 3,
                    onTap: () => setState(() => _selectedSection = 3),
                  ),
                  _NavItem(
                    icon: Icons.inventory_2_outlined, label: 'Pacotes',
                    isActive: _selectedSection == 4,
                    onTap: () => setState(() => _selectedSection = 4),
                  ),
                  _NavItem(
                    icon: Icons.video_camera_front_outlined, label: 'Cabines',
                    isActive: _selectedSection == 5,
                    onTap: () => setState(() => _selectedSection = 5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.x6),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildContent(conf),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Panels & helpers ─────────────────────────────────────────────────────

  Widget _buildPanel({
    required String title,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    required VoidCallback onSave,
    required List<Widget> children,
  }) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x6),
            child: AppCard(
              radius: AppRadius.xl,
              borderColor: context.colors.borderSubtle,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: AppTypography.h3)),
                        if (!isEditing)
                          IconButton(icon: Icon(Icons.edit_rounded, color: context.colors.textSecondary), onPressed: onEdit),
                      ],
                    ),
                    const Divider(height: 32),
                    ...children,
                    if (isEditing) ...[
                      const SizedBox(height: AppSpacing.x6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppSecondaryButton(onPressed: onCancel, label: 'Cancelar'),
                          const SizedBox(width: AppSpacing.x2),
                          AppPrimaryButton(onPressed: onSave, label: 'Salvar'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool enabled = true, bool obscureText = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x4),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.6,
        child: IgnorePointer(
          ignoring: !enabled,
          child: AppTextField(controller: ctrl, obscureText: obscureText, keyboardType: keyboardType, hint: label),
        ),
      ),
    );
  }

  Widget _idDisplay(String id) {
    final isEmpty = id.isEmpty || id == 'undefined';
    if (isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID da Franquia', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.x2),
            const AppBadge(label: 'ID não carregado', type: AppBadgeType.warning),
            const SizedBox(height: AppSpacing.x2),
            AppSecondaryButton(
              label: 'Recarregar', icon: Icons.refresh,
              onPressed: () => ref.read(configuracoesProvider.notifier).refresh(),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID da Franquia', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.x2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4, vertical: AppSpacing.x3),
            decoration: BoxDecoration(color: context.colors.bgPage, borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: context.colors.borderSubtle)),
            child: Row(
              children: [
                Expanded(child: Text(id, style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis)),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16), color: context.colors.textMuted,
                  tooltip: 'Copiar ID', padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  onPressed: () async {
                    final success = await ClipboardService.copy(id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(success ? 'ID copiado!' : 'Falha ao copiar — copie manualmente: $id')));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
      _uploadingLogo = true;
    });

    try {
      final name = picked.name.isNotEmpty ? picked.name : 'logo.jpg';
      final ext = name.split('.').last.toLowerCase();
      final mediaType = switch (ext) {
        'jpg' || 'jpeg' => DioMediaType('image', 'jpeg'),
        'png' => DioMediaType('image', 'png'),
        'webp' => DioMediaType('image', 'webp'),
        'gif' => DioMediaType('image', 'gif'),
        _ => DioMediaType('image', 'jpeg'),
      };
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: name, contentType: mediaType),
      });
      final resp = await ApiService.post<Map<String, dynamic>>('/configuracoes/logo', data: formData);
      final url = (resp.data as Map<String, dynamic>)['url'] as String;
      if (!mounted) return;
      setState(() => _logoCtrl.text = url);
    } catch (e) {
      if (!mounted) return;
      setState(() => _pickedImageBytes = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService.extractErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _uploadingLogo = false);
    }
  }

  Widget _logoUploadArea() {
    final url = _logoCtrl.text.trim();
    final hasUrl = url.isNotEmpty;
    final hasPreview = _pickedImageBytes != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Logotipo', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.x2),
          GestureDetector(
            onTap: _isEditingGeral && !_uploadingLogo ? _pickAndUploadLogo : null,
            child: SizedBox(
              width: 120, height: 120,
              child: _uploadingLogo
                  ? Container(
                      decoration: BoxDecoration(
                        color: context.colors.bgPage,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.colors.borderSubtle, width: 2),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : hasPreview || hasUrl
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              hasPreview
                                  ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                                  : Image.network(url, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        decoration: BoxDecoration(
                                          color: context.colors.bgPage,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: context.colors.borderSubtle, width: 2),
                                        ),
                                        child: Center(child: Icon(Icons.broken_image_outlined, size: 32, color: context.colors.textMuted)),
                                      )),
                              if (_isEditingGeral)
                                Positioned(
                                  bottom: 6, right: 6,
                                  child: Container(
                                    width: 26, height: 26,
                                    decoration: BoxDecoration(
                                      color: context.colors.textPrimary.withValues(alpha: 0.55),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.edit_rounded, size: 14, color: AppColors.textOnPrimary),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: context.colors.bgPage,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isEditingGeral ? AppColors.primary : context.colors.borderSubtle,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 32,
                                  color: _isEditingGeral ? AppColors.primary : context.colors.textMuted),
                              const SizedBox(height: AppSpacing.x1),
                              Text(
                                _isEditingGeral ? 'Toque para adicionar' : 'Sem logo',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 11,
                                  color: _isEditingGeral ? AppColors.primary : context.colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ),
          if (_isEditingGeral && !_uploadingLogo)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.x1),
              child: Text('JPEG, PNG ou WebP • máx. 5 MB',
                  style: AppTypography.caption.copyWith(color: context.colors.textMuted, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  // ─── Sections ──────────────────────────────────────────────────────────────

  Widget _buildGeral(dynamic conf) {
    if (!_isEditingGeral) {
      _nomeCtrl.text = conf.nome;
      _logoCtrl.text = conf.logoUrl ?? '';
      _metaCtrl.text = conf.metaDiariaGmv.toStringAsFixed(0);
    }
    return _buildPanel(
      title: 'Identidade da Franquia',
      isEditing: _isEditingGeral,
      onEdit: () => setState(() => _isEditingGeral = true),
      onCancel: () => setState(() {
        _isEditingGeral = false;
        _pickedImageBytes = null;
      }),
      onSave: () => _salvar({
        'nome': _nomeCtrl.text,
        'logo_url': _logoCtrl.text.isEmpty ? null : _logoCtrl.text,
        'meta_diaria_gmv': double.tryParse(_metaCtrl.text) ?? 10000,
      }, () => setState(() {
        _isEditingGeral = false;
        _pickedImageBytes = null;
      })),
      children: [
        _idDisplay(conf.id),
        _field('Nome da Franquia', _nomeCtrl, enabled: _isEditingGeral),
        _field('Meta Diária de GMV (R\$)', _metaCtrl,
            enabled: _isEditingGeral, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        _logoUploadArea(),
      ],
    );
  }

  Widget _buildFinanceiro(dynamic conf) {
    if (!_isEditingFin) {
      _asaasKeyCtrl.text = conf.hasAsaas ? (conf.asaasApiKeyHidden ?? '') : '';
      _asaasWalletCtrl.text = conf.asaasWalletId ?? '';
    }
    return _buildPanel(
      title: 'Integração Asaas (Split de Pagamentos)',
      isEditing: _isEditingFin,
      onEdit: () {
        setState(() {
          _isEditingFin = true;
          _asaasKeyCtrl.clear();
        });
      },
      onCancel: () => setState(() => _isEditingFin = false),
      onSave: _salvarFinanceiroSensivel,
      children: [
        _field(conf.hasAsaas && !_isEditingFin ? 'API Key (Oculta)' : 'Nova API Key', _asaasKeyCtrl,
            enabled: _isEditingFin, obscureText: true),
        _field('Wallet ID', _asaasWalletCtrl, enabled: _isEditingFin),
        if (conf.hasAsaas && !_isEditingFin)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.x4),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                const SizedBox(width: AppSpacing.x2),
                Text('Conexão Asaas configurada e protegida.',
                    style: AppTypography.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildIntegravel(dynamic conf) {
    if (!_isEditingTiktok) {
      _tiktokShopCtrl.text = conf.tiktokShopId ?? '';
    }
    final tiktokAsync = ref.watch(tiktokStatusProvider);
    final tiktok = tiktokAsync.valueOrNull;
    final isConnected = tiktok?.connected ?? conf.hasTiktok;

    return _buildPanel(
      title: 'Integração TikTok Shop',
      isEditing: _isEditingTiktok,
      onEdit: () => setState(() => _isEditingTiktok = true),
      onCancel: () => setState(() => _isEditingTiktok = false),
      onSave: () => _salvar(
        {if (_tiktokShopCtrl.text.isNotEmpty) 'tiktok_shop_id': _tiktokShopCtrl.text},
        () => setState(() => _isEditingTiktok = false),
      ),
      children: [
        // Status chip
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.x4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Conta TikTok', style: AppTypography.caption.copyWith(color: context.colors.textSecondary)),
                    const SizedBox(height: AppSpacing.x2),
                    tiktokAsync.when(
                      loading: () => const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (_, __) => const AppBadge(label: 'Erro ao verificar', type: AppBadgeType.warning, showDot: false),
                      data: (s) => s.connected
                          ? AppBadge(
                              label: s.expiresAt != null
                                  ? 'Conectado · Expira ${s.expiresAt!.day.toString().padLeft(2,'0')}/${s.expiresAt!.month.toString().padLeft(2,'0')}/${s.expiresAt!.year}'
                                  : 'Conectado',
                              type: AppBadgeType.success,
                            )
                          : const AppBadge(label: 'Desconectado', type: AppBadgeType.danger, showDot: false),
                    ),
                    if (tiktok?.userId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.x1),
                        child: Text('ID: ${tiktok!.userId}',
                            style: AppTypography.caption.copyWith(color: context.colors.textMuted)),
                      ),
                  ],
                ),
              ),
              if (isConnected)
                TextButton.icon(
                  icon: Icon(Icons.link_off, size: 16, color: AppColors.danger),
                  label: Text('Desconectar',
                      style: AppTypography.caption.copyWith(color: AppColors.danger)),
                  onPressed: () async {
                    await ref.read(tiktokStatusProvider.notifier).disconnect();
                    ref.invalidate(configuracoesProvider);
                  },
                ),
            ],
          ),
        ),

        // Botão OAuth (apenas quando desconectado)
        if (!isConnected)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.x4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isConnectingTiktok ? null : _conectarTikTok,
                icon: _isConnectingTiktok
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.open_in_new, size: 16),
                label: Text(_isConnectingTiktok ? 'Aguardando autorização...' : 'Conectar com TikTok'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF010101)),
                  foregroundColor: context.colors.textPrimary,
                ),
              ),
            ),
          ),

        // Shop ID
        _field('TikTok Shop ID', _tiktokShopCtrl, enabled: _isEditingTiktok),
      ],
    );
  }

  Future<void> _conectarTikTok() async {
    setState(() => _isConnectingTiktok = true);
    try {
      final resp = await ApiService.get('/tiktok/connect');
      final url = (resp.data as Map<String, dynamic>)['url'] as String;
      final uri = Uri.parse(url);
      if (uri.scheme != 'https') {
        throw const ApiException('URL de autorizacao invalida.');
      }
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Não foi possível abrir o navegador');
      }
      ref.read(tiktokStatusProvider.notifier).startPollingAfterOAuth();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Autorize o acesso no TikTok e volte para esta tela.'),
        duration: Duration(seconds: 8),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService.extractErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _isConnectingTiktok = false);
    }
  }

  Widget _buildSeguranca() {
    return _buildPanel(
      title: 'Alterar Senha',
      isEditing: _isEditingSeguranca,
      onEdit: () => setState(() => _isEditingSeguranca = true),
      onCancel: () {
        _senhaCtrl.clear();
        setState(() => _isEditingSeguranca = false);
      },
      onSave: _salvarNovaSenha,
      children: [
        _field('Nova Senha', _senhaCtrl, enabled: _isEditingSeguranca, obscureText: true),
      ],
    );
  }

  Widget _buildPacotes() {
    final pacotesAsync = ref.watch(pacotesProvider);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x6),
            child: AppCard(
              radius: AppRadius.xl,
              borderColor: context.colors.borderSubtle,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Pacotes de Serviço', style: AppTypography.h3)),
                        AppPrimaryButton(label: 'Novo Pacote', icon: Icons.add, onPressed: () => _abrirFormPacote()),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    Text('Defina os pacotes que serão oferecidos aos clientes.',
                        style: AppTypography.caption.copyWith(color: context.colors.textSecondary)),
                    const Divider(height: 32),
                    pacotesAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text(ApiService.extractErrorMessage(e))),
                      data: (pacotes) {
                        if (pacotes.isEmpty) return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.x6),
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 40, color: context.colors.textMuted),
                                const SizedBox(height: AppSpacing.x3),
                                Text('Nenhum pacote cadastrado.',
                                    style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary)),
                              ],
                            ),
                          ),
                        );
                        return Column(
                          children: pacotes.map((p) => _PacoteItem(
                            pacote: p,
                            onEdit: () => _abrirFormPacote(p),
                            onDesativar: p.ativo
                                ? () async { await ref.read(pacotesProvider.notifier).desativar(p.id); }
                                : null,
                          )).toList(),
                        );
                      },
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

  Widget _buildCabines() {
    final cabinesAsync = ref.watch(cabinesProvider);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x6),
            child: AppCard(
              radius: AppRadius.xl,
              borderColor: context.colors.borderSubtle,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Minhas Cabines', style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.x2),
                    Text('Configure o nome, tamanho e descrição de cada cabine da sua unidade.',
                        style: AppTypography.caption.copyWith(color: context.colors.textSecondary)),
                    const Divider(height: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppPrimaryButton(label: 'Nova Cabine', icon: Icons.add_rounded, onPressed: () => _mostrarFormCabine(context)),
                        const SizedBox(height: AppSpacing.x4),
                        cabinesAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text(ApiService.extractErrorMessage(e))),
                          data: (cabines) {
                            if (cabines.isEmpty) return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.x6),
                                child: Text('Nenhuma cabine encontrada.',
                                    style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary)),
                              ),
                            );
                            return Column(
                              children: cabines.map((c) => _CabineConfigItem(
                                cabine: c,
                                onSave: (nome, tamanho, descricao) async {
                                  await ref.read(cabinesProvider.notifier).atualizarCabine(c.id, {
                                    if (nome.isNotEmpty) 'nome': nome,
                                    if (tamanho.isNotEmpty) 'tamanho': tamanho,
                                    if (descricao.isNotEmpty) 'descricao': descricao,
                                  });
                                },
                                onDelete: () => _confirmarDeletar(context, c),
                              )).toList(),
                            );
                          },
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
}

// ─── Sidebar Nav Item ─────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x4, vertical: AppSpacing.x3),
        decoration: BoxDecoration(
          color: isActive ? context.colors.primarySoftBg : Colors.transparent,
          border: isActive ? Border(left: BorderSide(color: AppColors.primary, width: 3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? AppColors.primary : context.colors.textMuted),
            const SizedBox(width: AppSpacing.x3),
            Text(label, style: AppTypography.bodyMedium.copyWith(
              color: isActive ? AppColors.primary : context.colors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            )),
          ],
        ),
      ),
    );
  }
}

// ─── Pacote Item ──────────────────────────────────────────────────────────────

class _PacoteItem extends StatelessWidget {
  final Pacote pacote;
  final VoidCallback onEdit;
  final VoidCallback? onDesativar;

  const _PacoteItem({required this.pacote, required this.onEdit, this.onDesativar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x3),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.x4),
        shadow: const [],
        borderColor: context.colors.borderSubtle,
        child: Opacity(
          opacity: pacote.ativo ? 1.0 : 0.5,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(pacote.nome, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(width: AppSpacing.x2),
                        if (!pacote.ativo) const AppBadge(label: 'Inativo', type: AppBadgeType.neutral, showDot: false),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    Text('R\$ ${pacote.valor.toStringAsFixed(2)} / mês • ${pacote.horasIncluidas.toStringAsFixed(0)} h incluídas',
                        style: AppTypography.caption.copyWith(color: context.colors.textSecondary)),
                    if (pacote.descricao != null && pacote.descricao!.isNotEmpty)
                      Text(pacote.descricao!, style: AppTypography.caption.copyWith(color: context.colors.textMuted)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit_outlined, size: 18), color: context.colors.textSecondary, onPressed: onEdit),
              if (onDesativar != null) IconButton(icon: const Icon(Icons.delete_outline, size: 18), color: AppColors.danger,
                  tooltip: 'Desativar pacote', onPressed: onDesativar),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Cabine Config Item ───────────────────────────────────────────────────────

class _CabineConfigItem extends StatefulWidget {
  final Cabine cabine;
  final Future<void> Function(String nome, String tamanho, String descricao) onSave;
  final VoidCallback onDelete;

  const _CabineConfigItem({required this.cabine, required this.onSave, required this.onDelete});

  @override
  State<_CabineConfigItem> createState() => _CabineConfigItemState();
}

class _CabineConfigItemState extends State<_CabineConfigItem> {
  bool _editing = false;
  bool _saving = false;
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _tamanhoCtrl;
  late final TextEditingController _descCtrl;
  static const _tamanhoOptions = ['P', 'M', 'G', 'GG'];

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.cabine.nome ?? '');
    _tamanhoCtrl = TextEditingController(text: widget.cabine.tamanho ?? '');
    _descCtrl = TextEditingController(text: widget.cabine.descricao ?? '');
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _tamanhoCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    setState(() => _saving = true);
    try {
      await widget.onSave(_nomeCtrl.text.trim(), _tamanhoCtrl.text.trim(), _descCtrl.text.trim());
      if (!mounted) return;
      setState(() => _editing = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiService.extractErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x3),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.x4),
        shadow: const [],
        borderColor: context.colors.borderSubtle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(widget.cabine.numero.toString().padLeft(2, '0'),
                      style: AppTypography.caption.copyWith(color: AppColors.primary)),
                ),
                const SizedBox(width: AppSpacing.x3),
                Expanded(
                  child: Text(widget.cabine.nome ?? 'Cabine ${widget.cabine.numero.toString().padLeft(2, '0')}',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                ),
                if (!_editing) ...[
                  IconButton(icon: const Icon(Icons.edit_outlined, size: 18), color: context.colors.textSecondary,
                      onPressed: () => setState(() => _editing = true)),
                  IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 18), color: AppColors.danger,
                      tooltip: 'Deletar cabine', onPressed: widget.onDelete),
                ],
              ],
            ),
            if (_editing) ...[
              const SizedBox(height: AppSpacing.x3),
              AppTextField(controller: _nomeCtrl, hint: 'Nome da cabine'),
              const SizedBox(height: AppSpacing.x2),
              Row(
                children: [
                  Expanded(child: AppTextField(controller: _descCtrl, hint: 'Descrição (opcional)')),
                  const SizedBox(width: AppSpacing.x2),
                  SizedBox(
                    width: 80,
                    child: AppDropdown<String>(
                      value: _tamanhoCtrl.text.isEmpty ? null : _tamanhoCtrl.text,
                      hint: 'Tam.',
                      items: _tamanhoOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) { if (v != null) _tamanhoCtrl.text = v; },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x3),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppSecondaryButton(onPressed: () => setState(() => _editing = false), label: 'Cancelar'),
                  const SizedBox(width: AppSpacing.x2),
                  AppPrimaryButton(label: 'Salvar', isLoading: _saving, onPressed: _salvar),
                ],
              ),
            ] else if (widget.cabine.tamanho != null || widget.cabine.descricao != null) ...[
              const SizedBox(height: AppSpacing.x1),
              Text([if (widget.cabine.tamanho != null) 'Tamanho: ${widget.cabine.tamanho}',
                  if (widget.cabine.descricao != null) widget.cabine.descricao!].join(' • '),
                  style: AppTypography.caption.copyWith(color: context.colors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}
