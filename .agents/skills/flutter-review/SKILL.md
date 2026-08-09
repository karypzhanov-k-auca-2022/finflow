---
name: flutter-review
description: Review FinFlow Flutter changes for correctness and repository-specific risks without modifying code on the first pass. Use for diff reviews, pull-request reviews, pre-merge audits, regression analysis, and architecture-conformance checks.
---

# Flutter review

Keep the first review pass read-only. Inspect the diff, then open only enough surrounding code and tests to validate behavior.

Check:

- correctness and edge cases;
- BLoC/Cubit ownership, lifecycle, and uncancelled subscriptions;
- async ordering, races, mounted checks, and duplicate submissions;
- transaction-form restoration and unsaved-change regressions;
- local-first behavior and accidental REST/Firestore semantic changes;
- user/guest storage scope and repository change notifications;
- route behavior, especially state-dependent transaction editing;
- generated-file edits and stale generation;
- missing English or Russian localization;
- unnecessary architectural cleanup;
- missing focused regression coverage.

Use docs/agent/architecture.md and docs/agent/data-sync.md only when relevant. Report actionable findings by severity with precise file locations. State when no findings are present and identify any verification not performed.

