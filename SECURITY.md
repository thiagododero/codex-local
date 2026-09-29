# Security

Codex Local is a local-first Codex UI. The intended default deployment is a single-user Mac with the gateway bound to loopback only.

## Safe default

The macOS launcher in `codex-local-v3` is expected to start with:

- `HOST=127.0.0.1`
- no public tunnel
- one explicit allowed project root
- `sandbox_mode = "workspace-write"`
- `approval_policy = "on-request"`
- sandbox network disabled by default
- `CODEX_WEBUI_FORCE_YOLO` disabled
- strict same-site cookies
- origin checks for mutating browser requests
- owner checks for terminal/runtime host actions
- system shutdown integration disabled

## Full access

`danger-full-access`, approval policy `never`, network access, public tunnels, and broad filesystem roots materially reduce isolation. They should only be enabled deliberately for a specific trusted task.

A local model can still make mistakes or follow malicious instructions contained in a repository. Treat model-generated shell commands, install scripts, migrations, deploys, and destructive Git operations as untrusted until reviewed.

## Files and credentials

The gateway contains path-boundary checks, symlink-write defenses, and a sensitive-file denylist for common secrets. These controls reduce exposure but are not a complete secrets boundary. Keep credentials outside project trees where possible and do not rely on an AI sandbox as the only protection for important data.

## Build provenance

The macOS test package is built by GitHub Actions from the repository source using lockfiles. Build actions are pinned to exact commits. The package contains build metadata and SHA-256 checksums.

Test builds are currently not notarized with an Apple Developer ID. macOS Gatekeeper can therefore warn before first launch. A production release should use Developer ID signing and Apple notarization.

## Reporting

Do not publish secrets or exploit details in a public issue. Until a private security reporting channel is configured, contact the repository owner privately.
