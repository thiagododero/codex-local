# AGENTS.md — Codex Local continuity rules

These instructions apply to repository work unless a more specific nested `AGENTS.md` overrides them.

## Before changing code

1. Read `PROJECT_CONTEXT.md`.
2. Read the newest relevant entries in `docs/PROJECT_LOG.md`.
3. Check the current branch head, active PR, and latest GitHub Actions.
4. Distinguish:
   - implemented/committed;
   - CI/build validated;
   - manually validated on the target Mac.
5. Do not assume a previous chat transcript is available.

## During work

- Keep commits focused and use descriptive commit messages.
- Preserve the existing isolation/security intent unless the task explicitly changes it.
- Do not merge the active Codex Local v3 PR until the required real-Mac validation has been recorded or the user explicitly changes that requirement.
- When GitHub state disagrees with prose documentation, investigate and update the documentation rather than silently trusting stale prose.

## After each meaningful work block

Update durable project context in the same working branch:

1. Update `PROJECT_CONTEXT.md` if current status, known-good status, active objective, branch/PR, validation state, or next step changed.
2. Append a new entry to `docs/PROJECT_LOG.md` containing:
   - objective;
   - changes;
   - relevant commits;
   - tests/Actions/manual checks and results;
   - unresolved problems;
   - current state;
   - next step.
3. Never mark a manual Mac test as passed unless the user/test actually confirmed it.
4. Keep old log entries intact; append corrections/new facts rather than rewriting history.

## Handoff goal

A new chat should be able to resume the project by reading:
- this file;
- `PROJECT_CONTEXT.md`;
- the latest `docs/PROJECT_LOG.md` entries;
- the active PR;
- latest branch commits;
- latest GitHub Actions.
