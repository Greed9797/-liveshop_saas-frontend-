import '../providers/billing_alert_provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_mode_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_extension.dart';
import '../theme/app_typography.dart';
import '../providers/boletos_provider.dart';

class AppScaffold extends ConsumerWidget {
  final Widget child;
  final String currentRoute;
  final String? userName;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
    this.userName = 'FVC Promoções',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(billingAlertProvider, (prev, next) {
      if (next.valueOrNull != null) {
        final alert = next.valueOrNull!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppColors.primaryOrange),
                  const SizedBox(width: 8),
                  const Text('Fatura Disponível'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seu boleto referente aos serviços e comissões do período foi emitido.'),
                  const SizedBox(height: 12),
                  Text('Valor: ' + NumberFormat.simpleCurrency(locale: 'pt_BR').format(alert.valor), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              actions: [
                if (alert.asaasPixCopiaCola != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen),
                    icon: const Icon(Icons.pix_rounded, size: 16, color: AppColors.white),
                    label: const Text('Copiar PIX', style: TextStyle(color: AppColors.white)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: alert.asaasPixCopiaCola!));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código PIX copiado!')));
                      ref.read(billingAlertProvider.notifier).marcarVisto(alert.id);
                      Navigator.pop(ctx);
                    },
                  ),
                TextButton(
                  onPressed: () {
                    ref.read(billingAlertProvider.notifier).marcarVisto(alert.id);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        });
      }
    });

    final boletosAsync = ref.watch(boletosProvider);
    final authState = ref.watch(authProvider);
    final isFranqueadorMaster = authState.user?.papel == 'franqueador_master';
    final isClienteParceiro = authState.user?.papel == 'cliente_parceiro';
    final displayName = authState.user?.nome ?? userName ?? 'Livelab';
    final boletosCount = boletosAsync.valueOrNull
            ?.where((b) => b.status == 'vencido' || b.status == 'pendente')
            .length ??
        0;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPermanentMenu(
                  context,
                  boletosCount,
                  isFranqueadorMaster,
                  isClienteParceiro,
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildHeader(
                        context,
                        ref,
                        isDesktop: true,
                        displayName: displayName,
                        isFranqueadorMaster: isFranqueadorMaster,
                        isClienteParceiro: isClienteParceiro,
                      ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildHeader(
                context,
                ref,
                isDesktop: false,
                displayName: displayName,
                isFranqueadorMaster: isFranqueadorMaster,
                isClienteParceiro: isClienteParceiro,
              ),
              Expanded(child: child),
            ],
          );
        },
      ),
      drawer: MediaQuery.of(context).size.width < 800
          ? _buildDrawer(
              context, boletosCount, isFranqueadorMaster, isClienteParceiro)
          : null,
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref, {
    required bool isDesktop,
    required String displayName,
    required bool isFranqueadorMaster,
    required bool isClienteParceiro,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.divider, width: 1),
        ),
      ),
      padding:
          EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (!isDesktop) ...[
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: context.colors.textSecondary),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const SizedBox(width: 8),
            ],
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryOrange,
              child: Text(
                displayName.length >= 2
                    ? displayName.substring(0, 2).toUpperCase()
                    : 'LS',
                style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.surfaceWhite, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Olá, $displayName!',
                    style: AppTypography.bodyLarge.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isClienteParceiro
                        ? 'Cliente Parceiro'
                        : isFranqueadorMaster
                            ? 'Franqueador Master'
                            : 'Franqueado Livelab',
                    style: AppTypography.caption
                        .copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
            Consumer(
              builder: (context, ref, _) {
                final mode = ref.watch(themeModeProvider);
                return IconButton(
                  icon: Icon(
                    mode == ThemeMode.dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: context.colors.textTertiary,
                    size: 20,
                  ),
                  tooltip: mode == ThemeMode.dark ? 'Modo claro' : 'Modo escuro',
                  onPressed: () {
                    ref.read(themeModeProvider.notifier).state =
                        mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                  },
                );
              },
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.notifications_none_rounded,
                  color: context.colors.textTertiary),
              tooltip: 'Notificações',
              offset: const Offset(0, 40),
              color: context.colors.surface,
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Nenhuma notificação no momento',
                        style: AppTypography.caption
                            .copyWith(color: context.colors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isDesktop) ...[
              const SizedBox(width: 16),
              Image.asset('assets/images/logo.png', height: 32),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    int boletosCount,
    bool isFranqueadorMaster,
    bool isClienteParceiro,
  ) {
    return Drawer(
      backgroundColor: context.colors.sidebarBg,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Image(
                  image: AssetImage('assets/images/logo.png'), height: 40),
            ),
            Divider(color: context.colors.divider, height: 1),
            Expanded(
                child: _MenuContent(
              currentRoute: currentRoute,
              boletosCount: boletosCount,
              isFranqueadorMaster: isFranqueadorMaster,
              isClienteParceiro: isClienteParceiro,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPermanentMenu(
    BuildContext context,
    int boletosCount,
    bool isFranqueadorMaster,
    bool isClienteParceiro,
  ) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: context.colors.sidebarBg,
        border: Border(
          right: BorderSide(color: context.colors.divider, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Image(
                  image: AssetImage('assets/images/logo.png'), height: 40),
            ),
          ),
          Expanded(
              child: _MenuContent(
            currentRoute: currentRoute,
            boletosCount: boletosCount,
            isFranqueadorMaster: isFranqueadorMaster,
            isClienteParceiro: isClienteParceiro,
          )),
        ],
      ),
    );
  }
}

