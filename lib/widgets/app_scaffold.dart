import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/billing_alert_provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_mode_provider.dart';
import '../routes/app_routes.dart';
import '../design_system/design_system.dart';
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(PhosphorIconsBold.receipt, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Fatura Disponível'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'Seu boleto referente aos serviços e comissões do período foi emitido.'),
                  const SizedBox(height: 12),
                  Text(
                    'Valor: ${NumberFormat.simpleCurrency(locale: 'pt_BR').format(alert.valor)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                if (alert.asaasPixCopiaCola != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success),
                    icon: Icon(PhosphorIcons.copy(),
                        size: 16, color: Colors.white),
                    label: const Text('Copiar PIX',
                        style: TextStyle(color: AppColors.textOnPrimary)),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: alert.asaasPixCopiaCola!),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Código PIX copiado!')),
                      );
                      ref
                          .read(billingAlertProvider.notifier)
                          .marcarVisto(alert.id);
                      Navigator.pop(ctx);
                    },
                  ),
                TextButton(
                  onPressed: () {
                    ref
                        .read(billingAlertProvider.notifier)
                        .marcarVisto(alert.id);
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
    final isApresentador = authState.user?.papel == 'apresentador';
    final isGerente = authState.user?.papel == 'gerente';
    final displayName = authState.user?.nome ?? userName ?? 'Livelab';
    final boletosCount = boletosAsync.valueOrNull
            ?.where((b) => b.status == 'vencido' || b.status == 'pendente')
            .length ??
        0;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isMobile = width < 800;
          final isTablet = width >= 800 && width < 1100;

          if (!isMobile) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPermanentMenu(
                  context,
                  boletosCount,
                  isFranqueadorMaster,
                  isClienteParceiro,
                  isApresentador,
                  isGerente,
                  compact: isTablet,
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
                        isApresentador: isApresentador,
                        isGerente: isGerente,
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
                isApresentador: isApresentador,
                isGerente: isGerente,
              ),
              Expanded(child: child),
            ],
          );
        },
      ),
      drawer: MediaQuery.of(context).size.width < 800
          ? _buildDrawer(context, boletosCount, isFranqueadorMaster,
              isClienteParceiro, isApresentador, isGerente)
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
    required bool isApresentador,
    required bool isGerente,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: 16,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (!isDesktop) ...[
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(PhosphorIcons.list(),
                      color: AppColors.textSecondary),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const SizedBox(width: 8),
            ],
            AvatarGradientTopbar(
              initials: displayName.length >= 2
                  ? displayName.substring(0, 2).toUpperCase()
                  : 'LS',
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
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isClienteParceiro
                        ? 'Cliente Parceiro'
                        : isFranqueadorMaster
                            ? 'Franqueador Master'
                            : isApresentador
                                ? 'Apresentador'
                                : isGerente
                                    ? 'Gerente'
                                    : 'Franqueado Livelab',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Consumer(
              builder: (context, ref, _) {
                final mode = ref.watch(themeModeProvider);
                return IconButton(
                  icon: Icon(
                    mode == ThemeMode.dark
                        ? PhosphorIcons.sun()
                        : PhosphorIcons.moon(),
                    color: AppColors.textSecondary,
                  ),
                  tooltip:
                      mode == ThemeMode.dark ? 'Modo claro' : 'Modo escuro',
                  onPressed: () {
                    ref.read(themeModeProvider.notifier).state =
                        mode == ThemeMode.dark
                            ? ThemeMode.light
                            : ThemeMode.dark;
                  },
                );
              },
            ),
            PopupMenuButton<String>(
              icon: Icon(PhosphorIcons.bell(), color: AppColors.textMuted),
              tooltip: 'Notificações',
              offset: const Offset(0, 40),
              color: AppColors.bgCard,
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Nenhuma notificação no momento',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    bool isApresentador,
    bool isGerente,
  ) {
    return Drawer(
      backgroundColor: AppColors.bgSidebar,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: _Logo(),
            ),
            Divider(color: AppColors.borderLight, height: 1),
            Expanded(
                child: _MenuContent(
              currentRoute: currentRoute,
              boletosCount: boletosCount,
              isFranqueadorMaster: isFranqueadorMaster,
              isClienteParceiro: isClienteParceiro,
              isApresentador: isApresentador,
              isGerente: isGerente,
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
    bool isApresentador,
    bool isGerente, {
    bool compact = false,
  }) {
    return Container(
      width: compact ? 68 : 220,
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        border: Border(
          right: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: compact
                  ? CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.bgMuted,
                      child:
                          Icon(PhosphorIcons.house(), color: AppColors.primary),
                    )
                  : const _Logo(),
            ),
          ),
          Expanded(
              child: _MenuContent(
            currentRoute: currentRoute,
            boletosCount: boletosCount,
            isFranqueadorMaster: isFranqueadorMaster,
            isClienteParceiro: isClienteParceiro,
            isApresentador: isApresentador,
            isGerente: isGerente,
            compact: compact,
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
  final bool isApresentador;
  final bool isGerente;
  final bool compact;

  const _MenuContent({
    required this.currentRoute,
    required this.boletosCount,
    required this.isFranqueadorMaster,
    required this.isClienteParceiro,
    required this.isApresentador,
    required this.isGerente,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isFranqueadorMaster) {
      final masterItems = <_MenuItem>[
        _MenuItem(
          icon: PhosphorIcons.gauge(),
          label: 'Painel Master',
          route: AppRoutes.masterDashboard,
          isSelected: currentRoute == AppRoutes.masterDashboard ||
              currentRoute == AppRoutes.franqueado,
          compact: compact,
        ),
        _MenuItem(
          icon: PhosphorIcons.buildings(),
          label: 'Unidades',
          route: AppRoutes.masterUnits,
          isSelected: currentRoute == AppRoutes.masterUnits,
          compact: compact,
        ),
        _MenuItem(
          icon: PhosphorIcons.chartLineUp(),
          label: 'Consolidado',
          route: AppRoutes.masterConsolidated,
          isSelected: currentRoute == AppRoutes.masterConsolidated,
          compact: compact,
        ),
        _MenuItem(
          icon: PhosphorIcons.usersThree(),
          label: 'CRM',
          route: AppRoutes.masterCrm,
          isSelected: currentRoute == AppRoutes.masterCrm,
          compact: compact,
        ),
        _MenuItem(
          icon: PhosphorIcons.gear(),
          label: 'Configurações',
          route: AppRoutes.configuracoes,
          isSelected: currentRoute == AppRoutes.configuracoes,
          compact: compact,
        ),
        _MenuItem(
          icon: PhosphorIcons.signOut(),
          label: 'Sair',
          isSelected: false,
          compact: compact,
          onTap: () => ref.read(authProvider.notifier).logout(),
        ),
      ];
      return ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        children: masterItems,
      );
    }

    final homeRoute = isClienteParceiro
        ? AppRoutes.cliente
        : isApresentador
            ? AppRoutes.cabines
            : AppRoutes.home;

    final items = <_MenuItem>[
      _MenuItem(
        icon: PhosphorIcons.house(),
        label: isApresentador ? 'Cabines' : 'Home',
        route: homeRoute,
        isSelected: currentRoute == homeRoute,
        compact: compact,
      ),
      if (isClienteParceiro) ...[
        _MenuItem(
          icon: PhosphorIcons.chartBar(),
          label: 'Dashboard',
          route: AppRoutes.clienteDashboard,
          isSelected: currentRoute == AppRoutes.clienteDashboard,
          compact: compact,
        ),
        _MenuItem(
          icon: PhosphorIcons.clockCounterClockwise(),
          label: 'Histórico de Lives',
          route: AppRoutes.clienteHistorico,
          isSelected: currentRoute == AppRoutes.clienteHistorico,
          compact: compact,
        ),
      ],
      if (!isClienteParceiro && !isApresentador)
        _MenuItem(
          icon: PhosphorIcons.videoCamera(),
          label: 'Cabines',
          route: AppRoutes.cabines,
          isSelected: currentRoute == AppRoutes.cabines,
          compact: compact,
        ),
      if (!isClienteParceiro && !isApresentador)
        _MenuItem(
          icon: PhosphorIcons.calendarBlank(),
          label: 'Agendamentos',
          route: AppRoutes.agendamentos,
          isSelected: currentRoute == AppRoutes.agendamentos ||
              currentRoute == AppRoutes.solicitacoes,
          compact: compact,
        ),
      if (!isClienteParceiro && !isApresentador)
        _MenuItem(
          icon: PhosphorIcons.shoppingCart(),
          label: 'Vendas em Andamento',
          route: AppRoutes.vendas,
          isSelected: currentRoute == AppRoutes.vendas,
          compact: compact,
        ),
      if (!isClienteParceiro && !isApresentador && !isGerente)
        _MenuItem(
          icon: PhosphorIcons.wallet(),
          label: 'Financeiro',
          route: AppRoutes.financeiro,
          isSelected: currentRoute == AppRoutes.financeiro,
          compact: compact,
        ),
      if (!isClienteParceiro)
        _MenuItem(
          icon: PhosphorIcons.chartLineUp(),
          label: 'Analytics',
          route: AppRoutes.analyticsDashboard,
          isSelected: currentRoute == AppRoutes.analyticsDashboard,
          compact: compact,
        ),
      if (!isApresentador && !isGerente)
        _MenuItem(
          icon: PhosphorIcons.receipt(),
          label: 'Meus boletos',
          route: AppRoutes.boletos,
          isSelected: currentRoute == AppRoutes.boletos,
          badge: boletosCount > 0 ? '$boletosCount' : null,
          compact: compact,
        ),
      if (!isClienteParceiro && !isApresentador)
        _MenuItem(
          icon: PhosphorIcons.usersThree(),
          label: 'Clientes/Leads',
          route: AppRoutes.clientesLeads,
          isSelected: currentRoute == AppRoutes.clientesLeads,
          compact: compact,
        ),
      if (!isClienteParceiro && !isApresentador)
        _MenuItem(
          icon: PhosphorIcons.star(),
          label: 'Programa de Excelência',
          route: AppRoutes.excelencia,
          isSelected: currentRoute == AppRoutes.excelencia,
          compact: compact,
        ),
      _MenuItem(
        icon: PhosphorIcons.bookOpen(),
        label: 'Base de Conhecimento',
        route: AppRoutes.baseConhecimento,
        isSelected: currentRoute == AppRoutes.baseConhecimento ||
            currentRoute == AppRoutes.manuais,
        compact: compact,
      ),
      if (!isClienteParceiro && !isApresentador)
        _MenuItem(
          icon: PhosphorIcons.handshake(),
          label: 'Recomendações',
          route: AppRoutes.recomendacoes,
          isSelected: currentRoute == AppRoutes.recomendacoes,
          compact: compact,
        ),
      if (!isClienteParceiro && !isApresentador && !isGerente)
        _MenuItem(
          icon: PhosphorIcons.gear(),
          label: 'Configurações',
          route: AppRoutes.configuracoes,
          isSelected: currentRoute == AppRoutes.configuracoes,
          compact: compact,
        ),
      _MenuItem(
        icon: PhosphorIcons.signOut(),
        label: 'Sair',
        isSelected: false,
        compact: compact,
        onTap: () => ref.read(authProvider.notifier).logout(),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      children: items,
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
  final bool compact;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.route,
    required this.isSelected,
    this.badge,
    this.onTap,
    this.compact = false,
  });

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    if (route != null && route != AppRoutes.login) {
      Navigator.pushReplacementNamed(context, route!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;
    final bgColor = isSelected ? AppColors.bgMuted : Colors.transparent;

    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _handleTap(context),
            hoverColor: AppColors.bgMuted,
            child: Tooltip(
              message: label,
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, color: color, size: 24),
                    if (badge != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Stack(
        children: [
          if (isSelected)
            Positioned(
              left: -12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              hoverColor: AppColors.bgMuted,
              leading: Icon(icon, color: color, size: 24),
              title: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
              trailing: badge != null
                  ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: Text(badge!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    )
                  : null,
              onTap: () => _handleTap(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'Live',
          style: AppTypography.h2.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 26,
            letterSpacing: -0.04,
          ),
        ),
        Text(
          'ab',
          style: AppTypography.h2.copyWith(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w800,
            fontSize: 26,
            letterSpacing: -0.04,
          ),
        ),
        Text(
          '.',
          style: AppTypography.h2.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 26,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
