# LiveShop SaaS — Frontend (Flutter Web)

App Flutter Web para a plataforma multi-tenant LiveShop. Painel para franqueador master, franqueados, gerentes, apresentadores e clientes-parceiros (lojistas).

**Stack**: Flutter 3.41 · Riverpod 2.6 · Dio 5.6 · flutter_secure_storage 9 · fl_chart 0.68 · Phosphor Icons · GoogleFonts (Inter, InstrumentSerif)

---

## Setup local (5 min)

```bash
cd ~/Documents/Playground/-liveshop_saas-frontend-
flutter pub get
flutter run -d chrome --web-browser-flag "--window-size=1200,800"
# Aplicação em http://localhost:<porta-aleatoria>
```

Backend deve estar rodando em `http://localhost:3001` (default) ou apontar para Railway via `--dart-define`.

### E2E auto-login (dev)

```bash
flutter run -d chrome \
  --dart-define=E2E_TESTING=true \
  --dart-define=E2E_ROLE=franqueado \
  --dart-define=E2E_EMAIL_FRANQUEADO=franqueado@liveshop.com \
  --dart-define=E2E_PASSWORD_FRANQUEADO=teste123
```

⚠️ E2E bootstrap está protegido por `kReleaseMode` — não dispara em release builds mesmo se flags forem passadas.

Roles aceitas: `franqueador_master` (`master`), `franqueado`, `cliente_parceiro` (`cliente`), `apresentador`.

---

## Comandos

| Comando | O que faz |
|---|---|
| `flutter pub get` | instala dependências |
| `flutter run -d chrome` | dev server hot-reload |
| `flutter analyze` | lint + type check (zero erros esperado) |
| `flutter test` | smoke widget test |
| `flutter test --coverage` | coverage report (lcov) |
| `flutter build web --release --dart-define=API_URL=https://...` | bundle prod |
| `firebase deploy --only hosting --project livelab-3601f` | deploy Firebase |

---

## Arquitetura

### Initialization (`lib/main.dart`)

```
ApiService.init()                     # Dio + token interceptors
ProviderContainer()                   # Riverpod root
ApiService.setUnauthorizedHandler()   # 401 → authProvider.expireSession()
authProvider.restoreSession()         # SecureStorage → token + user
if (!kReleaseMode && E2E_TESTING) bootstrapE2EAuth()
runApp(UncontrolledProviderScope(...))
```

`LiveShopApp` ouve `authProvider` global; expiry → `pushReplacementNamed(login)`.

### HTTP layer (`lib/services/api_service.dart`)

- Dio com `Authorization: Bearer` injetado por interceptor
- 401 → tentativa de refresh transparente; falha → `_onUnauthorized()`
- Erros lançam `ApiException`; usar `ApiService.extractErrorMessage(e)` para mensagem pt_BR
- SSE via `ResponseType.stream` (compatível Flutter Web)
- Tokens em `flutter_secure_storage`. **No Flutter Web, sem fallback in-memory** (decisão de segurança — XSS poderia ler heap).

### State management (Riverpod)

| Pattern | Quando usar | Exemplo |
|---|---|---|
| `Notifier` | Estado síncrono (auth) | `auth_provider.dart` |
| `AsyncNotifier` | Fetch + polling | `dashboard_provider.dart` (15s) |
| `FamilyAsyncNotifier<T,Id>` | Detail by ID | `cabine_detail_provider.dart` |
| `StreamProvider.family.autoDispose` | SSE real-time | `live_stream_provider.dart` |

**Polling**: `Timer.periodic` em `build()`, cancelar em `ref.onDispose`.

**Filter-driven refetch**: provider observa filtros via `ref.watch(filtrosProvider)` — Riverpod re-roda automaticamente.

### Routing (`lib/routes/app_routes.dart`)

Todas rotas wrapped em `RoleRouteGuard`. Roles:

| Role | Rota inicial | Acesso negado |
|---|---|---|
| `franqueador_master` | `/master` | rotas operacionais |
| `franqueado` / `gerente` | `/` | rotas master |
| `apresentador` | `/cabines` | tudo exceto cabines/manuais |
| `cliente_parceiro` | `/cliente` | rotas operacionais |

`onGenerateRoute` para rotas com argumentos (ex: `Cabine` em `/cabines/detalhe`).

