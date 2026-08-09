---
name: flutter-tests
description: Add, update, or diagnose tests in the FinFlow Flutter repository using its existing flutter_test, bloc_test, mocktail, SharedPreferences, and widget Bloc-injection conventions. Use for regression coverage, failing tests, test design, or verification-focused tasks.
---

# Flutter tests

1. Read docs/agent/testing.md and locate nearby tests through docs/agent/codebase-map.md.
2. Prefer the lowest test level that proves the behavior: pure unit, repository, BLoC/Cubit, then widget.
3. Reuse test/helpers.dart fixtures when they fit; keep dates deterministic.
4. Use mocktail at infrastructure boundaries and bloc_test for state sequences.
5. Initialize SharedPreferences mock values before obtaining an instance.
6. Inject widget BLoCs explicitly and clean up streams, state managers, surface sizes, and other test state.
7. Check global getIt registrations; prevent order-dependent leakage.
8. Run the focused test first, then expand only as justified by docs/agent/testing.md.

Do not add integration or golden infrastructure unless the task explicitly requires it. Report exact checks run.

