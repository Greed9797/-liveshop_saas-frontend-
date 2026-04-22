# STATUS

## Atualizacao Desta Sessao
- Foi aplicado um rebranding visual no frontend com base na pasta local `rebrainding/`.
- O `STATUS.md` e a pasta `rebrainding/` agora sao as fontes principais para continuar este trabalho em outra sessao.
- `flutter analyze` esta sem erros de compilacao; restam apenas warnings/info pre-existentes do projeto.

### Escopo principal do rebranding
- Tela de login redesenhada para refletir o material exportado em `rebrainding/`.
- Home redesenhada com fundo gradiente, cards de metricas revisados e bloco de cabines atualizado.
- Sidebar simplificada, sem secoes, com logo e nova ordem visual dos itens.
- Design system alinhado com os tokens da pasta `rebrainding/`.
- Pasta `rebrainding/` excluida do analyzer para ser tratada apenas como referencia.

### Pastas mexidas nesta sessao
- `lib/screens/auth/`
- `lib/screens/home/`
- `lib/widgets/`
- `lib/theme/`
- raiz do projeto:
  - `analysis_options.yaml`
  - `pubspec.yaml`
  - `pubspec.lock`

### Arquivos alterados nesta sessao
- `analysis_options.yaml`
- `pubspec.yaml`
- `pubspec.lock`
- `lib/screens/auth/login_screen.dart`
- `lib/screens/home/home_screen.dart`
- `lib/widgets/app_scaffold.dart`
- `lib/widgets/metric_card.dart`
- `lib/widgets/money_card.dart`
- `lib/theme/app_colors.dart`
- `lib/theme/app_colors_extension.dart`
- `lib/theme/app_radius.dart`
- `lib/theme/app_shadows.dart`
- `lib/theme/app_spacing.dart`
- `lib/theme/app_theme.dart`
- `lib/theme/app_typography.dart`

### Referencias usadas
- `rebrainding/README.md`
- `rebrainding/Frame 1 (1).png`
- `rebrainding/Frame 2.png`
- arquivos de tokens/componentes dentro de `rebrainding/`

## Resumo
- Frontend Flutter funcional localmente.
- `flutter analyze` nao retorna erros; apenas infos de deprecacao e pequenos ajustes cosméticos.
- Existem mudancas locais ainda nao commitadas que consolidam navegacao por papel, BI e partes de UX.
- Parte importante do realtime de live ja esta commitada: SSE na cabine detail.

## Estado Atual
- Autenticacao e refresh token centralizados em `ApiService` com interceptors Dio.
- `cliente_parceiro` nao deve acessar areas operacionais; menu e guardas de rota ja foram ajustados localmente para refletir isso.
- Existe nova tela de BI dedicada para `Análise de Vendas`.
- Cabine detail agora usa SSE para refletir viewer count, pedidos, GMV, likes e comentarios.

## Mudancas Pendentes no Worktree

### Arquivos modificados
- `lib/main.dart`
- `lib/models/cabine.dart`
- `lib/models/contrato.dart`
- `lib/providers/auth_provider.dart`
- `lib/providers/cabines_provider.dart`
- `lib/providers/cliente_dashboard_provider.dart`
- `lib/providers/contratos_provider.dart`
- `lib/providers/financeiro_provider.dart`
- `lib/routes/app_routes.dart`
- `lib/screens/auth/login_screen.dart`
- `lib/screens/cabines/cabines_screen.dart`
- `lib/screens/financeiro/financeiro_screen.dart`
- `lib/screens/home/home_screen.dart`
- `lib/screens/leads/leads_screen.dart`
- `lib/screens/painel_cliente/carteira_clientes_screen.dart`
- `lib/screens/painel_cliente/cliente_screen.dart`
- `lib/screens/recomendacoes/recomendacoes_screen.dart`
- `lib/screens/vendas/analise_financeira_screen.dart`
- `lib/screens/vendas/contrato_screen.dart`
- `lib/screens/vendas/vendas_screen.dart`
- `lib/theme/app_colors.dart`
- `lib/theme/app_theme.dart`
- `lib/widgets/app_scaffold.dart`
- `lib/widgets/cabine_card.dart`
- `lib/widgets/client_pin.dart`
- `lib/widgets/money_card.dart`
- `lib/widgets/ranking_destaque.dart`
- `lib/widgets/status_badge.dart`
- `pubspec.yaml`
- `pubspec.lock`
- `test/widget_test.dart`

### Arquivos novos relevantes
- `lib/models/fila_ativacao_item.dart`
- `lib/models/franqueado_analytics_resumo.dart`
- `lib/providers/analytics_provider.dart`
- `lib/routes/app_navigator.dart`
- `lib/screens/vendas/analise_vendas_screen.dart`
- `lib/theme/app_typography.dart`
- `lib/widgets/banner_alerta_comercial.dart`
- `lib/widgets/role_route_guard.dart`
- `lib/widgets/charts/heatmap_horarios_chart.dart`
- `lib/screens/auditoria/...`
- `lib/config/...`

