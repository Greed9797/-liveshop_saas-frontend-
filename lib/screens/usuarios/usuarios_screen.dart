import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/usuario.dart';
import '../../providers/usuarios_provider.dart';
import '../../services/api_service.dart';
import '../../design_system/design_system.dart';
import '../../widgets/app_scaffold.dart';
import '../../routes/app_routes.dart';
import 'criar_usuario_dialog.dart';
import '../../widgets/temp_password_dialog.dart';

class UsuariosScreen extends ConsumerStatefulWidget {
  const UsuariosScreen({super.key});

  @override
  ConsumerState<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends ConsumerState<UsuariosScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.usuarios,
      child: Column(
        children: [
          _Header(tab: _tab),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [
                _TabUsuarios(papeis: ['gerente', 'gerente_comercial', 'financeiro', 'operacional']),
                _TabUsuarios(papeis: ['apresentador', 'apresentadora']),
                _TabUsuarios(papeis: ['cliente_parceiro']),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tab});
  final TabController tab;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x6, AppSpacing.x6, AppSpacing.x6, AppSpacing.x2),
            child: Row(
              children: [
                Expanded(
                  child: Text('Equipe', style: AppTypography.h2),
                ),
                Builder(builder: (ctx) => FilledButton.icon(
                  onPressed: () => showDialog<void>(
                    context: ctx,
                    builder: (_) => const CriarUsuarioDialog(),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Novo usuário'),
                )),
              ],
            ),
          ),
          TabBar(
            controller: tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Internos'),
              Tab(text: 'Apresentadores'),
              Tab(text: 'Clientes'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabUsuarios extends ConsumerWidget {
  const _TabUsuarios({required this.papeis});
  final List<String> papeis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsers = ref.watch(usuariosProvider);

    return asyncUsers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(ApiService.extractErrorMessage(e),
            style: TextStyle(color: AppColors.danger)),
      ),
      data: (users) {
        final filtered = users
            .where((u) => papeis.contains(u.papel))
            .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline,
                    size: 48, color: AppColors.textMuted),
                const SizedBox(height: AppSpacing.x3),
                Text(
                  'Nenhum usuário nesta categoria',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.x4),
          itemCount: filtered.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.x2),
          itemBuilder: (context, i) =>
              _UsuarioCard(usuario: filtered[i]),
        );
      },
    );
  }
}

class _UsuarioCard extends ConsumerWidget {
  const _UsuarioCard({required this.usuario});
  final Usuario usuario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: AppRadius.lgR,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Text(
              usuario.nome.isNotEmpty
                  ? usuario.nome[0].toUpperCase()
                  : '?',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(usuario.nome, style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                )),
                Text(usuario.email,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    )),
              ],
            ),
          ),
          _PapelChip(papel: usuario.papel),
          const SizedBox(width: AppSpacing.x3),
          if (!usuario.ativo)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x2,
                vertical: AppSpacing.x1,
              ),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: AppRadius.fullR,
              ),
              child: Text(
                'Inativo',
                style: AppTypography.caption
                    .copyWith(color: AppColors.danger),
              ),
            ),
          const SizedBox(width: AppSpacing.x2),
          _Acoes(usuario: usuario),
        ],
      ),
    );
  }
}

class _PapelChip extends StatelessWidget {
  const _PapelChip({required this.papel});
  final String papel;

  static const _labels = {
    'gerente': 'Gerente',
    'gerente_comercial': 'Ger. Comercial',
    'financeiro': 'Financeiro',
    'operacional': 'Operacional',
    'apresentador': 'Apresentador',
    'apresentadora': 'Apresentadora',
    'cliente_parceiro': 'Cliente',
    'franqueado': 'Franqueado',
    'franqueador_master': 'Master',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: AppSpacing.x1,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgMuted,
        borderRadius: AppRadius.fullR,
      ),
      child: Text(
        _labels[papel] ?? papel,
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Acoes extends ConsumerWidget {
  const _Acoes({required this.usuario});
  final Usuario usuario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_Acao>(
      icon: Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
      onSelected: (acao) => _handle(context, ref, acao),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: _Acao.reset,
          child: Row(children: [
            Icon(Icons.lock_reset, size: 18),
            SizedBox(width: 8),
            Text('Resetar senha'),
          ]),
        ),
        PopupMenuItem(
          value: usuario.ativo ? _Acao.desativar : _Acao.ativar,
          child: Row(children: [
            Icon(
              usuario.ativo ? Icons.person_off : Icons.person,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(usuario.ativo ? 'Desativar' : 'Reativar'),
          ]),
        ),
      ],
    );
  }

  Future<void> _handle(
      BuildContext context, WidgetRef ref, _Acao acao) async {
    try {
      if (acao == _Acao.reset) {
        final senha =
            await ref.read(usuariosProvider.notifier).resetSenha(usuario.id);
        if (!context.mounted) return;
        await TempPasswordDialog.show(
          context,
          nome: usuario.nome,
          email: usuario.email,
          senhaTemporaria: senha,
        );
      } else {
        final ativo = acao == _Acao.ativar;
        await ref
            .read(usuariosProvider.notifier)
            .atualizar(usuario.id, {'ativo': ativo});
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ativo ? 'Usuário reativado' : 'Usuário desativado'),
        ));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ApiService.extractErrorMessage(e)),
        backgroundColor: AppColors.danger,
      ));
    }
  }
}

enum _Acao { reset, desativar, ativar }
