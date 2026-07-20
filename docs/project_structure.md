# Структура проекта

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── app_initializer.dart
│   ├── dependency_injection.dart
│   ├── router.dart
│   └── splash_page.dart
├── core/
│   ├── error/        # Failure, Result, Dio mapper
│   ├── network/      # Dio configuration
│   ├── theme/        # Material 3 light/dark themes
│   ├── utils/        # currency/date/category presentation helpers
│   └── widgets/      # state views, confirmation, currency
└── features/
    ├── transactions/ # полный Data/Domain/Presentation с CRUD и фильтрами
    ├── budgets/      # полный Data/Domain/Presentation с CRUD и прогрессом
    ├── dashboard/    # domain aggregation + BLoC + page
    ├── analytics/    # чистые расчёты + BLoC + charts
    └── settings/     # persistence темы, reset/seed, about
```

## Как найти код сценария

- загрузка списка: `transactions_bloc.dart` → `transaction_use_cases.dart` → `transaction_repository_impl.dart` → local/remote data source;
- сохранение формы: `transaction_form_page.dart` → `transaction_form_cubit.dart` → use case → repository;
- расчёт dashboard: `dashboard_bloc.dart` → `build_dashboard.dart`;
- spent бюджета: `budgets_bloc.dart` → `budget_use_cases.dart`;
- аналитика: `analytics_bloc.dart` → `calculate_analytics.dart`;
- смена темы: `settings_page.dart` → `theme_cubit.dart` → `settings_repository_impl.dart`;
- создание объектов: только `dependency_injection.dart`.

## Тестовая структура

```text
test/
├── helpers.dart
├── unit/finance_calculations_test.dart
├── repository/transaction_repository_test.dart
├── bloc/transactions_bloc_test.dart
└── widget/transactions_widgets_test.dart
```

Тесты отделены по уровню, чтобы на интервью было легко показать разницу между чистой бизнес-логикой, инфраструктурой, переходами State и UI.
