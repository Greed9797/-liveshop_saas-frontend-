import 'package:flutter/material.dart';

import '../models/cabine.dart';
import '../screens/admin_master/master_consolidated_screen.dart';
import '../screens/admin_master/master_crm_screen.dart';
import '../screens/admin_master/master_dashboard_screen.dart';
import '../screens/admin_master/master_units_screen.dart';
import '../screens/analytics/analytics_dashboard_screen.dart';
import '../screens/auditoria/analise_credito_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/boletos/boletos_screen.dart';
import '../screens/cabines/cabine_detail_screen.dart';
import '../screens/cabines/cabines_screen.dart';
import '../screens/cliente/cliente_historico_screen.dart';
import '../screens/clientes/clientes_leads_screen.dart';
import '../screens/configuracoes/configuracoes_screen.dart';
import '../screens/excelencia/excelencia_screen.dart';
import '../screens/financeiro/financeiro_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/leads/leads_screen.dart';
import '../screens/manuais/manuais_screen.dart';
import '../screens/painel_cliente/carteira_clientes_screen.dart';
import '../screens/painel_cliente/cliente_dashboard_screen.dart';
import '../screens/painel_cliente/cliente_screen.dart';
import '../screens/recomendacoes/recomendacoes_screen.dart';
import '../screens/solicitacoes/solicitacoes_screen.dart';
import '../screens/vendas/analise_financeira_screen.dart';
import '../screens/vendas/analise_vendas_screen.dart';
import '../screens/vendas/cadastro_cliente_screen.dart';
import '../screens/vendas/contrato_screen.dart';
import '../screens/vendas/vendas_screen.dart';
import '../widgets/role_route_guard.dart';
import 'app_page_transitions.dart';

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
  static const clienteHistorico = '/cliente/historico';
  static const clienteCabines = '/cliente/cabines';
  static const clienteCabineDetail = '/cliente/cabines/detalhe';
  static const clienteDashboard = '/cliente/dashboard';
  static const leads = '/leads';
  static const boletos = '/boletos';
  static const excelencia = '/excelencia';
  static const recomendacoes = '/recomendacoes';
  static const manuais = '/manuais';
  static const baseConhecimento = '/base-conhecimento';
  static const carteiraClientes = '/carteira-clientes';
  static const auditoriaContratos = '/auditoria-contratos';
  static const clientesLeads = '/clientes-leads';
  static const configuracoes = '/configuracoes';
  static const solicitacoes = '/solicitacoes';
  static const agendamentos = '/agendamentos';
  static const analyticsDashboard = '/analytics-dashboard';

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

  /// All named routes are handled via [onGenerateRoute] so that
  /// [buildPremiumRoute] (SharedAxisTransition) is applied uniformly.
  static Map<String, WidgetBuilder> get routes => {};

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return buildPremiumRoute(
          child: const LoginScreen(),
          settings: settings,
        );

      case home:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: masterDashboard,
            unauthenticatedRoute: login,
            child: HomeScreen(),
          ),
          settings: settings,
        );

      case vendas:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: VendasScreen(),
          ),
          settings: settings,
        );

      case cadastroCliente:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: CadastroClienteScreen(),
          ),
          settings: settings,
        );

      case contrato:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: ContratoScreen(),
          ),
          settings: settings,
        );

      case analise:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: AnaliseVendasScreen(),
          ),
          settings: settings,
        );

      case analiseCredito:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: AnaliseFinanceiraScreen(),
          ),
          settings: settings,
        );

      case financeiro:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: FinanceiroScreen(),
          ),
          settings: settings,
        );

      case cabines:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente', 'apresentador'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: CabinesScreen(),
          ),
          settings: settings,
        );

      case franqueado:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: MasterDashboardScreen(),
          ),
          settings: settings,
        );

      case masterDashboard:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: MasterDashboardScreen(),
          ),
          settings: settings,
        );

      case masterUnits:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master'},
            fallbackRoute: masterDashboard,
            unauthenticatedRoute: login,
            child: MasterUnitsScreen(),
          ),
          settings: settings,
        );

      case masterConsolidated:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master'},
            fallbackRoute: masterDashboard,
            unauthenticatedRoute: login,
            child: MasterConsolidatedScreen(),
          ),
          settings: settings,
        );

      case masterCrm:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master'},
            fallbackRoute: masterDashboard,
            unauthenticatedRoute: login,
            child: MasterCrmScreen(),
          ),
          settings: settings,
        );

      case cliente:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'cliente_parceiro'},
            fallbackRoute: login,
            unauthenticatedRoute: login,
            child: ClienteScreen(),
          ),
          settings: settings,
        );

      case clienteHistorico:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'cliente_parceiro'},
            fallbackRoute: login,
            unauthenticatedRoute: login,
            child: ClienteHistoricoScreen(),
          ),
          settings: settings,
        );

      case clienteCabines:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: clienteDashboard,
            unauthenticatedRoute: login,
            child: CabinesScreen(),
          ),
          settings: settings,
        );

      case clienteDashboard:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'cliente_parceiro'},
            fallbackRoute: login,
            unauthenticatedRoute: login,
            child: ClienteDashboardScreen(),
          ),
          settings: settings,
        );

      case leads:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: LeadsScreen(),
          ),
          settings: settings,
        );

      case boletos:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente', 'cliente_parceiro'},
            fallbackRoute: login,
            unauthenticatedRoute: login,
            child: BoletosScreen(),
          ),
          settings: settings,
        );

      case excelencia:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: ExcelenciaScreen(),
          ),
          settings: settings,
        );

      case recomendacoes:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: RecomendacoesScreen(),
          ),
          settings: settings,
        );

      case baseConhecimento:
      case manuais:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {
              'franqueado',
              'gerente',
              'apresentador',
              'cliente_parceiro'
            },
            fallbackRoute: login,
            unauthenticatedRoute: login,
            child: ManuaisScreen(),
          ),
          settings: settings,
        );

      case carteiraClientes:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: CarteiraClientesScreen(),
          ),
          settings: settings,
        );

      case clientesLeads:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: ClientesLeadsScreen(),
          ),
          settings: settings,
        );

      case auditoriaContratos:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master'},
            fallbackRoute: masterDashboard,
            unauthenticatedRoute: login,
            child: AnaliseCreditoScreen(),
          ),
          settings: settings,
        );

      case configuracoes:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master', 'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: ConfiguracoesScreen(),
          ),
          settings: settings,
        );

      case agendamentos:
      case solicitacoes:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: SolicitacoesScreen(),
          ),
          settings: settings,
        );

      case analyticsDashboard:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: AnalyticsDashboardScreen(),
          ),
          settings: settings,
        );

      case cabineDetail:
        {
          final args = settings.arguments;
          String? cabineId;
          int? cabineNumero;
          if (args is Cabine) {
            cabineId = args.id;
            cabineNumero = args.numero;
          } else if (args is String) {
            cabineId = args;
          }
          if (cabineId == null) {
            return buildPremiumRoute(
              child: const _CabineNotFoundScreen(),
              settings: settings,
            );
          }
          return buildPremiumRoute(
            child: RoleRouteGuard(
              allowedRoles: const {'franqueado', 'gerente', 'apresentador'},
              fallbackRoute: home,
              unauthenticatedRoute: login,
              child: CabineDetailScreen(
                cabineId: cabineId,
                cabineNumero: cabineNumero,
              ),
            ),
            settings: settings,
          );
        }

      case clienteCabineDetail:
        {
          final args = settings.arguments;
          String? cabineId;
          int? cabineNumero;
          if (args is Cabine) {
            cabineId = args.id;
            cabineNumero = args.numero;
          } else if (args is String) {
            cabineId = args;
          }
          if (cabineId == null) {
            return buildPremiumRoute(
              child: const _CabineNotFoundScreen(),
              settings: settings,
            );
          }
          return buildPremiumRoute(
            child: RoleRouteGuard(
              allowedRoles: const {'franqueado', 'gerente', 'apresentador'},
              fallbackRoute: clienteDashboard,
              unauthenticatedRoute: login,
              child: CabineDetailScreen(
                cabineId: cabineId,
                cabineNumero: cabineNumero,
              ),
            ),
            settings: settings,
          );
        }

      default:
        return null;
    }
  }
}

class _CabineNotFoundScreen extends StatelessWidget {
  const _CabineNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Cabine não encontrada'),
        actions: [
          TextButton.icon(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.cabines),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar às Cabines'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Color(0xFFFF5A1F),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cabine não identificada',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecione uma cabine na lista para acessar o detalhamento.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.cabines),
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('Ver Cabines'),
            ),
          ],
        ),
      ),
    );
  }
}
