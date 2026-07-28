# FinFlow: Interview Preparation Guide

## Brief Project Presentation

> FinFlow is my Flutter pet project for personal finance tracking. It allows users to manage income and expenses, search and filter transactions, set monthly budgets, and view analytics over various periods. I used a feature-first Clean Architecture: the UI sends events to a BLoC, which calls a UseCase, while the Repository abstracts away local SharedPreferences and an optional REST source using Dio. The app is offline-first, meaning it runs without a backend and seeds stable data for six months upon the first installation. I also implemented typed errors, DI via get_it, GoRouter with shell navigation, light/dark themes, and unit, repository, BLoC, and widget tests.

This takes about 50 seconds at a steady pace.

## Architecture in Simple Terms

- **Presentation** — pages, widgets, BLoC/Cubit. Handles user actions and displays State.
- **Domain** — the heart of the app: Entities, Repository contracts, UseCases, calculations. Doesn't know where data is physically stored.
- **Data** — storage and network details: Models, JSON, SharedPreferences, Dio, and RepositoryImpl.
- **Repository** — the single point of data access; decides between local/remote and handles fallbacks.
- **UseCase** — a clear app operation and the boundary between state and data.
- **DataSource** — a specific data source: local storage or REST.
- **Dependency Injection** — creating and linking objects from the outside via `get_it`; dependencies are passed through constructors.

## Request Execution Flow

Example of opening the transactions list:

1. User opens the Transactions tab.
2. Splash or UI sends `TransactionsRequested`.
3. `TransactionsBloc` transitions to loading state.
4. BLoC calls `TransactionUseCases.load()`.
5. UseCase accesses the `TransactionRepository` interface.
6. `TransactionRepositoryImpl` reads local or attempts remote with fallback.
7. `Result<List<FinanceTransaction>>` is returned to BLoC.
8. BLoC emits success, empty, or failure.
9. `BlocBuilder` rebuilds only the necessary part of the UI.

## Possible Senior Developer Questions

### 1. Why choose BLoC?

It makes events, states, and transitions explicit, separates business logic from Widgets, and is easily testable via State sequences.

### 2. How does Bloc differ from Cubit?

Cubit is triggered by methods and changes State immediately. Bloc accepts typed Events and is better suited for multiple action sources or complex transitions. Thus, the list uses Bloc, while the form and theme use Cubit.

### 3. Why is the Repository between Domain and DataSource?

Domain describes what data is needed, while RepositoryImpl decides where to get it. BLoC doesn't change if you swap SharedPreferences for SQLite.

### 4. Why are UseCases necessary?

They create a stable scenario boundary, prevent the BLoC from knowing Repository details, and serve as a coordination point for rules. One-line operations are collected in a feature facade to avoid dozens of classes.

### 5. Why not call Dio directly from a Widget?

The Widget would become responsible for UI, network, parsing, and errors; it would be harder to test and reuse, and its lifecycle could lead to setState after dispose.

### 6. How are errors handled?

Infrastructure exceptions are caught in Data/Repository and converted into a `Failure`. BLoC emits a failure state, and the UI shows a safe message with a Retry option.

### 7. How does the local data fallback work?

During a refresh from the backend, the Repository first calls remote. If Dio throws an error, the Repository reads the local cache and returns a Success with it.

### 8. What happens without internet?

Without `API_BASE_URL`, the network isn't called at all. With the URL, reading falls back to cache, while local changes remain successful.

### 9. How does Dependency Injection work?

Implementations are registered by interfaces in the composition root. GetIt builds the object graph, and each business class receives its dependencies via the constructor.

### 10. Why pass dependencies via constructor?

They are visible in the class API, required upon creation, easily replaceable with mock objects, and don't hide global state.

### 11. Why use GoRouter?

It descriptively defines routes, supports path parameters, deep links, error pages, and `StatefulShellRoute` for five tabs.

### 12. How does `go` differ from `push`?

`go` changes the current location and is suitable for main sections; `push` adds a screen on top of the stack and is suitable for forms or the About page.

### 13. How is theme state persisted?

`ThemeCubit` changes `ThemeMode`, and `SettingsRepositoryImpl` saves its name to SharedPreferences. Upon Cubit creation, the value is read back.

### 14. Why should State be immutable?

Transitions result in new values, making them easier to compare, log, test, and safely use with reactive rebuilds.

### 15. How does an Entity differ from a Model?

An Entity reflects business meaning and doesn't know about JSON. A Model resides in Data, handles `fromJson/toJson`, and is mapped to an Entity.

### 16. Where does Model-to-Entity mapping happen?

In the Data layer. Models extend the immutable Entity for easy reading, and `fromEntity` is used before saving.

### 17. How is Null Safety implemented?

Required fields use `required`, optional ones use nullable types or safe default values. Nullable fields are checked before use.

### 18. Where are generics used?

`Result<T>`, `Success<T>`, `Bloc<Event, State>`, Entity collections, and generic Dio API methods.

### 19. Where are enums used?

Transaction type, category, period, sort field, sort direction, BLoC and form statuses, and ThemeMode.

### 20. Where is Future used?

Initialization, DataSource, Repository, UseCase, form submission, confirmations, and pull-to-refresh — these are asynchronous operations with a single result.

### 21. Where might Stream be used?

BLoC provides a Stream of states. In production, Streams are also useful for live DB updates or WebSocket synchronization.

### 22. What tests were added?

Unit for calculations, repository for local/remote/fallback/error, BLoC/Cubit for transitions, and widget for loading/empty/list/error/validation.

### 23. How is BLoC tested?

`bloc_test` sets up a mock Repository, sends Events, and verifies the exact State sequence without UI.

