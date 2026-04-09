import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/configuracoes_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';

class ConfiguracoesScreen extends ConsumerStatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  ConsumerState<ConfiguracoesScreen> createState() =>
      _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends ConsumerState<ConfiguracoesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  final _nomeCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  final _metaCtrl = TextEditingController();
  final _asaasKeyCtrl = TextEditingController();
  final _asaasWalletCtrl = TextEditingController();
  final _tiktokKeyCtrl = TextEditingController();
  final _tiktokShopCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  bool _isEditingGeral = false;
  bool _isEditingFin = false;
  bool _isEditingTiktok = false;
  bool _isEditingSeguranca = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nomeCtrl.dispose();
    _logoCtrl.dispose();
    _metaCtrl.dispose();
    _asaasKeyCtrl.dispose();
    _asaasWalletCtrl.dispose();
    _tiktokKeyCtrl.dispose();
    _tiktokShopCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar(
      Map<String, dynamic> payload, VoidCallback onFinish) async {
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
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncConf = ref.watch(configuracoesProvider);

    return AppScaffold(
      currentRoute: AppRoutes.configuracoes,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.compactPadding),
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Configurações', style: AppTypography.h1),
                const SizedBox(height: AppSpacing.xs),
                Text('Gerencie sua franquia, integrações e segurança',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.lg),
                TabBar(
                  controller: _tabCtrl,
                  isScrollable: true,
                  labelColor: AppColors.primaryOrange,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryOrange,
                  tabs: const [
                    Tab(text: 'Geral'),
                    Tab(text: 'Financeiro'),
                    Tab(text: 'Integrações'),
                    Tab(text: 'Segurança'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: asyncConf.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (conf) {
                return TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildGeral(conf),
                    _buildFinanceiro(conf),
                    _buildIntegravel(conf),
                    _buildSeguranca(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
      onCancel: () => setState(() => _isEditingGeral = false),
      onSave: () => _salvar({
        'nome': _nomeCtrl.text,
        'logo_url': _logoCtrl.text.isEmpty ? null : _logoCtrl.text,
        'meta_diaria_gmv': double.tryParse(_metaCtrl.text) ?? 10000,
      }, () => setState(() => _isEditingGeral = false)),
      children: [
        _field('Nome da Franquia', _nomeCtrl, enabled: _isEditingGeral),
        _field('Meta Diária de GMV (R\$)', _metaCtrl,
            enabled: _isEditingGeral,
            keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        _field('URL do Logotipo (Opcional)', _logoCtrl,
            enabled: _isEditingGeral),
        if (conf.logoUrl != null &&
            conf.logoUrl!.isNotEmpty &&
            !_isEditingGeral)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Logo atual:', style: AppTypography.caption),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gray300),
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: Image.network(conf.logoUrl!,
                      errorBuilder: (_, __, ___) => const Padding(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            child: Text('Imagem indisponível'),
                          )),
                ),
              ],
            ),
          ),
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
          _asaasKeyCtrl.clear(); // forçar digitar a chave inteira
        });
      },
      onCancel: () => setState(() => _isEditingFin = false),
      onSave: () => _salvar({
        if (_asaasKeyCtrl.text.isNotEmpty) 'asaas_api_key': _asaasKeyCtrl.text,
        if (_asaasWalletCtrl.text.isNotEmpty)
          'asaas_wallet_id': _asaasWalletCtrl.text,
      }, () => setState(() => _isEditingFin = false)),
      children: [
        _field(
            conf.hasAsaas && !_isEditingFin
                ? 'API Key (Oculta)'
                : 'Nova API Key',
            _asaasKeyCtrl,
            enabled: _isEditingFin,
            obscureText: true),
        _field('Wallet ID', _asaasWalletCtrl, enabled: _isEditingFin),
        if (conf.hasAsaas && !_isEditingFin)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.successGreen, size: 16),
                const SizedBox(width: AppSpacing.sm),
                Text('Conexão Asaas configurada e protegida.',
                    style: AppTypography.labelSmall.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          )
      ],
    );
  }

  Widget _buildIntegravel(dynamic conf) {
    if (!_isEditingTiktok) {
      _tiktokKeyCtrl.text = conf.hasTiktok ? '********' : '';
      _tiktokShopCtrl.text = conf.tiktokShopId ?? '';
    }

    return _buildPanel(
      title: 'Integração TikTok Shop',
      isEditing: _isEditingTiktok,
      onEdit: () {
        setState(() {
          _isEditingTiktok = true;
          _tiktokKeyCtrl.clear();
        });
      },
      onCancel: () => setState(() => _isEditingTiktok = false),
      onSave: () => _salvar({
        if (_tiktokKeyCtrl.text.isNotEmpty)
          'tiktok_access_token': _tiktokKeyCtrl.text,
        if (_tiktokShopCtrl.text.isNotEmpty)
          'tiktok_shop_id': _tiktokShopCtrl.text,
      }, () => setState(() => _isEditingTiktok = false)),
      children: [
        _field('Access Token', _tiktokKeyCtrl,
            enabled: _isEditingTiktok, obscureText: true),
        _field('Shop ID', _tiktokShopCtrl, enabled: _isEditingTiktok),
      ],
    );
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
      onSave: () {
        if (_senhaCtrl.text.length < 6) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('A senha deve ter no mínimo 6 caracteres.')));
          return;
        }
        _salvar({'nova_senha': _senhaCtrl.text}, () {
          _senhaCtrl.clear();
          setState(() => _isEditingSeguranca = false);
        });
      },
      children: [
        _field('Nova Senha', _senhaCtrl,
            enabled: _isEditingSeguranca, obscureText: true),
      ],
    );
  }

  Widget _buildPanel({
    required String title,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    required VoidCallback onSave,
    required List<Widget> children,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: AppCard(
            borderRadius: AppRadius.xl,
            borderColor: AppColors.gray200,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: AppTypography.h3),
                      if (!isEditing)
                        IconButton(
                            icon: const Icon(Icons.edit_rounded,
                                color: AppColors.textSecondary),
                            onPressed: onEdit),
                    ],
                  ),
                  const Divider(height: 32),
                  ...children,
                  if (isEditing) ...[
                    const SizedBox(height: AppSpacing.x2l),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: onCancel,
                            child: const Text('Cancelar')),
                        const SizedBox(width: AppSpacing.sm),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange),
                          onPressed: onSave,
                          child: Text('Salvar',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.white)),
                        ),
                      ],
                    ),
                  ],
                ],
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
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: !enabled,
          fillColor: enabled ? Colors.transparent : AppColors.gray50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        ),
      ),
    );
  }
}