### Arquivos novos nao necessariamente de producao
- `.superpowers/`
- `auditoria-frontend.md`
- `flutter_01.png`
- `assets/`

## Features Ja Commitadas por Fora e Importantes

### Realtime de live por SSE
- `lib/models/live_snapshot.dart`
- `lib/providers/live_stream_provider.dart`
- `lib/screens/cabines/cabine_detail_screen.dart`

Capacidades:
- stream SSE por `liveId`
- fallback no polling local
- cards com 6 metricas realtime

## Agrupamento Recomendado de Commits Pendentes

### Commit 1: navegacao, auth e RBAC visual
Escopo:
- `lib/providers/auth_provider.dart`
- `lib/routes/app_routes.dart`
- `lib/routes/app_navigator.dart`
- `lib/widgets/app_scaffold.dart`
- `lib/widgets/role_route_guard.dart`
- `lib/main.dart`
- `lib/screens/auth/login_screen.dart`

Mensagem sugerida:
- `feat: harden auth flow and role-based navigation`

### Commit 2: dashboard cliente parceiro consultivo
Escopo:
- `lib/providers/cliente_dashboard_provider.dart`
- `lib/screens/painel_cliente/cliente_screen.dart`
- `lib/screens/painel_cliente/carteira_clientes_screen.dart`

Mensagem sugerida:
- `feat: expand cliente dashboard with reservation and benchmarks`

### Commit 3: operacao de cabines e modelos
Escopo:
- `lib/models/cabine.dart`
- `lib/models/fila_ativacao_item.dart`
- `lib/providers/cabines_provider.dart`
- `lib/screens/cabines/cabines_screen.dart`
- `lib/widgets/cabine_card.dart`
- `lib/widgets/status_badge.dart`

Mensagem sugerida:
- `feat: support cabine reservation lifecycle in frontend`

### Commit 4: BI do franqueado
Escopo:
- `lib/models/franqueado_analytics_resumo.dart`
- `lib/providers/analytics_provider.dart`
- `lib/screens/vendas/analise_vendas_screen.dart`
- `lib/widgets/charts/heatmap_horarios_chart.dart`

Mensagem sugerida:
- `feat: add sales analytics dashboard with heatmap`

### Commit 5: auditoria e componentes auxiliares
Escopo:
- `lib/screens/auditoria/...`
- `lib/screens/vendas/analise_financeira_screen.dart`
- `lib/screens/vendas/contrato_screen.dart`
- `lib/widgets/banner_alerta_comercial.dart`
- `lib/models/contrato.dart`
- `lib/providers/contratos_provider.dart`

Mensagem sugerida:
- `feat: add contract audit and approval experience`

### Commit 6: design system e refinamentos visuais
Escopo:
- `lib/theme/app_colors.dart`
- `lib/theme/app_theme.dart`
- `lib/theme/app_typography.dart`
- `lib/widgets/client_pin.dart`
- `lib/widgets/money_card.dart`
- `lib/widgets/ranking_destaque.dart`
- `lib/screens/home/home_screen.dart`
- `lib/screens/recomendacoes/recomendacoes_screen.dart`
- `lib/screens/financeiro/financeiro_screen.dart`
- `lib/providers/financeiro_provider.dart`

Mensagem sugerida:
- `refactor: unify design system and dashboard visuals`

### Commit 7: arquivos auxiliares e assets
Escopo:
- `assets/`
- `.superpowers/`
- `auditoria-frontend.md`
- `flutter_01.png`
- `test/widget_test.dart`

Mensagem sugerida:
- `chore: add frontend assets and local project notes`

## Riscos Atuais
- O header do `AppScaffold` ainda usa subtitulo fixo de franqueado; isso pode ficar semanticamente errado para cliente parceiro.
- O dashboard de BI do franqueado ja existe localmente, mas ainda esta em estado inicial, com foco principal no heatmap.
- Parte das mudancas visuais e de role routing ainda nao esta protegida por commit.
- `assets/` e anexos de imagem precisam ser avaliados antes de commit para evitar ruido desnecessario.

## Como Continuar
1. Commitar primeiro navegacao/auth/RBAC para estabilizar o shell do app.
2. Commitar depois cliente dashboard e cabines para manter coerencia funcional.
3. Commitar BI do franqueado em bloco proprio.
4. Revisar warnings do `flutter analyze` depois dos commits:
   - trocar `withOpacity` por `withValues`
   - trocar `activeColor` por `activeThumbColor`
   - adicionar `const` onde relevante

## Validacao Atual
- `flutter analyze` sem erros, apenas infos.
- Nesta sessao, o analyzer tambem foi configurado para ignorar `rebrainding/**`.
- Recomendado apos commits:
  - smoke test login franqueado
  - smoke test login cliente parceiro
  - navegar para `Home`, `Análise de Vendas`, `Cabines`
  - validar detalhe da cabine com SSE quando houver live ativa

## Notas de Continuidade
- Para continuar o trabalho de UI, leia primeiro este arquivo e depois consulte a pasta `rebrainding/`.
- O arquivo `PROMPT_CONTINUACAO.md` deste repositorio aponta para este `STATUS.md` como guia completo.
