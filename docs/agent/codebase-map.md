# Codebase map

Use this index before repository-wide searches.

| Area | Primary paths |
| --- | --- |
| Startup | lib/main.dart; lib/app/app.dart; lib/app/app_initializer.dart; lib/app/splash_page.dart |
| Dependency injection | lib/app/dependency_injection.dart |
| Routes and shell | lib/app/app_routes.dart; lib/app/router.dart |
| Core errors | lib/core/error/failure.dart; lib/core/error/result.dart; lib/core/error/dio_failure_mapper.dart |
| Network and connectivity | lib/core/network/dio_factory.dart; lib/core/connectivity/ |
| Shared UI/theme/utilities | lib/core/widgets/; lib/core/theme/; lib/core/utils/; lib/core/extensions/ |
| Localization | l10n.yaml; lib/l10n/app_en.arb; lib/l10n/app_ru.arb; generated lib/l10n/app_localizations*.dart |
| Auth | lib/features/auth/domain/; lib/features/auth/data/repositories/firebase_auth_repository_impl.dart; lib/features/auth/presentation/bloc/; lib/features/auth/presentation/pages/login_page.dart |
| Transactions domain | lib/features/transactions/domain/entities/transaction.dart; lib/features/transactions/domain/repositories/transaction_repository.dart; lib/features/transactions/domain/usecases/transaction_use_cases.dart |
| Transactions data | lib/features/transactions/data/models/; lib/features/transactions/data/datasources/; lib/features/transactions/data/repositories/transaction_repository_impl.dart |
| Transaction list | lib/features/transactions/presentation/transactions_list/bloc/; lib/features/transactions/presentation/transactions_list/pages/; lib/features/transactions/presentation/transactions_list/widgets/ |
| Transaction form | lib/features/transactions/presentation/transaction_form/cubit/; lib/features/transactions/presentation/transaction_form/pages/ |
| Budgets | lib/features/budgets/domain/; lib/features/budgets/data/models/; lib/features/budgets/data/datasources/; lib/features/budgets/data/repositories/; lib/features/budgets/presentation/bloc/; lib/features/budgets/presentation/pages/; lib/features/budgets/presentation/widgets/ |
| Categories | lib/features/categories/domain/; lib/features/categories/data/models/; lib/features/categories/data/datasources/; lib/features/categories/data/repositories/; lib/features/categories/presentation/bloc/; lib/features/categories/presentation/pages/; lib/features/categories/presentation/widgets/ |
| Dashboard | lib/features/dashboard/domain/entities/; lib/features/dashboard/domain/usecases/build_dashboard.dart; lib/features/dashboard/presentation/bloc/; lib/features/dashboard/presentation/pages/ |
| Analytics | lib/features/analytics/domain/entities/; lib/features/analytics/domain/usecases/calculate_analytics.dart; lib/features/analytics/presentation/bloc/; lib/features/analytics/presentation/pages/ |
| Settings/About | lib/features/settings/domain/; lib/features/settings/data/; lib/features/settings/presentation/bloc/; lib/features/settings/presentation/pages/ |
| Generated/config | lib/firebase_options.dart; lib/l10n/app_localizations*.dart; lib/features/categories/presentation/bloc/categories_bloc.freezed.dart; lib/features/transactions/presentation/transactions_list/bloc/transactions_bloc.freezed.dart |
| Tests | test/helpers.dart; test/unit/; test/repository/; test/bloc/; test/widget/ |
| Project guidance | README.md; docs/architecture.md; docs/project_structure.md; docs/api_contract.md; docs/agent/ |

Representative tests:

- Transactions: test/repository/transaction_repository_test.dart, test/bloc/transactions_bloc_test.dart, test/widget/transactions_widgets_test.dart
- Budgets: test/bloc/budgets_bloc_test.dart, test/widget/budget_details_test.dart
- Categories: test/repository/categories_repository_test.dart, test/bloc/categories_bloc_test.dart, test/widget/categories_widgets_test.dart
- Auth/settings: test/unit/auth_cubit_test.dart, test/unit/auth_repository_test.dart, test/unit/settings_repository_test.dart
