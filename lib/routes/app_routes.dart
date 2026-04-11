import 'package:flutter/material.dart';
import '../models/cabine.dart';
import '../screens/home/home_screen.dart';
import '../screens/cabines/cabine_detail_screen.dart';
import '../screens/vendas/vendas_screen.dart';
import '../screens/vendas/cadastro_cliente_screen.dart';
import '../screens/vendas/contrato_screen.dart';
import '../screens/vendas/analise_financeira_screen.dart';
import '../screens/vendas/analise_vendas_screen.dart';
import '../screens/financeiro/financeiro_screen.dart';
import '../screens/cabines/cabines_screen.dart';
import '../screens/painel_franqueado/franqueado_screen.dart';
import '../screens/painel_cliente/cliente_screen.dart';
import '../screens/leads/leads_screen.dart';
import '../screens/boletos/boletos_screen.dart';
import '../screens/excelencia/excelencia_screen.dart';
import '../screens/recomendacoes/recomendacoes_screen.dart';
import '../screens/manuais/manuais_screen.dart';
import '../screens/cliente/cliente_historico_screen.dart';
import '../screens/cliente/cliente_cabines_screen.dart';
import '../screens/cliente/cliente_cabine_detail_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/painel_cliente/carteira_clientes_screen.dart';
import '../screens/auditoria/analise_credito_screen.dart';
import '../screens/configuracoes/configuracoes_screen.dart';
import '../screens/clientes/clientes_leads_screen.dart';
import '../screens/solicitacoes/solicitacoes_screen.dart';
import '../screens/analytics/analytics_dashboard_screen.dart';
import '../widgets/role_route_guard.dart';

/// Rotas nomeadas da aplicação
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
  static const cliente = '/cliente';
  static const clienteHistorico = '/cliente/historico';
  static const clienteCabines = '/cliente/cabines';
  static const clienteCabineDetail = '/cliente/cabines/detalhe';
  static const leads = '/leads';
  static const boletos = '/boletos';
  static const excelencia = '/excelencia';
  static const recomendacoes = '/recomendacoes';
  static const manuais = '/manuais';
  static const carteiraClientes = '/carteira-clientes';
  static const auditoriaContratos = '/auditoria-contratos';
  static const clientesLeads = '/clientes-leads';
  static const configuracoes = '/configuracoes';
  static const solicitacoes = '/solicitacoes';
  static const analyticsDashboard = '/analytics-dashboard';

  static String routeForRole(String? role) {
    switch (role) {
      case 'franqueador_master':
        return franqueado;
      case 'cliente_parceiro':
        return cliente;
      case 'franqueado':
        return home;
      default:
        return login;
    }
  }

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        home: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: HomeScreen(),
            ),
        vendas: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: VendasScreen(),
            ),
        cadastroCliente: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: CadastroClienteScreen(),
            ),
        contrato: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: ContratoScreen(),
            ),
        analise: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: AnaliseVendasScreen(),
            ),
        analiseCredito: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: AnaliseFinanceiraScreen(),
            ),
        financeiro: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: FinanceiroScreen(),
            ),
        cabines: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: CabinesScreen(),
            ),
        franqueado: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master'},
              fallbackRoute: home,
              unauthenticatedRoute: login,
              child: FranqueadoScreen(),
            ),
        cliente: (_) => const RoleRouteGuard(
              allowedRoles: {'cliente_parceiro'},
              fallbackRoute: login,
              unauthenticatedRoute: login,
              child: ClienteScreen(),
            ),
        clienteHistorico: (_) => const RoleRouteGuard(
              allowedRoles: {'cliente_parceiro'},
              fallbackRoute: login,
              unauthenticatedRoute: login,
              child: ClienteHistoricoScreen(),
            ),
        clienteCabines: (_) => const RoleRouteGuard(
              allowedRoles: {'cliente_parceiro'},
              fallbackRoute: login,
              unauthenticatedRoute: login,
              child: ClienteCabinesScreen(),
            ),
        leads: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: LeadsScreen(),
            ),
        boletos: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado', 'cliente_parceiro'},
              fallbackRoute: login,
              unauthenticatedRoute: login,
              child: BoletosScreen(),
            ),
        excelencia: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: ExcelenciaScreen(),
            ),
        recomendacoes: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: RecomendacoesScreen(),
            ),
        manuais: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado', 'cliente_parceiro'},
              fallbackRoute: login,
              unauthenticatedRoute: login,
              child: ManuaisScreen(),
            ),
        carteiraClientes: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: CarteiraClientesScreen(),
            ),
        clientesLeads: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: ClientesLeadsScreen(),
            ),
        auditoriaContratos: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: AnaliseCreditoScreen(),
            ),
        configuracoes: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: ConfiguracoesScreen(),
            ),
        solicitacoes: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: SolicitacoesScreen(),
            ),
        analyticsDashboard: (_) => const RoleRouteGuard(
              allowedRoles: {'franqueador_master', 'franqueado'},
              fallbackRoute: franqueado,
              unauthenticatedRoute: login,
              child: AnalyticsDashboardScreen(),
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
          allowedRoles: const {'franqueador_master', 'franqueado'},
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

    if (settings.name == clienteCabineDetail) {
      final cabine = settings.arguments;
      if (cabine is! Cabine) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Cabine inválida.')),
          ),
          settings: settings,
        );
      }

      return MaterialPageRoute(
        builder: (_) => RoleRouteGuard(
          allowedRoles: const {'cliente_parceiro'},
          fallbackRoute: login,
          unauthenticatedRoute: login,
          child: ClienteCabineDetailScreen(
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
