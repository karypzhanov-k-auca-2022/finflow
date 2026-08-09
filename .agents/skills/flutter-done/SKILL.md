---
name: flutter-done
description: Determine whether a FinFlow Flutter change is complete by selecting justified verification, inspecting the final diff, and reporting exact evidence. Use before handoff, completion claims, commits, pull requests, or when asked whether work is done.
---

# Flutter done

1. Inspect git status and the complete diff.
2. Confirm changed files match task scope and no unrelated production, dependency, generated, native, or Firebase files changed.
3. Select DOCUMENTATION / AGENT INFRASTRUCTURE, SMALL, MEDIUM, or LARGE verification from docs/agent/testing.md.
4. Run only justified commands from docs/agent/commands.md; prefer targeted tests during iteration.
5. Recheck the diff after any formatter or generator.
6. Confirm localization and generated outputs are consistent when affected.
7. Report exactly which commands passed, failed, or were not run.
8. Summarize remaining risks or uncertainties. Do not declare completion while required checks or work remain.

Never imply analyzer, tests, formatting, or generation passed without successful command output.
