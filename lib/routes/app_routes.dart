import 'package:flutter/material.dart';

import '../models/cabine.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/usuarios/usuarios_screen.dart';
import '../screens/analytics/analytics_dashboard_screen.dart';
import '../screens/apresentadoras/apresentadoras_screen.dart';
import '../screens/auditoria/analise_credito_screen.dart';
import '../screens/auditoria/audit_log_screen.dart';
import '../screens/auth/aceitar_convite_screen.dart';
import '../screens/auth/esqueci_senha_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/redefinir_senha_screen.dart';
import '../screens/boletos/boletos_screen.dart';
import '../livelab/features/cabines/cabines_repository.dart';
import '../livelab/features/cabines/cabines_screen.dart';
import '../livelab/features/home/home_repository.dart';
import '../livelab/features/home/home_screen.dart';
import '../screens/cabines/cabine_detail_screen.dart';
import '../screens/solicitacoes/solicitacoes_screen.dart';
import '../screens/cliente/cliente_agenda_screen.dart';
import '../screens/cliente/cliente_ao_vivo_screen.dart';
import '../screens/cliente/cliente_reservas_screen.dart';
import '../screens/cliente/cliente_lives_screen.dart';
import '../livelab_v2/admin_v2_routes.dart';
import '../livelab_v2/cliente_v2_routes.dart';
import '../screens/admin_master/regional_managers_screen.dart';
import '../screens/configuracoes/configuracoes_screen.dart';
import '../screens/excelencia/excelencia_screen.dart';
import '../screens/financeiro/financeiro_screen.dart';
import '../screens/manuais/manuais_screen.dart';
import '../screens/knowledge/admin_article_editor_screen.dart';
import '../screens/knowledge/admin_categories_screen.dart';
import '../screens/knowledge/knowledge_article_screen.dart';
import '../screens/knowledge/knowledge_category_screen.dart';
import '../screens/knowledge/knowledge_home_screen.dart';
import '../models/knowledge_article.dart';
import '../screens/painel_cliente/carteira_clientes_screen.dart';
import '../screens/recomendacoes/recomendacoes_screen.dart';
import '../screens/vendas/analise_financeira_screen.dart';
import '../screens/vendas/analise_vendas_screen.dart';
import '../screens/vendas/cadastro_cliente_screen.dart';
import '../screens/vendas/contrato_screen.dart';
import '../screens/vendas/vendas_screen.dart';
import '../widgets/role_route_guard.dart';
import 'app_page_transitions.dart';

class AppRoutes {
  static const login = '/login';
  // F4: rotas públicas de recuperação/convite (sem RoleRouteGuard).
  static const esqueciSenha = '/esqueci-senha';
  static const redefinirSenha = '/redefinir-senha';
  static const aceitarConvite = '/aceitar-convite';
  static const home = '/';
  static const vendas = '/vendas';
  static const comercial = '/comercial';
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
  static const clienteAoVivo = '/cliente/ao-vivo';
  static const clienteHistorico = '/cliente/historico';
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
  static const auditLog = '/auditoria/log';
  static const clientesLeads = '/clientes-leads';
  static const clientes = '/clientes';
  static const configuracoes = '/configuracoes';
  static const solicitacoes = '/solicitacoes';
  static const agendamentos = '/agendamentos';
  static const apresentadoras = '/apresentadoras';
  static const analyticsDashboard = '/analytics-dashboard';
  static const clienteConfiguracoes = '/cliente/configuracoes';
  static const clienteCabinesTabs = '/cliente/cabines';
  static const clienteLives = '/cliente/lives';
  static const clienteAgenda = '/cliente/agenda';
  static const clienteReservas = '/cliente/reservas';
  static const onboarding = '/onboarding';
  static const usuarios = '/usuarios';
  static const masterFranqueados = '/master/franqueados';
  static const masterRegionalManagers = '/master/gerentes-regionais';

  // Papéis que enxergam o painel /master/* — franqueador_master vê tudo,
  // gerente_regional vê subset filtrado pelo backend (user_tenant_access).
  static const Set<String> _masterRoles = {
    'franqueador_master',
    'admin_master',
    'gerente_regional',
  };

