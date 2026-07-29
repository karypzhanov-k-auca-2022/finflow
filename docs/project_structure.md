# Project Structure

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── app_initializer.dart
│   ├── app_routes.dart
│   ├── dependency_injection.dart
│   ├── router.dart
│   └── splash_page.dart
├── core/
│   ├── error/        # Failure, Result, Dio mapper
│   ├── network/      # Dio configuration
│   ├── connectivity/ # connectivity monitor, Cubit, and offline UI gate
│   ├── extensions/   # BuildContext localization helpers
│   ├── theme/        # Material 3 themes and shared spacing tokens
│   ├── utils/        # currency/date/category presentation helpers
│   └── widgets/      # state views, confirmation, currency
└── features/
    ├── transactions/ # Data/Domain plus page-based list and form presentation
    ├── budgets/      # full Data/Domain/Presentation with CRUD and progress
    ├── dashboard/    # domain aggregation + BLoC + page
    ├── analytics/    # pure calculations + BLoC + charts
    └── settings/     # theme persistence, reset/seed, about
```

## How to Find Scenario Code

- List loading: `presentation/transactions_list/bloc/transactions_bloc.dart` → `transaction_use_cases.dart` → `transaction_repository_impl.dart` → local/remote data source;
- Form saving: `presentation/transaction_form/pages/transaction_form_page.dart` → `transaction_form_cubit.dart` → use case → repository;
- Dashboard calculation: `dashboard_bloc.dart` → `build_dashboard.dart`;
- Budget spent: `budgets_bloc.dart` → `budget_use_cases.dart`;
- Analytics: `analytics_bloc.dart` → `calculate_analytics.dart`;
- Theme change: `settings_page.dart` → `theme_cubit.dart` → `settings_repository_impl.dart`;
- Object creation: only `dependency_injection.dart`.

Each BLoC is split into `*_bloc.dart`, `*_event.dart`, and `*_state.dart`.
Each Cubit with a custom state uses separate `*_cubit.dart` and
`*_state.dart` files. Route paths live in `app_routes.dart`, while reusable
UI spacing values live in `core/theme/app_spacing.dart`.

## Test Structure

```text
test/
├── helpers.dart
├── unit/finance_calculations_test.dart
├── repository/transaction_repository_test.dart
├── bloc/transactions_bloc_test.dart
└── widget/transactions_widgets_test.dart
```

Tests are separated by level to make it easy during an interview to show the difference between pure business logic, infrastructure, State transitions, and UI.
