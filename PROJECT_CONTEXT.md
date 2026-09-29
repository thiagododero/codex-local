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
- Current application-code head: `4b9ee8d` — `feat(ui): establish compact developer workspace shell`.

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

### Rejected UI baseline and current local access change

The first midnight/indigo UI baseline from `ddcadde` was reviewed locally and rejected by the user as visually inadequate. Its custom palette, shell styles, sidebar treatment, and draft design document were removed in `35b3c8d`; do not treat them as the design direction for future work.

`35b3c8d` changes the local launcher to use the backend's built-in authentication-free mode **only while bound to loopback**. It removes generated password/owner-password configuration and requires no login in the local UI. `127.0.0.1`, strict Origin checking, SameSite cookies, session secret, restricted workspace roots, and the separation between application security and agent permissions remain in place. It also removes the redundant global rollback-target panel; rollback remains contextual per turn with confirmation.

- **Implemented:** yes.
- **Validated locally:** `pnpm check`, production static-build verification, `zsh -n mac/ABRIR.command`, and a direct `GET /api/auth/session` after local relaunch (`authenticated: true`, `role: admin`). The local UI loaded without a password and without the global rollback panel.
- **CI/build status:** CI and Build Mac were successful for `2f7f958` (the now-rejected first UI baseline). Results for `35b3c8d` are pending after push.
- **Not user-confirmed as a physical Mac test:** this is an agent-run local smoke test, not a confirmation of the downloadable ZIP by the user.
- **Local limitation:** this shell has no `cargo`; `node scripts/verify-security-regressions.mjs` stops at `cargo fmt --check`. GitHub Actions remains the authoritative native/security validation until Rust is installed locally.

### Current UI redesign baseline (pending CI/package)

`4b9ee8d` begins the replacement direction after comparison with OpenCode/OpenChamber/Codex WebUI patterns: a compact developer workspace rather than a card-heavy chat page. It reduces transcript turn spacing, widens the readable work canvas, treats turns as a continuous work stream, makes the composer a centered primary control, and turns the active session into a restrained rail state. It uses existing semantic tokens and deliberately avoids importing third-party code/assets or adding a new brand palette.

- **Implemented and locally rendered:** yes.
- **Local checks:** `pnpm check` and static build verification passed.
- **Not yet CI/build validated:** results for `4b9ee8d` are pending after push.
- **Still incomplete by design:** inherited controls and panels need a second simplification pass; do not call the overall UI redesign finished.

## Current objective

Deliver **Codex Local v3** for macOS Apple Silicon using the real Codex app-server with free local Ollama models, while keeping its state isolated from normal Codex usage.

The immediate workstream is a product-UI redesign based on an evidence-backed comparison of mature open-source coding-agent interfaces. The next pass simplifies inherited controls and introduces work panels only on demand; the runtime, session isolation, localhost security controls, and permissions model remain unchanged.

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

Verify GitHub CI and the Apple Silicon package generated from `35b3c8d`, then manually test that new unmodified artifact on the target Mac.

Suggested validation sequence:

1. Download the unmodified artifact for `35b3c8d` and run `VERIFICAR.command`.
2. Launch that package with `ABRIR.command`.
3. Confirm installed Ollama models are detected automatically.
4. Confirm an older/stale session does not remain bound to a missing model.
5. Close with `CERRAR.command` and launch again.
6. Confirm the restarted app does not reuse a stale backend/build.
7. Test `/max`, `/safe`, and `/power`.
8. Test **TODO AL PALO** and **Modo seguro**.
9. Confirm the empty rollback panel no longer appears.
10. Confirm launch and relaunch require no password while remaining unreachable from non-loopback addresses.
11. Once a new UI direction is implemented, check it at desktop and narrow widths, including keyboard focus and the mobile sidebar.
12. Record every pass/failure in `docs/PROJECT_LOG.md` and update this file's validation status.

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