  // Knowledge Base (KB)
  static const knowledgeBase = '/conhecimento';
  static const knowledgeCategory = '/conhecimento/c';
  static const knowledgeArticle = '/conhecimento/a';
  static const adminKnowledgeNew = '/master/conhecimento/novo';
  static const adminKnowledgeEdit = '/master/conhecimento/editar';
  static const adminKnowledgeCategories = '/master/conhecimento/categorias';

  static const Set<String> _knowledgeReadRoles = {
    'franqueador_master',
    'admin_master',
    'franqueado',
    'gerente',
    'gerente_comercial',
    'financeiro',
    'operacional',
    'apresentador',
    'apresentadora',
    'cliente_parceiro',
  };

  // Grupos de papéis — espelho de src/config/role_groups.js do backend.
  // Inclui 6 papéis novos da migration 064 (Tier 1+2+3):
  // financeiro_readonly, auditor, suporte, produtor_live,
  // marketing, comercial_readonly.
  static const Set<String> _internalRoles = {
    'franqueado',
    'gerente',
    'gerente_comercial',
    'financeiro',
    'financeiro_readonly',
    'operacional',
    'auditor',
    'suporte',
    'produtor_live',
    'marketing',
    'comercial_readonly',
    'gerente_regional',
  };
  static const Set<String> _commercialRoles = {
    'franqueado',
    'gerente',
    'gerente_comercial',
    'auditor',
    'suporte',
    'marketing',
    'comercial_readonly',
  };
  static const Set<String> _financeRoles = {
    'franqueado',
    'gerente',
    'financeiro',
    'financeiro_readonly',
    'auditor',
  };
  static const Set<String> _opsRoles = {
    'franqueado',
    'gerente',
    'operacional',
    'auditor',
    'suporte',
    'produtor_live',
    'comercial_readonly',
  };
  static const Set<String> _cabineRoles = {
    'franqueado',
    'gerente',
    'operacional',
    'apresentador',
    'apresentadora',
    'auditor',
    'suporte',
    'produtor_live',
    'marketing',
    'comercial_readonly',
  };

  static String routeForRole(String? role, {bool onboardingCompleted = true}) {
    switch (role) {
      case 'franqueador_master':
      case 'admin_master':
      case 'gerente_regional':
        return masterDashboard;
      case 'franqueado':
      case 'gerente':
      case 'gerente_comercial':
      case 'financeiro':
      case 'financeiro_readonly':
      case 'operacional':
      case 'auditor':
      case 'suporte':
      case 'produtor_live':
      case 'marketing':
      case 'comercial_readonly':
        return home;
      case 'apresentador':
      case 'apresentadora':
        return cabines;
      case 'cliente_parceiro':
        return onboardingCompleted ? cliente : onboarding;
      default:
        return login;
    }
  }

  /// All named routes are handled via [onGenerateRoute] so that
  /// [buildPremiumRoute] (SharedAxisTransition) is applied uniformly.
  static Map<String, WidgetBuilder> get routes => {};

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Knowledge Base — rotas dinâmicas com slug/id no path.
    final dynamicRoute = _knowledgeDynamicRoute(settings);
    if (dynamicRoute != null) return dynamicRoute;

