# Auditoria Frontend

## Goal
Implementar a base do dashboard de auditoria de contratos no frontend, conectado ao novo contrato de API do backoffice.

## Tasks
- [ ] Atualizar `lib/models/contrato.dart` para suportar payload de auditoria → Verify: parse sem exception para `items` do board.
- [ ] Refatorar `lib/providers/contratos_provider.dart` para novo payload `{ items, meta }` e ações novas → Verify: métodos aceitam aba/motivo/CONCORDO+senha.
- [ ] Adicionar rota `auditoriaContratos` em `lib/routes/app_routes.dart` → Verify: rota registrada sem quebrar análise financeira.
- [ ] Criar `lib/screens/auditoria/analise_credito_screen.dart` com abas e estados base → Verify: tela compila e abre com loading/erro/vazio.
- [ ] Expor item de menu para `franqueador_master` em `lib/widgets/app_scaffold.dart` → Verify: role master vê o item, franqueado não.
- [ ] Criar componentes `card`, `tabs` e modais da auditoria → Verify: ações disparam callbacks e validam input.
- [ ] Sincronizar invalidadores de Home/Mapa após ações → Verify: sem F5 após sucesso.

## Done When
- [ ] O board de auditoria abre via rota dedicada e consome o payload novo do backend.
