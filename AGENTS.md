# FinFlow agent contract

Use docs/agent/codebase-map.md to narrow exploration before reading broadly. Read the other docs/agent files only when the task touches their subject.

## Architecture

- This is a feature-first Flutter app, but feature depth differs. Transactions, budgets, and categories have the deepest data/domain/presentation layering; dashboard and analytics derive read models; auth and settings use their own shallower patterns.
- Do not impose one generic Clean Architecture template across all features. Follow the nearest existing implementation.
- State management uses flutter_bloc. Prefer BLoC for event-driven screens and Cubit for linear state such as forms and settings, matching nearby code.
- Dependencies are registered manually with get_it in lib/app/dependency_injection.dart. Constructor injection is usual, but direct getIt access already exists in some presentation code for auxiliary loads, undo, details, and export.
- Do not silently "clean up" existing architectural exceptions while implementing unrelated tasks.
- Navigation uses go_router. Main tabs use StatefulShellRoute.indexedStack; pushed routes may create route-scoped state managers.

## Data and behavior

- Transactions and budgets are local-first. SharedPreferences is primary; REST is optional through API_BASE_URL. Local writes succeed even when best-effort remote writes fail.
- Firestore finance datasources exist but are dormant: they are not registered in the active DI graph. Do not switch or combine backends incidentally.
- Transaction, budget, and category repositories expose change streams used by dependent BLoCs. Preserve notifications and cancel subscriptions.
- Categories and settings are globally stored; transactions and budgets use user-specific/guest keys. See docs/agent/data-sync.md before changing persistence.

## UI, generation, and tests

- Add user-facing strings to both lib/l10n/app_en.arb and lib/l10n/app_ru.arb. Regenerate localization output; do not edit generated localization Dart directly.
- Freezed is used selectively. Edit annotated source, not committed .freezed.dart files, and regenerate when relevant.
- Preserve transaction-form RestorationMixin behavior, unsaved-change handling, and rotation/state-restoration tests.
- Add the lowest useful targeted test. Match existing flutter_test, bloc_test, mocktail, SharedPreferences, and Bloc injection patterns.
- Choose verification scope from docs/agent/testing.md. Never claim a command passed unless it ran.
- Do not refactor unrelated architecture, change dependencies, or modify native/Firebase configuration without explicit task scope.