    switch (settings.name) {
      case login:
        return buildPremiumRoute(
          child: const LoginScreen(),
          settings: settings,
        );

      // F4: rotas públicas — sem RoleRouteGuard (parte do auth flow).
      case esqueciSenha:
        return buildPremiumRoute(
          child: const EsqueciSenhaScreen(),
          settings: settings,
        );

      case redefinirSenha:
        return buildPremiumRoute(
          child: RedefinirSenhaScreen(
            initialToken: settings.arguments is String
                ? settings.arguments as String
                : null,
          ),
          settings: settings,
        );

      case aceitarConvite:
        return buildPremiumRoute(
          child: AceitarConviteScreen(
            initialToken: settings.arguments is String
                ? settings.arguments as String
                : null,
          ),
          settings: settings,
        );

      case home:
        return buildPremiumRoute(
          child: RoleRouteGuard(
            allowedRoles: _internalRoles,
            fallbackRoute: masterDashboard,
            unauthenticatedRoute: login,
            child: HomeScreen(repository: ApiHomeRepository()),
          ),
          settings: settings,
        );

      case comercial:
      case vendas:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _commercialRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: VendasScreen(),
          ),
          settings: settings,
        );

      case cadastroCliente:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _commercialRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: CadastroClienteScreen(),
          ),
          settings: settings,
        );

      case contrato:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _commercialRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: ContratoScreen(),
          ),
          settings: settings,
        );

      case analise:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _commercialRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: AnaliseVendasScreen(),
          ),
          settings: settings,
        );

      case analiseCredito:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _financeRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: AnaliseFinanceiraScreen(),
          ),
          settings: settings,
        );

      case financeiro:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _financeRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: FinanceiroScreen(),
          ),
          settings: settings,
        );

      case cabines:
        return buildPremiumRoute(
          child: RoleRouteGuard(
            allowedRoles: _cabineRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: CabinesScreen(repository: ApiCabinesRepository()),
          ),
          settings: settings,
        );

      case franqueado:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: MasterHomeV2(),
          ),
          settings: settings,
        );

      case masterDashboard:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _masterRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: MasterHomeV2(),
          ),
          settings: settings,
        );

      case masterUnits:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _masterRoles,
            fallbackRoute: masterDashboard,
            unauthenticatedRoute: login,
            child: MasterUnidadesV2(),
          ),
          settings: settings,
        );

      case masterConsolidated:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _masterRoles,
            fallbackRoute: masterDashboard,
            unauthenticatedRoute: login,
            child: MasterConsolidadoV2(),
          ),
          settings: settings,
        );

      case masterCrm:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _masterRoles,
            fallbackRoute: masterDashboard,
            unauthenticatedRoute: login,
            child: MasterCrmV2(),
          ),
          settings: settings,
        );

      case cliente:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'cliente_parceiro'},
            fallbackRoute: login,
            unauthenticatedRoute: login,
            child: ClienteHomeV2(),
          ),
          settings: settings,
        );

      // clienteHistorico removed (legacy screen deleted)

      case clienteAoVivo:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'cliente_parceiro'},
            fallbackRoute: cliente,
            unauthenticatedRoute: login,
            child: ClienteAoVivoScreen(),
          ),
          settings: settings,
        );

      case clienteConfiguracoes:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'cliente_parceiro'},
            fallbackRoute: cliente,
            unauthenticatedRoute: login,
            child: ClienteConfigV2(),
          ),
          settings: settings,
        );

      case clienteLives:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'cliente_parceiro'},
            fallbackRoute: login,
            unauthenticatedRoute: login,
            child: ClienteLivesScreen(),
          ),
          settings: settings,
        );

      case clienteAgenda:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'cliente_parceiro'},
            fallbackRoute: login,
            unauthenticatedRoute: login,
            child: ClienteAgendaScreen(),
          ),
          settings: settings,
        );

      case clienteCabinesTabs:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'cliente_parceiro'},
            fallbackRoute: login,
            unauthenticatedRoute: login,
            child: ClienteCabinesV2(),
          ),
          settings: settings,
        );

      case clienteReservas:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'cliente_parceiro'},
            fallbackRoute: login,
            unauthenticatedRoute: login,
            child: ClienteReservasScreen(),
          ),
          settings: settings,
        );

      case clienteDashboard:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'cliente_parceiro'},
            fallbackRoute: login,
            unauthenticatedRoute: login,
            child: ClienteHomeV2(),
          ),
          settings: settings,
        );

      case leads:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _commercialRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: MasterCrmV2(),
          ),
          settings: settings,
        );

      case boletos:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {
              'franqueado',
              'gerente',
              'financeiro',
              'cliente_parceiro'
            },
            fallbackRoute: login,
            unauthenticatedRoute: login,
            child: BoletosScreen(),
          ),
          settings: settings,
        );

      case excelencia:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado', 'gerente', 'gerente_comercial'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: ExcelenciaScreen(),
          ),
          settings: settings,
        );

      case recomendacoes:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _commercialRoles,
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
              'gerente_comercial',
              'financeiro',
              'operacional',
              'apresentador',
              'apresentadora',
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
            allowedRoles: _commercialRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: CarteiraClientesScreen(),
          ),
          settings: settings,
        );

      case clientes:
      case clientesLeads:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _commercialRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: MasterCrmV2(),
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

      case auditLog:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master', 'franqueado', 'auditor'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: AuditLogScreen(),
          ),
          settings: settings,
        );

      case configuracoes:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master', 'franqueado'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: ConfiguracoesScreen(),
          ),
          settings: settings,
        );

      case agendamentos:
        return buildPremiumRoute(
          child: RoleRouteGuard(
            allowedRoles: _opsRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: CabinesScreen(repository: ApiCabinesRepository()),
          ),
          settings: settings,
        );

      case solicitacoes:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _opsRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: SolicitacoesScreen(),
          ),
          settings: settings,
        );

      case apresentadoras:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _opsRoles,
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: ApresentadorasScreen(),
          ),
          settings: settings,
        );

      case analyticsDashboard:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {
              'franqueado',
              'gerente',
              'gerente_comercial',
              'financeiro'
            },
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
              allowedRoles: const {
                'franqueado',
                'gerente',
                'operacional',
                'apresentador',
                'apresentadora',
              },
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
              allowedRoles: const {
                'franqueado',
                'gerente',
                'operacional',
                'apresentador',
                'apresentadora',
              },
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

      case onboarding:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'cliente_parceiro'},
            fallbackRoute: cliente,
            unauthenticatedRoute: login,
            child: OnboardingScreen(),
          ),
          settings: settings,
        );

      case usuarios:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueado'},
            fallbackRoute: home,
            unauthenticatedRoute: login,
            child: UsuariosScreen(),
          ),
          settings: settings,
        );

      case masterFranqueados:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master'},
            fallbackRoute: masterDashboard,
            unauthenticatedRoute: login,
            child: MasterFranqueadosV2(),
          ),
          settings: settings,
        );

      case masterRegionalManagers:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master'},
            fallbackRoute: masterDashboard,
            unauthenticatedRoute: login,
            child: RegionalManagersScreen(),
          ),
          settings: settings,
        );

      case knowledgeBase:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: _knowledgeReadRoles,
            fallbackRoute: login,
            unauthenticatedRoute: login,
            child: KnowledgeHomeScreen(),
          ),
          settings: settings,
        );

      case adminKnowledgeNew:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master', 'admin_master'},
            fallbackRoute: knowledgeBase,
            unauthenticatedRoute: login,
            child: AdminArticleEditorScreen(),
          ),
          settings: settings,
        );

      case adminKnowledgeCategories:
        return buildPremiumRoute(
          child: const RoleRouteGuard(
            allowedRoles: {'franqueador_master', 'admin_master'},
            fallbackRoute: knowledgeBase,
            unauthenticatedRoute: login,
            child: AdminKnowledgeCategoriesScreen(),
          ),
          settings: settings,
        );

      default:
        return null;
    }
  }

  /// Resolves dynamic Knowledge Base routes:
  ///   - /conhecimento/c/<slug>      → category screen
  ///   - /conhecimento/a/<slug>      → article screen
  ///   - /master/conhecimento/editar/<id> → editor screen
  static Route<dynamic>? _knowledgeDynamicRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null) return null;

    if (name.startsWith('$knowledgeCategory/')) {
      final slug = name.substring(knowledgeCategory.length + 1);
      if (slug.isEmpty) return null;
      return buildPremiumRoute(
        child: RoleRouteGuard(
          allowedRoles: _knowledgeReadRoles,
          fallbackRoute: login,
          unauthenticatedRoute: login,
          child: KnowledgeCategoryScreen(slug: slug),
        ),
        settings: settings,
      );
    }

    if (name.startsWith('$knowledgeArticle/')) {
      final slug = name.substring(knowledgeArticle.length + 1);
      if (slug.isEmpty) return null;
      return buildPremiumRoute(
        child: RoleRouteGuard(
          allowedRoles: _knowledgeReadRoles,
          fallbackRoute: login,
          unauthenticatedRoute: login,
          child: KnowledgeArticleScreen(slug: slug),
        ),
        settings: settings,
      );
    }

    if (name.startsWith('$adminKnowledgeEdit/')) {
      final id = name.substring(adminKnowledgeEdit.length + 1);
      if (id.isEmpty) return null;
      final args = settings.arguments;
      final preloaded = args is KnowledgeArticle ? args : null;
      return buildPremiumRoute(
        child: RoleRouteGuard(
          allowedRoles: const {'franqueador_master', 'admin_master'},
          fallbackRoute: knowledgeBase,
          unauthenticatedRoute: login,
          child: AdminArticleEditorScreen(
            articleId: id,
            article: preloaded,
          ),
        ),
        settings: settings,
      );
    }

    return null;
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
