---
name: flutter-feature
description: Implement features in the FinFlow Flutter repository by selecting and following the closest existing feature pattern. Use for new screens, flows, domain behavior, state management, persistence, navigation, localization, or cross-feature capabilities.
---

# Flutter feature

1. Use docs/agent/codebase-map.md to identify the closest implemented feature.
2. Inspect the affected feature and its nearest representative implementation.
3. Read docs/agent/architecture.md only when layer boundaries matter, a new pattern is introduced, the nearest implementation is ambiguous, or architecture knowledge is otherwise necessary.
4. Decide which layers and files are actually required. Do not force every feature into the deepest data/domain/presentation structure.
5. Plan state ownership, DI registration, navigation, localization, persistence, and generated output only when applicable.
6. Implement in small coherent changes, following the nearest BLoC/Cubit and constructor patterns.
7. Add the lowest useful tests using docs/agent/testing.md.
8. Run justified verification using docs/agent/commands.md.
9. Review the diff for unrelated refactors, missed translations, generated drift, lifecycle issues, and data-sync changes.

Read docs/agent/data-sync.md before introducing or changing stored or remote behavior. Preserve existing architectural exceptions unless changing them is explicit scope.
