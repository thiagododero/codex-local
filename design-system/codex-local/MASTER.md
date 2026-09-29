# Codex Local — Design System

This is the durable visual source of truth for the Codex Local workspace. It applies to product UI, not marketing pages.

## Product job and audience

Codex Local is a private workstation for people who run coding agents locally on a Mac. Its single job is to make the state of an agent session legible and controllable: choose work, see what is happening, decide on permissions, and act without losing context.

## Visual thesis

**Local workstation, not browser chat.** The interface should feel like a quiet, capable control surface: concentrated information, calm surfaces, and one precise active signal. It should never resemble a generic AI landing page or a pile of rounded white cards.

The signature element is the **local-signal glow**: a restrained indigo field anchored in the application chrome and the active session. It communicates that work is happening on this machine without resorting to branding assets or decorative gradients everywhere.

## Theme tokens

| Role | Light | Dark | Purpose |
| --- | --- | --- | --- |
| Canvas | `#f5f7fb` | `#080d18` | Workspace background |
| Sidebar | `#eef2f8` | `#0c1322` | Navigation plane |
| Strong surface | `#ffffff` | `#111a2b` | Composer, active content |
| Soft surface | `#f7f9fd` | `#0e1626` | Secondary controls |
| Primary text | `#172033` | `#f3f6ff` | Titles and essential state |
| Secondary text | `#3d4b63` | `#c8d2e6` | Body copy |
| Muted text | `#68748b` | `#8f9bb3` | Metadata |
| Active signal | `#6256e8` | `#9186ff` | Focus, current session, primary action |
| Divider | `#dbe2ee` | `#26334a` | Separation without visual noise |

Amber is reserved for warnings or work requiring attention. Red is destructive only. Green is successful completion only. Do not use status colors as decorative accents.

## Type and density

- Product typography: the existing system sans stack for application text; mono only for paths, commands, token counts, and code.
- Dense by default: use 4 / 8 / 12 / 16 / 24 / 32 px spacing steps.
- Titles are compact and weighty; metadata is quieter but remains readable at a minimum 11 px with sufficient contrast.
- Do not introduce a remote font dependency solely for visual decoration.

## Layout rules

```text
┌──────── navigation ────────┬──────────────────────── workspace ────────────────────────┐
│ brand + local state        │ context header / tabs                                      │
│ primary action             │                                                            │
│ sessions (active has       │ focused transcript, bounded readable measure               │
│ indigo edge, not a card)  │                                                            │
│                            │                                                            │
│ account / runtime          │ persistent composer with visible local controls            │
└────────────────────────────┴────────────────────────────────────────────────────────────┘
```

- Sidebar is a navigation plane, not a card column. The active session receives a 3 px indigo edge and a subtle surface shift.
- The transcript has a readable maximum width while tool output can grow inside its own horizontally scrollable region.
- Composer is the primary physical control. It stays visually grounded at the bottom and gets the indigo signal only while focused.
- On small screens, navigation is a temporary drawer; focused controls must not be obscured by the transcript dock or header.

## Interaction rules

- Use Lucide icons only; no emoji icons.
- Every interactive element has an accessible name and a visible keyboard focus ring.
- Hover is restrained: surface or border changes, never layout shifts that move neighbors.
- Respect `prefers-reduced-motion`; no essential state depends on animation.
- Maintain 4.5:1 contrast for normal text in both themes.
- Selection, running work, warnings, and errors must have text or icon treatment in addition to color.

## Implementation guardrails

- Use the semantic runtime variables from `src/lib/theme-customization.ts`; do not add raw hex values to individual screens unless the value is a documented status color.
- Preserve user-selected theme settings. New defaults define the product baseline; they do not overwrite custom palettes.
- Do not import source code, visual assets, or brand material from reference projects without a separate license review.
- Evaluate the shell at 375 px, 768 px, 1024 px, and 1440 px before describing a UI change as complete.

## Reference projects

- OpenCode: hierarchy and agent-workflow ergonomics.
- Codex WebUI (`lezi-fun`): native app-server approvals, diffs, and terminal context.
- Open WebUI: model-management clarity.

These are interaction references only. Codex Local retains its own runtime, security model, and visual identity.
