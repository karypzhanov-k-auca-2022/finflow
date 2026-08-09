# Testing workflow

## Existing conventions

- Use flutter_test for unit, repository, and widget tests.
- Use bloc_test for BLoC/Cubit state sequences.
- Use mocktail for repository, datasource, Firebase, and mock-BLoC boundaries.
- Reuse fixtures and builders from test/helpers.dart when appropriate.
- Initialize SharedPreferences tests with SharedPreferences.setMockInitialValues before obtaining the instance.
- Inject widget state managers with BlocProvider or MultiBlocProvider; mock widgets commonly use MockBloc and whenListen.
- Use fixed dates for finance calculations.
- Close streams, BLoCs, Cubits, and fake controllers with addTearDown or explicit cleanup.

Some widget tests register objects in global getIt. Check existing registrations and isolate/reset any new global state so tests do not become order-dependent.

The repository currently has unit, repository, BLoC, and widget tests. It has no integration or golden test suite.

## Verification levels

### DOCUMENTATION / AGENT INFRASTRUCTURE

For changes limited to AGENTS.md, docs/agent/, .agents/, or agent-only behavior in scripts/agent/, inspect the diff and validate affected Skills or shell syntax as applicable. Do not run Flutter analyzer or tests unless application/runtime Dart behavior is affected.

### SMALL

Run the directly affected test file or test name when one exists. Add a focused regression test for a behavioral bug when practical.

Examples:

    scripts/agent/verify.sh test/bloc/transactions_bloc_test.dart
    fvm flutter test test/widget/about_page_test.dart

### MEDIUM

Run targeted tests plus Flutter analyzer:

    scripts/agent/verify.sh --analyze test/repository/transaction_repository_test.dart

Use this for changes spanning multiple files in one feature, state-manager changes, or repository behavior changes.

### LARGE or risky

Run targeted tests, analyzer, and a broader relevant suite. Reserve the full flutter test suite for final verification or changes with broad impact, such as startup, global DI, routing, localization infrastructure, or cross-feature persistence semantics.

    scripts/agent/verify.sh --analyze --all-tests

Do not run the full suite after every edit. Never claim tests, analyzer, generation, or formatting passed unless the exact command ran successfully.
