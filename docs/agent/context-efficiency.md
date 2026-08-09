# Context efficiency

- Start with docs/agent/codebase-map.md and search for the relevant symbol or route before opening files broadly.
- Read only the execution path involved in the task: UI/state manager, use case, repository, and datasource as needed.
- Inspect at most one or two analogous implementations unless differences require more.
- Do not recursively read entire feature trees by default.
- Do not inspect generated localization or Freezed Dart files unless generation output itself is relevant.
- Reuse docs/agent/commands.md instead of rediscovering commands.
- Prefer the lowest useful targeted test while iterating; avoid full flutter test after every edit.
- Use docs/agent/data-sync.md before persistence, auth identity, refresh, or offline changes.
- Avoid subagents for simple or tightly coupled tasks.
- Start independent Jira tasks in fresh Codex threads so task-specific context does not accumulate.
- Keep status updates and final reports focused on decisions, changed files, and checks actually run.

AGENTS.md and docs/agent are navigation aids, not substitutes for source evidence. Verify current code whenever correctness depends on implementation details.

