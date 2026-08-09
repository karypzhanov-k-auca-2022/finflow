---
name: flutter-bugfix
description: Diagnose and fix defects in the FinFlow Flutter repository with minimal, regression-focused changes. Use for incorrect behavior, crashes, broken state transitions, persistence or sync regressions, navigation defects, and failing Flutter tests.
---

# Flutter bugfix

1. Locate the affected feature with docs/agent/codebase-map.md.
2. Trace the relevant execution path from presentation through BLoC/Cubit, use case, repository, and datasource only as far as needed.
3. Inspect at most one or two analogous implementations when the local pattern is unclear.
4. Establish the root cause before editing. Document uncertainty instead of guessing.
5. Implement the smallest correct fix. Do not refactor unrelated architecture or silently remove existing exceptions.
6. Add or update a focused regression test when behavior can be isolated.
7. Choose targeted verification from docs/agent/testing.md and commands from docs/agent/commands.md.
8. Review the final diff for scope, generated files, localization, async lifecycle, and data-sync effects.

Read docs/agent/data-sync.md before changing persistence, refresh, identity, or offline behavior. Preserve transaction-form restoration when the form is involved.

