# PROJECT LOG — Codex Local

This is an **append-only chronological work log** for durable project continuity.

Do not rewrite history to make old entries match the present. If something changes later, append a new entry. `PROJECT_CONTEXT.md` is the concise current-state snapshot.

## Entry format

Each meaningful work block should record:

- date/time and timezone when useful;
- objective;
- changes made;
- relevant commits;
- validation performed and result;
- known issues or uncertainty;
- current state;
- next step.

---

## 2026-09-29 — Context recovery and Mac candidate #31

### Objective
Recover the exact state of Codex Local v3 after the previous chat reached its usage limit, verify GitHub as the source of truth, and establish durable continuity for future chats.

### Recovered state
- Working branch: `codex-local-v3`.
- Active PR: #1, Draft.
- Branch was 38 application commits ahead of `main` at the recovered application-code head.
- The PR explicitly required Mac artifact validation before merge.

### Recent application changes recovered
- `6111c6a` — restart stale builds instead of reusing an old backend.
- `597e1ba` — clear the running-build marker on shutdown.
- `442b7c2` — migrate stale session models to detected Ollama models.
- `207adbf` — hide the rollback panel when no rollback targets exist.

### Validation recovered/observed
- The previously known green baseline was Build Mac #27 and CI #27.
- Build Mac Test Package #31 then completed successfully on source commit `207adbf`.
- CI #31 also completed successfully.
- Artifact created:
  - name: `Codex_Local_v3_Mac_Apple_Silicon`
  - artifact id: `11061450363`
  - digest: `sha256:6d447afb20d2f26f1c335640cc975c32c310c25849ff04a31a7093d69eaac789`
  - GitHub expiry: 2026-10-13
- The package is CI/build validated, but manual real-Mac validation is still pending.

### Continuity changes
A repository-level continuity system was established:
- `PROJECT_CONTEXT.md` for the canonical current snapshot.
- `docs/PROJECT_LOG.md` for chronological append-only history.
- `AGENTS.md` to tell coding agents to read and maintain both documents.

### Current state
The code candidate at `207adbf` passed CI and the Apple Silicon packaging workflow. The next meaningful validation is the real-Mac smoke test.

### Next step
Download/test Build Mac #31 on the target Mac and append the exact pass/fail results here. Update `PROJECT_CONTEXT.md` after the test.

---

## 2026-09-29 — Local checkout startup smoke test

### Objective
Open the current Codex Local v3 worktree on the target Apple Silicon Mac so development can continue against a running local instance.

### Changes made
- Installed the lockfile dependencies locally.
- Built the frontend static bundle from `c2bbc83`.
- The local machine did not have Rust/Cargo on `PATH`, so a fresh gateway binary could not be compiled from source there.
- Used the Apple Silicon backend from the existing verified Build Mac #31 artifact (`207adbf`); the only later commit, `c2bbc83`, adds continuity documentation.
- Assembled the development-only launcher layout under ignored `dist/local-package/` and opened it with `ABRIR.command`.

### Relevant commits
- `207adbf` — application candidate contained in Build Mac #31.
- `c2bbc83` — current branch head; continuity documentation only.

### Validation performed and result
- Local launcher started the private gateway on `127.0.0.1:4173`.
- `GET /healthz` returned `{"instanceTokenMatched":false,"status":"ok"}`.
- Chrome visibly loaded Codex Local, an existing Local · Ollama session, and the `Qwen 3.5 9B · Local` model selector.

### Known issues or uncertainty
- This was a startup/UI smoke test of a local development assembly, not an end-to-end validation of the downloaded ZIP.
- Rust/Cargo is unavailable on this Mac's current shell `PATH`, so the native gateway was not rebuilt locally from source.
- `VERIFICAR.command`, clean extracted-package startup, stale-session/build behavior, and `/max`, `/safe`, `/power` controls still require manual validation.

### Current state
Codex Local is running locally from the checkout-derived development package. No application-code change was made in this block.

### Next step
Run the complete real-package checklist against the unmodified Build Mac #31 artifact, then record the exact results before considering a merge.
