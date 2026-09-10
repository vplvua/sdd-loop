# sdd-loop

Claude Code plugin for TypeScript projects: a spec-driven development
(SDD) workflow with a built-in self-improvement loop. Extracted from a
real 8-slice agentic-engineering POC.

The loop it encodes:

```
PRD (coded requirements) → capability plan (vertical slices + DoD)
  → per slice: propose → implement (verify gate on every commit)
  → adversarial review (maker ≠ checker, clean context, different model)
  → archive specs → retro (metrics + ≤3 applied process fixes)
  → fixes land in CLAUDE.md/skills → next slice is cheaper
```

## Contents

| Component                       | What it does                                                                                                                                                      |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/sdd-loop:project-doctor`      | Audits/scaffolds the 7 SDD layers: spec, plan, memory, verification, maker≠checker, retro loop, tooling. Idempotent readiness matrix.                             |
| `/sdd-loop:prd`                 | PRD interviewer & auditor: Socratic section-by-section elicitation (interview) and completeness/testability check (audit). Editor, not generator.                 |
| `/sdd-loop:slice-plan`          | Slices the PRD into vertical capability slices; generates or audits the capability plan and the shared DoD.                                                       |
| `/sdd-loop:slice-retro`         | Post-slice retrospective: metrics, friction from 4 signal sources, ≤3 small process fixes applied.                                                                |
| `sdd-loop:slice-reviewer` agent | Adversarial review of a finished slice on a frozen SHA range, different model than the author session.                                                            |
| Hooks                           | Format-on-edit (prettier + eslint --fix) and verify-on-commit (`npm run verify` gates every `git commit`). Both degrade gracefully in projects without the tools. |

Project-side state lives in `.sdd/config.json` (docs language, paths,
verify command) — written by the doctor's first-run interview.

## Where do the components live?

Nothing is copied into your project — unlike tools that vendor files
into `.claude/`, a plugin serves its components from the plugin cache
(`~/.claude/plugins/cache/`) for as long as it is enabled:

- **Skills** appear as namespaced commands — type `/sdd-loop:` to see
  all four in the autocomplete.
- **Agent** — `sdd-loop:slice-reviewer` shows up in `/agents`; spawn it
  by name. Subagents always start with a clean context, and its model
  is pinned to `sonnet` in frontmatter, so maker ≠ checker holds on
  both axes regardless of the author session's model.
- **Hooks** are active automatically — inspect them via `/hooks`, not
  `.claude/settings.json` (no entries there is normal).

The only files ever written into your repo are the ones the doctor
scaffolds (docs, configs, `.sdd/config.json`). This is deliberate:
plugin updates propagate by version bump without touching your repo,
and there is nothing to drift.

## Multi-repo projects

One documentation set can serve several repos (app + backend). Exactly
one repo is the **primary** (owns PRD, plan, journal, ADRs,
current-state, cycles); the others are **satellites** — their
`.sdd/config.json` declares `role: satellite` and `primaryRoot`
(relative path to the primary checkout), and doc paths point through
it. The doctor sets this up when it detects a sibling primary; it also
offers to add the primary to `permissions.additionalDirectories` in the
satellite's `.claude/settings.json` so every session can read the
shared docs. Satellites keep their own verify chain, per-repo OpenSpec
specs, and CLAUDE.md; shared docs are audited only from the primary.

## Install

```
/plugin marketplace add vplvua/sdd-loop
/plugin install sdd-loop@sdd-loop
```

Then in your project: `/sdd-loop:project-doctor`.

Starting a brand-new project? Walk
[docs/new-project-checklist.md](docs/new-project-checklist.md) first —
what to think through and scaffold before the doctor takes over.

## Requirements

- Node.js ≥ 20, `jq` (used by hooks)
- TypeScript project (prettier/eslint assumed; hooks skip silently when absent)
- Recommended: [OpenSpec](https://github.com/Fission-AI/OpenSpec) as the
  spec working layer — the doctor checks for it but does not vendor it

## Local development

```
claude --plugin-dir /path/to/sdd-loop
```

Skill edits apply live; hook/agent changes need `/reload-plugins`.

## Design

See [docs/DESIGN.md](docs/DESIGN.md).