class _MenuContent extends ConsumerWidget {
  final String currentRoute;
  final int boletosCount;
  final bool isFranqueadorMaster;
  final bool isClienteParceiro;

  const _MenuContent({
    required this.currentRoute,
    required this.boletosCount,
    required this.isFranqueadorMaster,
    required this.isClienteParceiro,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _MenuItem(
            icon: Icons.home_rounded,
            label: 'Home',
            route: isClienteParceiro ? AppRoutes.cliente : AppRoutes.home,
            isSelected: currentRoute == AppRoutes.home ||
                currentRoute == AppRoutes.cliente),
        if (isClienteParceiro) ...[
          _MenuItem(
              icon: Icons.history_rounded,
              label: 'Histórico de Vendas',
              route: AppRoutes.clienteHistorico,
              isSelected: currentRoute == AppRoutes.clienteHistorico),
          _MenuItem(
              icon: Icons.videocam_rounded,
              label: 'Minhas Cabines',
              route: AppRoutes.clienteCabines,
              isSelected: currentRoute == AppRoutes.clienteCabines ||
                  currentRoute == AppRoutes.clienteCabineDetail),
        ],
        if (!isClienteParceiro) ...[
          _MenuItem(
              icon: Icons.videocam_rounded,
              label: 'Cabines',
              route: AppRoutes.cabines,
              isSelected: currentRoute == AppRoutes.cabines ||
                  currentRoute == AppRoutes.cabineDetail),
          _MenuItem(
              icon: Icons.event_note_rounded,
              label: 'Solicitações',
              route: AppRoutes.solicitacoes,
              isSelected: currentRoute == AppRoutes.solicitacoes),
          _MenuItem(
              icon: Icons.map_rounded,
              label: 'Vendas em Andamento',
              route: AppRoutes.vendas,
              isSelected: currentRoute == AppRoutes.vendas ||
                  currentRoute == AppRoutes.cadastroCliente ||
                  currentRoute == AppRoutes.contrato ||
                  currentRoute == AppRoutes.analiseCredito),
          _MenuItem(
              icon: Icons.bar_chart_rounded,
              label: 'Análise de Vendas',
              route: AppRoutes.analise,
              isSelected: currentRoute == AppRoutes.analise),
          _MenuItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Financeiro',
              route: AppRoutes.financeiro,
              isSelected: currentRoute == AppRoutes.financeiro),
          if (isFranqueadorMaster) ...[
            _MenuItem(
              icon: Icons.fact_check_rounded,
              label: 'Auditoria de Contratos',
              route: AppRoutes.auditoriaContratos,
              isSelected: currentRoute == AppRoutes.auditoriaContratos,
            ),
          ],
          _MenuItem(
            icon: Icons.insights_rounded,
            label: 'Analytics',
            route: AppRoutes.analyticsDashboard,
            isSelected: currentRoute == AppRoutes.analyticsDashboard,
          ),
          _MenuItem(
              icon: Icons.receipt_long_rounded,
              label: 'Meus Boletos',
              route: AppRoutes.boletos,
              isSelected: currentRoute == AppRoutes.boletos,
              badge: boletosCount > 0 ? '$boletosCount' : null),
          _MenuItem(
              icon: Icons.people_alt_rounded,
              label: 'Clientes / Leads',
              route: AppRoutes.clientesLeads,
              isSelected: currentRoute == AppRoutes.clientesLeads),
          _MenuItem(
              icon: Icons.workspace_premium_rounded,
              label: 'Programa de Excelência',
              route: AppRoutes.excelencia,
              isSelected: currentRoute == AppRoutes.excelencia),
        ],
        _MenuItem(
            icon: Icons.menu_book_rounded,
            label: 'Manuais',
            route: AppRoutes.manuais,
            isSelected: currentRoute == AppRoutes.manuais),
        if (!isClienteParceiro) ...[
          _MenuItem(
              icon: Icons.handshake_rounded,
              label: 'Recomendações',
              route: AppRoutes.recomendacoes,
              isSelected: currentRoute == AppRoutes.recomendacoes),
          _MenuItem(
              icon: Icons.settings_outlined,
              label: 'Configurações',
              route: AppRoutes.configuracoes,
              isSelected: currentRoute == AppRoutes.configuracoes),
        ],
        Divider(color: context.colors.divider, height: 32),
        _MenuItem(
          icon: Icons.logout_rounded,
          label: 'Sair',
          route: AppRoutes.login,
          isSelected: false,
          onTap: () {
            ref.read(authProvider.notifier).logout();
          },
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? route;
  final bool isSelected;
  final String? badge;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.route,
    required this.isSelected,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isSelected ? colors.sidebarActiveText : colors.sidebarInactiveText;
    final bgColor = isSelected ? colors.sidebarActiveBg : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        // No left border accent — pill background is the active indicator
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hoverColor: colors.sidebarHover,
        leading: Icon(icon, color: color, size: 22),
        title: Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: colors.primary, shape: BoxShape.circle),
                child: Text(badge!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              )
            : null,
        onTap: () {
          if (onTap != null) {
            onTap!();
            return;
          }
          if (route != null && route != AppRoutes.login) {
            Navigator.pushReplacementNamed(context, route!);
          }
        },
      ),
    );
  }
}
