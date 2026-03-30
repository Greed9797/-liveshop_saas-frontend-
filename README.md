# LiveShop SaaS — Frontend Flutter

SaaS multi-tenant para gestão de franquias de estúdios de Live Shop (TikTok Live).
Permite que franqueados e parceiros acompanhem faturamento, cabines ao vivo, NPS, chamados e rankings em tempo real.

## Stack

- Flutter (Dart) + Material 3
- Riverpod (estado e async)
- shimmer (loading states)
- flutter_map (mapa de carteira de clientes)

## Como rodar

```bash
flutter pub get
flutter run -d chrome --web-browser-flag "--window-size=1200,800"
```

Usuário de teste: `franqueado@liveshop.com`

## Branch ativa

```bash
git checkout feat-ui-ux-architecture-v2
```

## O que foi feito

- UI/UX estilo EMIVE: Amarelo (#FFC107) / Preto / Cinza
- AppScaffold responsivo: menu lateral (desktop) / BottomNavigationBar (mobile)
- HomeScreen com CustomScrollView + Slivers (rolagem 120fps)
- MoneyCard com botão de visibilidade (ocultar valores)
- NpsGauge, ChamadosCard, ExcelenciaCard, RankingDestaque
- Loading com shimmer sobre AsyncNotifier
- Rota separada `/carteira-clientes` com flutter_map (lazy)

## Próximos passos

1. **Conectar widgets ao backend** — NpsGauge, ChamadosCard, ExcelenciaCard consumindo `GET /v1/home/dashboard`
2. **Corrigir layout mobile** — painel de cabines espremido no mobile, resolver com expansão em Slivers
3. **Tela de Cabines ao Vivo** — listar cabines ativas com status em tempo real
4. **Autenticação real** — trocar mock por JWT vindo do backend
5. **Tela do Parceiro** — dashboard consumindo `GET /v1/cliente/dashboard`

## Estrutura

```
lib/
  models/        # DashboardData e demais modelos
  providers/     # Riverpod providers (dashboardProvider, etc.)
  screens/       # Telas organizadas por módulo
  widgets/       # Componentes reutilizáveis globais
  theme/         # AppColors, AppTheme
  routes/        # AppRoutes
  mock/          # mock_data.dart (dados temporários até integração)
```
