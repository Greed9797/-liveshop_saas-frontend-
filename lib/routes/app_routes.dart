import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/vendas/vendas_screen.dart';
import '../screens/vendas/cadastro_cliente_screen.dart';
import '../screens/vendas/contrato_screen.dart';
import '../screens/vendas/analise_financeira_screen.dart';
import '../screens/financeiro/financeiro_screen.dart';
import '../screens/cabines/cabines_screen.dart';
import '../screens/painel_franqueado/franqueado_screen.dart';
import '../screens/painel_cliente/cliente_screen.dart';
import '../screens/leads/leads_screen.dart';
import '../screens/boletos/boletos_screen.dart';
import '../screens/excelencia/excelencia_screen.dart';
import '../screens/recomendacoes/recomendacoes_screen.dart';
import '../screens/manuais/manuais_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/painel_cliente/carteira_clientes_screen.dart';

/// Rotas nomeadas da aplicação
class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const vendas = '/vendas';
  static const cadastroCliente = '/vendas/cadastro';
  static const contrato = '/vendas/contrato';
  static const analise = '/vendas/analise';
  static const financeiro = '/financeiro';
  static const cabines = '/cabines';
  static const franqueado = '/franqueado';
  static const cliente = '/cliente';
  static const leads = '/leads';
  static const boletos = '/boletos';
  static const excelencia = '/excelencia';
  static const recomendacoes = '/recomendacoes';
  static const manuais = '/manuais';
  static const carteiraClientes = '/carteira-clientes';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        home: (_) => const HomeScreen(),
        vendas: (_) => const VendasScreen(),
        cadastroCliente: (_) => const CadastroClienteScreen(),
        contrato: (_) => const ContratoScreen(),
        analise: (_) => const AnaliseFinanceiraScreen(),
        financeiro: (_) => const FinanceiroScreen(),
        cabines: (_) => const CabinesScreen(),
        franqueado: (_) => const FranqueadoScreen(),
        cliente: (_) => const ClienteScreen(),
        leads: (_) => const LeadsScreen(),
        boletos: (_) => const BoletosScreen(),
        excelencia: (_) => const ExcelenciaScreen(),
        recomendacoes: (_) => const RecomendacoesScreen(),
        manuais: (_) => const ManuaisScreen(),
        carteiraClientes: (_) => const CarteiraClientesScreen(),
      };
}