### 24. Why SharedPreferences instead of SQLite?

For a small deterministic demo, JSON is easier to explain and maintain. For larger data, queries, and migrations, I would choose Drift/SQLite.

### 25. What would you improve in production?

SQLite, pagination, authorization, secure storage, outbox/retry, conflict resolution, crash reporting, localization, CI, and integration/golden tests.

### 26. Which parts can be scaled?

DataSource can be replaced independently, features can be moved to packages, server-side analytics can be connected via contract, and new features can be added as separate vertical layers.

### 27. What architectural trade-offs were made?

UseCases are grouped, JSON is stored as a whole array, remote writes are best-effort without a queue, analytics are calculated in-memory, and IDs are local.

### 28. How is double submission prevented?

`TransactionFormCubit` ignores submissions while saving, and the button is disabled and shows an indicator.

### 29. How are unsaved changes protected?

The page tracks dirty state and uses `PopScope` to ask for confirmation. Exit is allowed after successful saving.

### 30. Why aren't calculations inside `build`?

They are business logic, so they are moved to pure Domain functions/UseCases. Build only turns ready data into widgets.

### 31. How is list performance ensured?

Uses `ListView.builder`, stable `ValueKey` by id, and a pre-filtered State; Widgets don't make network requests during build.

### 32. Why is demo data deterministic?

Stable amounts and categories make charts and demonstrations reproducible. Dates are tied to the current month so the dashboard is always populated.

## Project Map

| File | Responsibility | Called by | Dependencies |
|---|---|---|---|
| `lib/main.dart` | binding start, locale, DI | Flutter runtime | Flutter, intl, app/DI |
| `lib/app/app.dart` | root BlocProviders, themes, router | `main` | feature BLoCs, AppTheme, router |
| `lib/app/dependency_injection.dart` | composition root | `main`, router | GetIt, all implementations |
| `lib/app/router.dart` | routes, shell, 404 | `FinFlowApp` | GoRouter, pages, form Cubit |
| `lib/app/app_initializer.dart` | first-run seed | Splash | local data sources |
| `lib/app/splash_page.dart` | actual initialization & first load | router | initializer, feature BLoCs |
| `lib/core/error/failure.dart` | domain error types | Repository/BLoC/UI | Equatable |
| `lib/core/error/result.dart` | Success/Error without throw | Repository/UseCase/BLoC | Failure |
| `lib/core/error/dio_failure_mapper.dart` | DioException → Failure | network Data/Repository | Dio, Failure |
| `lib/core/network/dio_factory.dart` | base URL, timeout, headers, debug log | DI | Dio, foundation |
| `lib/core/theme/app_theme.dart` | Material 3 light/dark | app | Material |
| `transaction.dart` | Entity and operation enums | all transaction layers | Equatable |
| `transaction_model.dart` | JSON and Entity mapping | data sources/repository | transaction Entity |
| `transaction_local_data_source.dart` | persistence and demo seed | Repository/initializer | SharedPreferences, JSON |
| `transaction_remote_data_source.dart` | REST CRUD | Repository | Dio, Model |
| `transaction_repository.dart` | Domain contract | UseCase | Result, Entity |
| `transaction_repository_impl.dart` | offline-first and fallback | DI/UseCase interface | local, remote, Model |
| `transaction_use_cases.dart` | operations, filtering, sorting | BLoC/Cubit | Repository |
| `transactions_bloc.dart` | list, delete, filters, State | page/splash | use cases |
| `transaction_form_cubit.dart` | saving/success/failure | form page | use cases |
| `transactions_page.dart` | search, filters, grouped list, swipe | router | TransactionsBloc, GoRouter |
| `transaction_form_page.dart` | create/edit UI and validation | router | FormCubit and feature BLoCs |
| `budget.dart` | Budget Entity and progress rules | budget/domain/UI | Equatable, category enum |
| `budget_local_data_source.dart` | budget JSON and seed | Repository/initializer | SharedPreferences |
| `budget_repository_impl.dart` | budget CRUD/fallback | BudgetUseCases | local/remote |
| `budget_use_cases.dart` | CRUD and spent calculation | BudgetsBloc | repositories/entities |
| `budgets_bloc.dart` | load/save/delete states | budgets page/splash | budget + transaction use cases |
| `budgets_page.dart` | cards, progress, CRUD dialogs | router | BudgetsBloc |
| `build_dashboard.dart` | balance and monthly aggregates | DashboardBloc | Transaction/Budget Entity |
| `dashboard_bloc.dart` | loading/empty/error/success overview | dashboard page/splash | use cases, build function |
| `dashboard_page.dart` | cards, pie chart, recent list | router | DashboardBloc, fl_chart |
| `calculate_analytics.dart` | month/category aggregation | AnalyticsBloc | Transaction Entity |
| `analytics_bloc.dart` | period and analytics states | analytics page/splash | use cases, calculator |
| `analytics_page.dart` | chart and summary | router | AnalyticsBloc, fl_chart |
| `theme_cubit.dart` | ThemeMode and persistence | app/settings | SettingsRepository |
| `settings_cubit.dart` | clear/reseed | settings page | transaction/budget use cases |
| `settings_page.dart` | theme and data actions | router | settings/theme and feature BLoCs |

## What to Show a Senior Developer in IDE

1. Start with `transactions_bloc.dart`: show Events/States and absence of UI logic.
2. Go to `transaction_use_cases.dart`: show pure filtering and the Repository contract.
3. Open `transaction_repository_impl.dart`: explain offline-first and fallback.
4. Show `dependency_injection.dart`: how interfaces and implementations are linked.
5. Run `flutter test` and open one test of each level.
