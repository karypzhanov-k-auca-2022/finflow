# Actual architecture

FinFlow is feature-first with pragmatic, unequal layering. Treat nearby implemented code as the primary convention.

## Composition and state

lib/main.dart initializes Firebase, date formatting, DI, and the app. lib/app/app.dart provides application-wide BLoCs/Cubits above MaterialApp.router. lib/app/splash_page.dart seeds local data, requests initial feature loads, and chooses login or dashboard.

flutter_bloc is the state-management standard:

- BLoC handles event-driven lists and derived screens: transactions, budgets, categories, dashboard, analytics.
- Cubit handles linear state: transaction submission, auth, connectivity, theme, locale, and settings actions.
- Feature BLoCs commonly model initial/loading/success/empty/failure.
- Repositories emit broadcast change notifications; dependent BLoCs subscribe and reload.
- Transaction form field drafts remain in a RestorationMixin widget while TransactionFormCubit owns submission status.

Freezed is selective, not universal. Transaction-list and category states use it; most other states are handwritten Equatable classes.

## Feature asymmetries

Transactions are the deepest reference feature. They have an entity, repository contract, use-case facade, model, local and REST datasources, repository implementation, list BLoC, and form Cubit. Presentation is split by page ownership under transactions_list and transaction_form.

Budgets use similar layers, but spent values are derived by BudgetUseCases from transactions. BudgetsBloc therefore consumes and listens to both budget and transaction use cases.

Categories use deep layering but only a local datasource. Category is also a Flutter-aware domain object because it exposes IconData and Color.

Dashboard and analytics do not own repositories. They build derived read models from transaction/budget data using pure calculation functions and presentation BLoCs.

Auth uses a Firebase repository contract and AuthCubit. Settings uses SharedPreferences directly behind SettingsRepository plus several Cubits; its domain interface uses Flutter ThemeMode and Locale types.

## DI and presentation exceptions

lib/app/dependency_injection.dart manually registers get_it objects. Datasources, repositories, and use-case facades are lazy singletons; most state managers are factories. AuthCubit is currently a lazy singleton.

Constructor injection is common, but getIt is not confined to the composition root. Existing presentation code uses it for category loads, delete undo, budget details, and CSV export. Do not broaden or remove this exception during an unrelated change.

## Navigation

lib/app/router.dart uses go_router. Five main destinations live in StatefulShellRoute.indexedStack. Main navigation uses go/goBranch, while forms and secondary pages are pushed. Transaction form routes provide a route-scoped TransactionFormCubit.

Authentication navigation is manual rather than a router redirect. The edit-transaction route resolves its object from the current TransactionsBloc state, so cold deep-link behavior is limited.

## Data objects and boundaries

Data models extend domain entities and implement JSON conversion manually. The architecture is therefore not strictly pure Clean Architecture. Preserve the established boundary of the affected feature and avoid broad normalization.