### Design system (`lib/theme/` + `lib/livelab/`)

- **Cores**: `AppColors.primary` (#E8673C); paleta livelab via `LlTokens` (themed)
- **Tipografia**: `AppTypography` Inter + serif Instrument Serif
- **Spacing**: base 4px (`x1=4 ... x8=32`)
- **Radius**: `sm/md/lg/xl/full`
- **Breakpoints**: tablet=800, desktop=1100, wide=1400

`AppScaffold` (legacy) e `LivelabScaffold` (atual) — sidebar branca em desktop, BottomNav em mobile.

### Charts

`fl_chart 0.68`. Template em `widgets/charts/heatmap_horarios_chart.dart`. Wrapper típico: `RepaintBoundary → Container(height:300) → Column(title, Expanded(chart))`.

---

## Convenções

- **Nova screen**: `lib/screens/<modulo>/`, `ConsumerStatefulWidget`, `RoleRouteGuard` em rota
- **Novo provider**: `AsyncNotifier` com `refresh()`, polling Timer + `ref.onDispose`
- **Datas**: passar como `String` ISO entre back e front, formatar pt_BR só no display
- **Money**: `(json['field'] as num? ?? 0).toDouble()` em `fromJson`
- **Erros**: `ApiService.extractErrorMessage(e)` em `SnackBar`
- **Loading**: shimmer skeleton em listas, `CircularProgressIndicator` em full-screen

---

## Deploy

### Build prod (sempre do clone Playground)

```bash
cd ~/Documents/Playground/-liveshop_saas-frontend-
flutter build web --release \
  --dart-define=API_URL=https://liveshop-saas-api-production.up.railway.app/v1
firebase deploy --only hosting --project livelab-3601f
```

⚠️ **CRÍTICO** — clone home (`~/-liveshop_saas-frontend-/`) está desatualizado. Build/deploy de lá publica design antigo.

### URLs

- **Produção**: https://app.grupolivelab.com.br · https://livelab-3601f.web.app
- **Backend**: https://liveshop-saas-api-production.up.railway.app/v1

### Cache invalidation

`firebase.json` configura `must-revalidate` em `index.html`, `main.dart.js`, `flutter_bootstrap.js`, `flutter_service_worker.js`. Assets com hash são `immutable`. Se usuário vir UI antiga: aba anônima ou DevTools → Application → Storage → Clear.

### Tag release

```bash
git tag -a v1.x.y -m "release notes"
git push origin v1.x.y
```

---

## Runbook (incidentes)

### Tela cinza após deploy

1. DevTools Console → procurar erro Flutter
2. Se Riverpod state mismatch: hard refresh (Ctrl+Shift+R)
3. Se persistir: rollback no Firebase Hosting → Deploys → "Rollback to previous"

### Backend 500 → frontend mostra erro genérico

1. Verificar `ApiService.extractErrorMessage(e)` no console
2. Network tab → request real
3. Backend Sentry/logs (Railway)

### Login não funciona em prod

1. Confirmar `--dart-define=API_URL` correto no build
2. CORS: confirmar backend `CORS_ORIGIN` allowlist inclui domínio do frontend
3. CSP: ver `firebase.json` — `connect-src` deve ter URL da API

### Mobile: layout quebrado

1. Validar breakpoint `tablet=800` em `MediaQuery`
2. Sidebar deve virar `Drawer` se largura < 800
3. Cards `Expanded` podem quebrar — usar `Wrap`/`LayoutBuilder`

---

## Estado atual de hardening (Wave 0+1)

- ✅ CI GitHub Actions (`flutter analyze` + build em PR)
- ✅ Token storage seguro (sem fallback heap em web)
- ✅ E2E bootstrap protegido por kReleaseMode
- ✅ CSP sem localhost em prod
- ⏳ Coverage threshold (Wave 2)
- ⏳ Widget tests (Wave 2)
- ⏳ Visual regression (Wave 2)

---

## Recursos relacionados

- `STATUS.md` — pendências, decisões
- `auditoria-frontend.md` — backlog UI
- `~/security-report.md` — auditoria de segurança
- `~/qa-report-2026-05-07.md` — QA report último ciclo
- `~/.claude/plans/crystalline-launching-acorn.md` — plano de hardening Wave 2+3
