import 'package:flutter/material.dart';

import '../models/cabine.dart';
import '../screens/admin_master/master_consolidated_screen.dart';
import '../screens/admin_master/master_crm_screen.dart';
import '../screens/admin_master/master_dashboard_screen.dart';
import '../screens/admin_master/master_units_screen.dart';
import '../screens/auditoria/analise_credito_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/boletos/boletos_screen.dart';
import '../screens/cabines/cabine_detail_screen.dart';
import '../screens/cabines/cabines_screen.dart';
import '../screens/clientes/clientes_leads_screen.dart';
import '../screens/configuracoes/configuracoes_screen.dart';
import '../screens/excelencia/excelencia_screen.dart';
import '../screens/financeiro/financeiro_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/leads/leads_screen.dart';
import '../screens/manuais/manuais_screen.dart';
import '../screens/painel_cliente/carteira_clientes_screen.dart';
import '../screens/painel_cliente/cliente_screen.dart';
import '../screens/recomendacoes/recomendacoes_screen.dart';
import '../screens/vendas/analise_financeira_screen.dart';
import '../screens/vendas/analise_vendas_screen.dart';
import '../screens/vendas/cadastro_cliente_screen.dart';
import '../screens/vendas/contrato_screen.dart';
import '../screens/vendas/vendas_screen.dart';
import '../widgets/role_route_guard.dart';

class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const vendas = '/vendas';
  static const cadastroCliente = '/vendas/cadastro';
  static const contrato = '/vendas/contrato';
  static const analise = '/vendas/analise';
  static const analiseCredito = '/vendas/analise_credito';
  static const financeiro = '/financeiro';
  static const cabines = '/cabines';
  static const cabineDetail = '/cabines/detalhe';
  static const franqueado = '/franqueado';
  static const masterDashboard = '/master';
  static const masterUnits = '/master/unidades';
  static const masterConsolidated = '/master/consolidado';
  static const masterCrm = '/master/crm';
  static const cliente = '/cliente';
  static const leads = '/leads';
  static const boletos = '/boletos';
  static const excelencia = '/excelencia';
  static const recomendacoes = '/recomendacoes';
  static const manuais = '/manuais';
  static const carteiraClientes = '/carteira-clientes';
  static const auditoriaContratos = '/auditoria-contratos';
  static const clientesLeads = '/clientes-leads';
  static const configuracoes = '/configuracoes';

  static String routeForRole(String? role) {
    switch (role) {
      case 'franqueador_master':
        return masterDashboard;
      case 'franqueado':
      case 'gerente':
        return home;
      case 'apresentador':
        return cabines;
      case 'cliente_parceiro':
        return cliente;
      default:
        return login;
    }
  }

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    home: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente'},
      fallbackRoute: masterDashboard,
      unauthenticatedRoute: login,
      child: HomeScreen(),
    ),
    vendas: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: VendasScreen(),
    ),
    cadastroCliente: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: CadastroClienteScreen(),
    ),
    contrato: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: ContratoScreen(),
    ),
    analise: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: AnaliseVendasScreen(),
    ),
    analiseCredito: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: AnaliseFinanceiraScreen(),
    ),
    financeiro: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: FinanceiroScreen(),
    ),
    cabines: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente', 'apresentador'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: CabinesScreen(),
    ),
    franqueado: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueador_master'},
      fallbackRoute: masterDashboard,
      unauthenticatedRoute: login,
      child: MasterDashboardScreen(),
    ),
    masterDashboard: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueador_master'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: MasterDashboardScreen(),
    ),
    masterUnits: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueador_master'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: MasterUnitsScreen(),
    ),
    masterConsolidated: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueador_master'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: MasterConsolidatedScreen(),
    ),
    masterCrm: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueador_master'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: MasterCrmScreen(),
    ),
    cliente: (_) => const RoleRouteGuard(
      allowedRoles: {'cliente_parceiro'},
      fallbackRoute: login,
      unauthenticatedRoute: login,
      child: ClienteScreen(),
    ),
    leads: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueador_master', 'franqueado', 'gerente'},
      fallbackRoute: masterDashboard,
      unauthenticatedRoute: login,
      child: LeadsScreen(),
    ),
    boletos: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente', 'cliente_parceiro'},
      fallbackRoute: login,
      unauthenticatedRoute: login,
      child: BoletosScreen(),
    ),
    excelencia: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: ExcelenciaScreen(),
    ),
    recomendacoes: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: RecomendacoesScreen(),
    ),
    manuais: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente', 'cliente_parceiro'},
      fallbackRoute: login,
      unauthenticatedRoute: login,
      child: ManuaisScreen(),
    ),
    carteiraClientes: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: CarteiraClientesScreen(),
    ),
    clientesLeads: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueado', 'gerente'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: ClientesLeadsScreen(),
    ),
    auditoriaContratos: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueador_master'},
      fallbackRoute: masterDashboard,
      unauthenticatedRoute: login,
      child: AnaliseCreditoScreen(),
    ),
    configuracoes: (_) => const RoleRouteGuard(
      allowedRoles: {'franqueador_master', 'franqueado', 'gerente'},
      fallbackRoute: home,
      unauthenticatedRoute: login,
      child: ConfiguracoesScreen(),
    ),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == cabineDetail) {
      final cabine = settings.arguments;
      if (cabine is! Cabine) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Cabine inválida para detalhamento.')),
          ),
          settings: settings,
        );
      }

      return MaterialPageRoute(
        builder: (_) => RoleRouteGuard(
          allowedRoles: const {'franqueado', 'gerente', 'apresentador'},
          fallbackRoute: home,
          unauthenticatedRoute: login,
          child: CabineDetailScreen(
            cabineId: cabine.id,
            cabineNumero: cabine.numero,
          ),
        ),
        settings: settings,
      );
    }

    return null;
  }
}
