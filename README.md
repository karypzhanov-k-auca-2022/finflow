# FinFlow — Personal Finance Tracker

FinFlow is a complete Flutter application for tracking income, expenses, and monthly budgets. The project works without a backend, persists data between launches, and demonstrates a product-oriented approach: feature-first Clean Architecture, BLoC/Cubit, Repository Pattern, Dependency Injection, GoRouter, Dio, Material 3, and automated tests.

## Features

- Dashboard with balance, monthly income/expenses, budget progress, chart, and recent transactions;
- Add and edit transactions with validation and unsaved changes protection;
- Search, filters by type/category/date, sorting, grouping by days, and swipe-to-delete;
- CRUD for monthly budgets, warnings after 80%, and a separate "over budget" state;
- Analytics for 3, 6, or 12 months: bar chart, average spending, and top category;
- System, light, and dark themes with persistence;
- Data clearing and deterministic restoration of demo data for six months;
- Loading, success, empty, and failure states with Retry;
- English and Russian localization with a persisted language choice;
- Dedicated offline screen, local continuation mode, and connection recovery;
- Responsive bottom navigation/NavigationRail and a rotation-safe transaction form;
- Optional synchronization with REST API and fallback to local cache.

## Screenshots

The `docs/screenshots/` folder is prepared for the portfolio. After running, add `dashboard.png`, `transactions.png`, `budgets.png`, `analytics.png` there and replace this block with images. This was intentionally not replaced with drawn mocks: screenshots should show the actual build running on your device.

## Technologies

Flutter 3.41.2, Dart 3.11, Material 3, `flutter_bloc`, `equatable`, `go_router`, `dio`, `get_it`, `intl`, `fl_chart`, `shared_preferences`, `bloc_test`, `mocktail`, `flutter_test`.

## Structure

```text
lib/
  app/                  # startup, DI, router, splash
  core/                 # errors, Dio, theme, formatters, common widgets
  features/
    dashboard/          # finance overview
    transactions/       # data/domain/presentation and form
    budgets/            # data/domain/presentation
    analytics/          # domain calculations, BLoC, and UI
    settings/           # theme, data, and about
test/
  unit/ repository/ bloc/ widget/
docs/
```

A detailed map is in [docs/project_structure.md](docs/project_structure.md), architecture — in [docs/architecture.md](docs/architecture.md), backend contract — in [docs/api_contract.md](docs/api_contract.md).

## Clean Architecture

- **Presentation** knows Flutter and BLoC. Widget sends an event and displays State.
- **Domain** contains Entities, Repository contracts, UseCases, and pure calculations. It does not import Flutter (exception — theme settings, as `ThemeMode` is a UI setting).
- **Data** knows JSON, SharedPreferences, and Dio. The Repository implementation hides the source choice.

Data flow:

```text
UI → Event → BLoC → UseCase → Repository → DataSource
                                      ↓
UI ← State ← BLoC ← Result/Failure ←
```

## Repository Pattern and offline-first

UI and BLoC depend on `TransactionRepository`/`BudgetRepository`, not on SharedPreferences or Dio. Reading is local by default. With `refresh: true` and a given `API_BASE_URL`, the Repository tries remote, saves the response to cache, and returns data. On network error, cache is returned. Creating, updating, and deleting are first applied locally, so the app remains useful without a network; the remote call is best effort.

`ConnectionCubit` observes platform connectivity. When the connection disappears,
the app shows a dedicated offline screen with Retry and Continue offline actions.
After local continuation, cached data and local writes remain available and a
persistent offline indicator is shown until connectivity returns.
If Firebase anonymous authentication cannot be reached on the first launch,
guest mode falls back to a persisted local guest so the finance tracker remains
usable without an account or network.

## Localization and adaptive UI

Flutter `gen_l10n` generates type-safe English and Russian resources from ARB
files. The selected locale is stored in `SharedPreferences`. Dates, currency,
navigation, validation, dialogs, and default category names follow the active
locale.

The app shell uses `NavigationBar` on compact windows and `NavigationRail` from
720 logical pixels. The transaction form switches between one and two columns,
retains its values when the viewport rotates, and uses Flutter state restoration
if the activity is recreated.

## Dependency Injection

`get_it` is configured once in `dependency_injection.dart`. DataSource, Repository, and UseCase are lazy singletons; BLoC/Cubit are factories. Business classes receive dependencies via constructor and do not access the service locator. `getIt` is only used in the composition root.

## Errors

The app uses typed `NetworkFailure`, `TimeoutFailure`, `ServerFailure`, `CacheFailure`, `ValidationFailure`, `UnknownFailure`, and `Result<T>`. `mapDioException` translates technical Dio errors into domain errors. The UI receives safe text, not a raw exception. Retry is available for recoverable errors.

## Launch

```bash
flutter pub get
flutter run
```

To select a device: `flutter devices`, then `flutter run -d <device-id>`. No backend needed: on the first run, the splash will fill local storage with demo data.

## Tests and Quality

```bash
dart format .
flutter analyze
flutter test
```

Tests cover calculations, filters and sorting, budget progress, analytics, Repository/fallback/Failure, BLoC states, creation and deletion, as well as key Widget states and form validation.

## Connecting Backend

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

The server must implement the contract from `docs/api_contract.md`. Do not store tokens in source code; for production, add an auth-interceptor and secure token storage. Without the define, remote is completely disabled and won't break the app.

## Architectural Decisions and Trade-offs

- SharedPreferences stores JSON: for a pet project's volume, this is transparent and easy to explain; for tens of thousands of records, consider SQLite/Drift or Isar.
- Local write is considered successful even if remote is unavailable. A production version would require an outbox, retry, and explicit sync-status.
- Analytics are calculated on the device. For large data, aggregation should move to backend/DB.
- UseCases are grouped by feature into small facades to avoid creating a class for every one-line operation.
- BLoC is used where there are events and multiple state transitions; Cubit is for linear forms and themes.
- UUID package was not added: local IDs are built from microseconds, which is sufficient for a single-device demo.
