---
name: project-doctor
description: Audit and scaffold a project's SDD readiness across seven layers (spec, plan, memory, verification, review, retro loop, tooling). Run on a fresh repo to set everything up step by step (interview mode), or on an existing project to get a readiness matrix with targeted fixes. Idempotent — safe to re-run anytime; a healthy project converges to all green.
argument-hint: "[audit|init]"
---

# Project Doctor

Check → status → offer scaffold, for every layer of the SDD loop. Never
overwrite an existing non-empty artifact without explicit confirmation;
report drift, don't revert it. Templates live in `templates/` next to
this skill — they are structural skeletons in English; when scaffolding,
translate headings and boilerplate into the project's documentation
language from the config and fill placeholders from the interview.

Prerequisites: the doctor audits and scaffolds the *process* layer, not
the application. If the repo has no `package.json` / app scaffold, stop
and tell the user to scaffold their stack first (their framework's CLI),
pointing them to `docs/new-project-checklist.md` in the plugin repo —
then re-run.

Modes (auto-detected, or forced via argument):

- **init** — no `.sdd/config.json` in the project: run the interview,
  write the config, then walk the checklist scaffolding each missing
  layer, pausing for user input where content is needed (product idea
  for the PRD, stack facts for verify). Suggest one commit per layer.
- **audit** — config exists: run all checks read-only first, print the
  readiness matrix, then offer fixes for each gap (user picks).

## The interview (init mode)

Ask only what cannot be detected. Detect first: package manager, test
runner, linter/formatter, monorepo tool, e2e framework, existing docs.
Then ask:

1. Documentation language (code, commits, and CLAUDE.md are always
   English; this sets only the `docs/` language).
2. One-paragraph product idea (seeds the PRD draft).
3. Deployment target + environments (seeds ADR candidates and the DoD
   smoke/launch checks).
4. Anything already decided that should become day-0 ADRs (stack,
   architecture, auth approach, hosting).

Write the answers to `.sdd/config.json` from `templates/config.template.json`.

## Config contract (`.sdd/config.json`)

All other sdd-loop skills and the `slice-reviewer` agent read this file.
Fields: `language` (BCP-47 code for docs), `docsDir`, `paths` (prd,
plan, currentState, traceability, journal, glossary, adrDir, cyclesDir),
`verifyCommand`, `openspec` (bool). Keep paths project-relative.

## Readiness checklist

Walk in order — each layer builds on the previous. For every item
report: `OK` / `GAP (what's missing)` / `N/A (why)`.

### 1. Config

`.sdd/config.json` exists and its paths resolve. Missing → interview.

### 2. Spec layer

- PRD at `paths.prd` with **stable requirement codes** (FR-/NFR-/TC-/BC-
  or the project's equivalent), a changelog section, and NFR coverage
  (security, performance, observability at minimum).
- This check is **agentic, not file-existence**: delegate the PRD part
  to `/sdd-loop:prd` in audit mode (testability, code uniqueness, NFR
  coverage, non-goals, changelog); its `READY` maps to OK, `NEEDS_WORK`
  to GAP with the blocking items as the gap list. When scaffolding a
  missing/skeletal PRD, offer `/sdd-loop:prd` interview mode instead of
  filling the template inline.
- Glossary at `paths.glossary` — terms used consistently in the PRD.
- ADR dir at `paths.adrDir` with a README registry
  (`templates/adr-README.template.md`, MADR format per
  `templates/adr.template.md`). Day-0 decisions from the interview
  become the first ADRs.
- Scaffold sources: `templates/PRD.template.md`,
  `templates/glossary.template.md`.

### 3. Plan layer

- Capability plan at `paths.plan`: vertical slices with the entry format
  and the shared per-slice DoD (see `sdd-loop:slice-plan` — offer to run
  it in generate mode once the PRD is ready; scaffold skeleton:
  `templates/capability-plan.template.md`).
- Traceability matrix at `paths.traceability`
  (`templates/traceability-matrix.template.md`).
- Assumptions/open-questions journal at `paths.journal`
  (`templates/assumptions-journal.template.md`).

### 4. Memory layer

- Current-state doc at `paths.currentState` — a snapshot, not a log:
  phase / done / next 1–2 tasks / blockers
  (`templates/current-state.template.md`).
- CLAUDE.md contains the **handoff protocol**: read order state → plan →
  specs → ADRs, plus the quality-gates and slice-workflow sections
  (`templates/claude-md-sections.template.md`). Merge into an existing
  CLAUDE.md — never clobber it.

### 5. Verification layer

- `verify` script in package.json: a blocking chain of the project's
  gates (typical TS chain: format check → lint → typecheck → static
  analysis → spec validation → unit tests → build; e2e intentionally NOT
  in verify — run targeted per slice). Compose it from the tools
  detected in the project; propose additions (e.g. a dead-code/dupes
  auditor) as recommendations, not hard failures.
- Run it once: `OK` requires a passing verify, not just an existing one.
- Hooks: this plugin ships format-on-edit and verify-on-commit hooks —
  active automatically wherever the plugin is enabled. Check only that
  the project does not have conflicting duplicate hooks in
  `.claude/settings.json`. Resolution guidance: while the plugin is
  dev-loaded (`--plugin-dir`), keep the project-local hooks (the repo
  stays self-sufficient) and accept the duplicate firing in plugin-dev
  sessions; once the plugin is permanently enabled at project scope,
  remove the project duplicates so verify does not run twice per commit.

### 6. Maker ≠ checker

- The `sdd-loop:slice-reviewer` agent is available (comes with this
  plugin — verify the plugin is enabled at project scope so teammates
  get it too).
- CLAUDE.md documents the review DoD step and the freeze-range rule
  (explicit end SHA, no commits until the verdict lands) — part of the
  CLAUDE.md sections template.

### 7. Improvement loop

- `paths.cyclesDir` exists with a README retro template
  (`templates/cycles-README.template.md`).
- The retro (`/sdd-loop:slice-retro`) is wired as the final DoD step in
  the capability plan and CLAUDE.md.

### 8. SDD working layer (recommended)

- OpenSpec (or equivalent) initialized: `openspec/config.yaml` present,
  `openspec validate --all --strict` wired into verify. If absent, point
  to `npx openspec init` — do NOT vendor or replace its skills.

### 9. Tooling (recommended, never blocking)

- MCP servers useful for the detected stack (e.g. framework docs
  servers, a browser-automation server for e2e debugging).
- Static analysis beyond ESLint (dead code, duplication, complexity)
  wired into verify.

## Output: readiness matrix

Always end the audit with one table:

| #   | Layer | Status | Evidence | Gap → offered fix |
| --- | ----- | ------ | -------- | ----------------- |

For `OK` rows put the concrete proof in Evidence (what was checked and
found) and leave the fix cell empty; only `GAP` rows carry a fix offer.

Then scaffold accepted fixes one layer at a time (suggest a
`chore(sdd): …` commit per layer). Re-run at the end of a full init to
prove convergence: the matrix must be all green / N/A.
