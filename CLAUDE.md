# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get
flutter run -d chrome --web-browser-flag "--window-size=1200,800"
flutter analyze              # zero errors expected; warnings/infos are acceptable
flutter test
flutter test test/widget_test.dart   # single test file

# Build with custom backend URL
flutter build web --dart-define=API_URL=https://api.example.com

# Auto-login for manual testing (backend must be running on :3001)
flutter run -d chrome --dart-define=E2E_TESTING=true --dart-define=E2E_ROLE=franqueador_master
flutter run -d chrome --dart-define=E2E_TESTING=true --dart-define=E2E_ROLE=franqueado
flutter run -d chrome --dart-define=E2E_TESTING=true --dart-define=E2E_ROLE=cliente_parceiro
# Role aliases accepted: 'master' → franqueador_master, 'cliente' → cliente_parceiro
```

## Architecture

### Initialization flow (`lib/main.dart`)

```
ApiService.init()                     # Dio + token interceptors
ProviderContainer()                   # Riverpod root
ApiService.setUnauthorizedHandler()   # Wires 401 → authProvider.expireSession()
authProvider.restoreSession()         # Load persisted token from FlutterSecureStorage
if (E2E_TESTING) bootstrapE2EAuth()  # Auto-login from e2e_bootstrap.dart
runApp(UncontrolledProviderScope(...))
```

`LiveShopApp` watches `authProvider` globally; any session expiry triggers a `pushReplacementNamed` to login.

### HTTP layer (`lib/services/api_service.dart`)

- Dio with `Authorization: Bearer` injected by interceptor
- **401 auto-refresh:** interceptor calls `tryRefresh()`, retries original request, falls back to `_onUnauthorized()` — callers never see a 401
- All methods throw `ApiException` on error; use `ApiService.extractErrorMessage(e)` to get a pt_BR-ready string
- SSE: `streamLiveSnapshot(liveId)` uses `ResponseType.stream` (Flutter Web compatible), yields `LiveSnapshot` frames

### State management (`lib/providers/`)

| Pattern | When to use | Example |
|---------|-------------|---------|
| `Notifier` | Sync state | `authProvider`, `dashboardFiltrosProvider` |
| `AsyncNotifier` | Fetch + optional polling | `dashboardProvider` (15 s), `analyticsDashboardProvider` |
| `FamilyAsyncNotifier<T, Id>` | Detail by ID | `cabineDetailProvider`, `liveRequestsProvider` |
| `StreamProvider.family.autoDispose` | SSE real-time | `liveStreamProvider(liveId)` |

**Polling pattern:** in `build()`, after first fetch, start `Timer.periodic` and cancel in `ref.onDispose`. Never store a timer in `state`.

**Filter-driven refetch:** the data notifier calls `ref.watch(filtrosProvider)` inside `build()` — Riverpod automatically re-runs `build()` when filters change. No manual invalidation needed.

### Routing (`lib/routes/app_routes.dart`)

All named routes are wrapped in `RoleRouteGuard`. The guard checks `authProvider`, waits for the auth state to load, then compares against `allowedRoles`. Unauthorized → `pushReplacementNamed(fallbackRoute)`. Unauthenticated → `pushReplacementNamed(unauthenticatedRoute)`.

`onGenerateRoute` handles routes with typed arguments (e.g., `Cabine` object for `/cabines/detalhe`). Always type-check `settings.arguments` and return an error scaffold on mismatch.

Initial route is determined by `AppRoutes.routeForRole(papel)`:
- `franqueador_master` → `/franqueado`
- `franqueado` → `/`
- `cliente_parceiro` → `/cliente`

### Design system (`lib/theme/`)

Always use theme tokens — never hardcode colors, sizes, or shadows.

- **Colors:** `AppColors.primaryOrange` (#E8673C), full gray scale (`gray50`–`gray900`), semantic (`successGreen`, `dangerRed`, `infoBlue`, `warningYellow`), medals (`medalGold/Silver/Bronze`)
- **Typography:** `AppTypography.h1/h2/h3`, `bodyLarge/Medium/Small`, `caption`, `labelLarge/Small`, `heroNumber` — all Google Fonts Inter
- **Spacing:** base-4 tokens `xs=4 sm=8 md=12 lg=16 xl=20 x2l=24 x3l=32 x4l=40`; semantic `screenPadding=x2l`, `cardPadding=x2l`
- **Radius:** `xs=4 sm=6 md=10 lg=14 xl=16 pill=999`
- **Shadows:** `AppShadows.sm/md/lg/xl` — Stripe-style dual-layer, low alpha
- **Breakpoints:** `tablet=800` (sidebar threshold), `desktop=1100`, `wide=1400`

### AppScaffold (`lib/widgets/app_scaffold.dart`)

Use for every screen: `AppScaffold(currentRoute: AppRoutes.xxx, child: ...)`.

Internally uses `LayoutBuilder` checking `constraints.maxWidth >= 800` for sidebar vs. drawer. The sidebar renders role-based menu items from `_MenuContent`; pass `currentRoute` so the active item highlights correctly.

### Charts (`lib/widgets/charts/`)

All charts use `fl_chart 0.68.0`. Template: `heatmap_horarios_chart.dart` (BarChart). Follow its structure for new charts: `RepaintBoundary` → `Container(height: 300)` → card decoration → `Column(title, Expanded(chart))`.

`HorasLiveChart` is the only `LineChart` in the project — wrap it (and any 30-point+ dataset) in `SingleChildScrollView(scrollDirection: Axis.horizontal)` with a minimum `width: 800` to keep it readable on mobile.

### Key conventions

- **New screen:** `lib/screens/<module>/`, `ConsumerStatefulWidget`, add to `AppRoutes.routes` with `RoleRouteGuard`.
- **New provider:** `AsyncNotifier` with `refresh()` method; polling via `Timer` + `ref.onDispose`. See `dashboard_provider.dart`.
- **Dates:** transport as plain strings (`"YYYY-MM-DD"`, `"HH:mm"`) between backend and Flutter — never convert to `DateTime` until display-time formatting to avoid timezone bugs.
- **Money values:** always `(json['field'] as num? ?? 0).toDouble()` in `fromJson` — backend may return strings or ints.
- **Error display:** use `ApiService.extractErrorMessage(e)` in catch blocks; show result in `SnackBar`.
- **Loading states:** shimmer skeleton (`shimmer` package) for list/card loads; `CircularProgressIndicator` for full-screen loads.
