# FinFlow Architecture

## Goal

The architecture demonstrates a production-ready approach while remaining understandable for a Junior developer. The code is organized by feature, and within each major feature, it is divided into Data, Domain, and Presentation layers.

## Layers

### Presentation

Pages and reusable widgets display an immutable State and send Events to a BLoC. Forms and themes use Cubit because their transitions are linear. Widgets do not call Dio, SharedPreferences, or Repositories directly.

### Domain

Entities describe business data. Repository interfaces define capabilities but not the storage method. UseCases coordinate operations, and pure functions perform calculations for the dashboard, analytics, filtering, and sorting.

### Data

Models handle JSON and Entity ↔ Model transformation. LocalDataSource stores JSON in SharedPreferences. RemoteDataSource implements REST via Dio. RepositoryImpl chooses the source, handles fallback, and transforms technical errors into Failures.

## Dependency Direction

```text
Presentation ─────► Domain ◄───── Data
     │                ▲             │
     └── Event/State  └─ implements ┘
```

Domain does not know about specific DataSources. Data depends on Domain because it implements its contract. All connections are created in the composition root `app/dependency_injection.dart`.

## Startup Lifecycle

1. `main` initializes Flutter binding, locale, and DI.
2. The Router opens `/splash`.
3. `AppInitializer` checks for first-run and deterministically creates demo data.
4. Splash sends initial loading events to feature BLoCs.
5. GoRouter replaces splash with `/dashboard` without artificial delay.

## Offline-first

Local storage is the primary source. If `API_BASE_URL` is provided, pull-to-refresh requests the server and updates the cache. In case of a network error, the user continues working with the cache. Changes are first saved locally. This is a good demo compromise; production synchronization would require an outbox, record versions, conflict resolution, and a retry policy.

`ConnectionMonitor` wraps the platform connectivity plugin, while
`ConnectionCubit` exposes checking/online/offline states to `OfflineGate`.
Transport availability is treated as a UI hint; repository requests still
handle network exceptions because a Wi-Fi or cellular interface does not
guarantee that the backend is reachable.

## Transaction presentation slices

The transaction feature keeps Data and Domain shared, but Presentation is
grouped by the page that owns each state manager:

```text
presentation/
  transactions_list/
    bloc/
    pages/
    widgets/
  transaction_form/
    cubit/
    pages/
```

This makes the ownership of `TransactionsBloc` and `TransactionFormCubit`
explicit and prevents unrelated page state from accumulating in one `bloc`
folder.

## States

Feature BLoCs use `initial`, `loading`, `success`, `empty`, and `failure`. Errors are stored as a `Failure`, not an Exception. Forms have `initial`, `saving`, `success`, and `failure` states to block double submission.

## Navigation

`StatefulShellRoute.indexedStack` preserves the state of five tabs. `go` switches the main destination, while `push` opens forms or the About page on top of the current stack. Unknown URLs are handled by `errorBuilder`.
