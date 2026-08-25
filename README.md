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
