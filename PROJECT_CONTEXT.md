# PROJECT CONTEXT — Codex Local

> **Start here when resuming the project in a new chat or coding session.**
>
> This file is the canonical snapshot of the current project state. Detailed chronological history lives in `docs/PROJECT_LOG.md`. Agent instructions live in `AGENTS.md`.

## Current workstream

- Repository: `thiagododero/codex-local`
- Working branch: `codex-local-v3`
- Base branch: `main`
- Active PR: **#1 — Codex Local v3: Ollama + Mac one-click test package**
- PR state: **Draft**
- Merge policy for this workstream: **do not merge until the current Mac package is validated on the real Mac**.
- Last application-code commit before continuity docs: `207adbf` — `ui: hide empty rollback panel`.

## Validation status

As of 2026-09-29:

- **CI #31:** success.
- **Build Mac Test Package #31:** success.
- Build run id: `36627485957`.
- Source commit built: `207adbf1b9f31e514102919b981974549b399cbf`.
- Artifact: `Codex_Local_v3_Mac_Apple_Silicon`.
- Artifact id: `11061450363`.
- Artifact digest: `sha256:6d447afb20d2f26f1c335640cc975c32c310c25849ff04a31a7093d69eaac789`.
- Artifact retention expiry reported by GitHub: 2026-10-13.

**Important distinction:** CI and packaging are green, but the package has **not yet been recorded here as manually validated on the real Mac**. Do not describe the release candidate as fully validated until that manual check is completed and logged.

### Partial local-Mac smoke test

On 2026-09-29, the application was opened successfully on the target Apple Silicon Mac from a local development package assembled in the checkout:

- frontend static files built from `c2bbc83`;
- Apple Silicon backend extracted from the verified Build Mac #31 artifact for application commit `207adbf` (the commits differ only by continuity documentation);
- `GET /healthz` returned `status: ok`;
- Chrome rendered the Codex Local workspace, an existing Local · Ollama session, and the `Qwen 3.5 9B · Local` selector.

This is **physical-Mac validation of startup and basic UI availability only**. It is not a verification of the downloadable ZIP itself: `VERIFICAR.command`, clean-package launch, stale-build/session behavior, and the permission-control flows remain pending.

## Current objective

Deliver **Codex Local v3** for macOS Apple Silicon using the real Codex app-server with free local Ollama models, while keeping its state isolated from normal Codex usage.

## Implemented and expected to work

### Local runtime and isolation
- Dedicated `CODEX_HOME`, separate from the normal Codex configuration.
- Data stored under `~/Library/Application Support/Codex Local v3/`.
- Does not modify `~/.codex/config.toml`.
- Backend bound to `127.0.0.1`.
- Random login/session credentials.
- Up to two Codex app-server processes per session/workflow as designed.

### macOS launcher/package
- `ABRIR.command`
- `CERRAR.command`
- `CAMBIAR_CARPETA.command`
- `VERIFICAR.command`
- Build metadata and SHA-256 verification included in the generated package.
- GitHub Actions workflow creates an Apple Silicon ZIP.

### Codex/Ollama integration
- Detect Codex inside ChatGPT.app, Codex.app, or PATH.
- Start/detect Ollama as needed.
- Detect installed local Ollama models.
- Support the current free-model flow including `qwen3.5:9b` and `gpt-oss:20b`.
- Prefer Qwen 3.5 9B when installed on the target Mac.
- UI model selector is constrained to detected local models.
- Migrate stale saved session model selections to a detected Ollama model.

### Agent power controls
- UI power controls.
- **TODO AL PALO** enables:
  - `danger-full-access`;
  - approval policy `never`;
  - session auto-approval;
  - network enabled.
- **Modo seguro** restores:
  - `workspace-write`;
  - approval policy `on-request`;
  - manual approval;
  - network disabled.
- Chat commands:
  - `/max`
  - `/safe`
  - `/power`
- Session defaults configurable in Settings.
- User-chosen permission settings persist across restarts after the one-time migration.

## Latest fixes on the application-code head

- `6111c6a` — restart stale builds instead of reusing an old backend.
- `597e1ba` — clear the running-build marker on shutdown.
- `442b7c2` — migrate stale session models to detected Ollama models.
- `207adbf` — hide the rollback panel when there are no rollback targets.

## Next required step

Manually test the artifact produced by Build Mac #31 on the target Mac.

Suggested validation sequence:

1. Download the unmodified artifact and run `VERIFICAR.command`.
2. Launch that package with `ABRIR.command`.
3. Confirm installed Ollama models are detected automatically.
4. Confirm an older/stale session does not remain bound to a missing model.
5. Close with `CERRAR.command` and launch again.
6. Confirm the restarted app does not reuse a stale backend/build.
7. Test `/max`, `/safe`, and `/power`.
8. Test **TODO AL PALO** and **Modo seguro**.
9. Confirm the empty rollback panel no longer appears.
10. Record every pass/failure in `docs/PROJECT_LOG.md` and update this file's validation status.

## Continuity protocol

For every meaningful block of future work:

1. Read this file first.
2. Read the newest entries in `docs/PROJECT_LOG.md`.
3. Check the active PR, current branch head, and latest GitHub Actions before assuming status.
4. Make focused commits with descriptive messages.
5. Run or inspect the relevant validation.
6. Update this file when the **current state, known-good state, active objective, branch/PR, or next step** changes.
7. Append an entry to `docs/PROJECT_LOG.md` describing what was changed, why, commits, validation, unresolved problems, and next step.
8. Never record a manual hardware/user validation as passed unless it was actually confirmed.

## How to resume from a new ChatGPT chat

A good request is:

> Continue working on `thiagododero/codex-local`. Read `AGENTS.md`, `PROJECT_CONTEXT.md`, the latest entries of `docs/PROJECT_LOG.md`, PR #1, the latest commits on `codex-local-v3`, and GitHub Actions before changing anything.

That should provide enough durable context to continue without relying on the previous chat transcript.
