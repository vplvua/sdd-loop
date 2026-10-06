# sdd-loop — design

Claude Code plugin that packages a spec-driven development (SDD) workflow
with a built-in self-improvement loop, extracted from the fwdays
"Agentic Engineering: Greenfield" POC (Сервіс-деск Mini, 8 slices,
$528.94 total). TypeScript-first, full setup (no minimal/standard tiers).

## The loop it encodes

```
PRD (coded requirements) → capability plan (vertical slices + DoD)
  → per slice: propose → implement (verify gate on every commit)
  → adversarial review (maker ≠ checker, clean context, different model)
  → archive specs → retro (metrics + ≤3 applied process fixes)
  → fixes land in CLAUDE.md/skills → next slice is cheaper
```

Differentiator vs spec-kit/BMAD-style frameworks: the retro step is a
mandatory DoD item that _edits the process itself_ — the framework
learns from its own sessions.

## Plugin contents

### Skills

| Skill            | Origin                           | Genericization                                                                                                                      |
| ---------------- | -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `project-doctor` | new                              | the heart: idempotent readiness audit + step-by-step scaffold (see checklist below)                                                 |
| `slice-plan`     | POC `.claude/skills/slice-plan`  | drop course cycle-frame (Е-N) as hard requirement → optional "milestone frame"; paths from config                                   |
| `slice-retro`    | POC `.claude/skills/slice-retro` | drop fallow/Nx-specific wording → "project tooling" signal source; keep 4 signal sources, metrics, apply-now(≤3)/propose-only split |

### Agents

| Agent            | Origin                                 | Genericization                                                                                                                                                                                                                                       |
| ---------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `slice-reviewer` | POC `.claude/agents/slice-reviewer.md` | keep: adversarial stance, frozen SHA range, ≥5 examined candidates, BLOCK/PASS_WITH_NOTES/PASS verdict. Parameterize: normative-context paths (PRD/plan/ADR) read from project config; security-priority examples become placeholders filled at init |

### Hooks

| Hook                                              | Origin                     | Contract                                                                                                                   |
| ------------------------------------------------- | -------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| PostToolUse Write\|Edit → prettier + eslint --fix | POC `post-edit-format.sh`  | project has prettier + eslint (TS-first assumption)                                                                        |
| PreToolUse Bash `git commit` → `npm run verify`   | POC `pre-commit-verify.sh` | project defines a blocking `verify` npm script; plugin defines the _contract_, doctor scaffolds the stack-specific content |

### Templates (assets the doctor scaffolds from)

PRD skeleton (coded FR/NFR/TC/BC requirements + changelog), MADR ADR
template + registry README, capability-plan skeleton (slice entry format

- shared DoD), `current-state.md` (memory bank), traceability matrix,
  assumptions/open-questions journal (Р-/П-/В-), `docs/cycles/` retro
  template, CLAUDE.md section blocks (handoff protocol, quality gates,
  slice workflow), `verify` script wiring for package.json.

## /project-doctor

Idempotent: run on day 1 (scaffolds everything, interview-style) or on
an existing project (audits, reports a readiness matrix, offers to fix
gaps). Every check: **verify → status → offer scaffold**.

Checklist (full set):

1. **Config** — `.sdd/config.json` exists (docs language, docs paths,
   stack facts). First run: interview (incl. docs language — Ukrainian /
   English / other), write config.
2. **Spec layer** — PRD with stable requirement codes + changelog;
   glossary; ADR dir + registry. _Completeness audit is agentic, not
   file-existence_: every requirement testable, coded, NFRs present.
3. **Plan layer** — capability plan with vertical slices + per-slice DoD;
   traceability matrix; assumptions journal.
4. **Memory layer** — `current-state.md`; CLAUDE.md contains the handoff
   protocol (read order: state → plan → specs → ADRs).
5. **Verification layer** — `verify` npm script exists, is blocking, and
   passes; hooks active (format-on-edit, verify-on-commit).
6. **Maker ≠ checker** — `slice-reviewer` agent available (from plugin),
   CLAUDE.md documents the freeze-range rule and DoD review step.
7. **Improvement loop** — `docs/cycles/` with template; retro wired as
   the final DoD step.
8. **SDD working layer** — OpenSpec installed and initialized
   (`openspec/config.yaml`); doctor checks/points to `npx openspec init`,
   does NOT vendor OpenSpec skills.
9. **Tooling** — recommended MCP servers for the stack; static analysis
   (fallow or equivalent) wired into verify. Recommend, don't hard-fail.

Output: readiness matrix (layer → status → gap → offered fix), then
step-by-step scaffolding of accepted fixes. Re-run must converge to all
green. Acceptance test: doctor run on the originating POC repo reports
green (modulo course-specific items).

## Project-side state

Everything the plugin writes into a target project lives in normal
project files (docs/, CLAUDE.md, package.json, .claude/settings.json for
project-local hook config if needed) + `.sdd/config.json` for doctor
state. The plugin itself stays read-only/upgradeable; drift between
scaffolded docs and templates is expected and fine. Rules added to the
templates in later releases reach an existing project only through the
doctor's rule-by-rule reconciliation, keyed by `templatesVersion` in
`.sdd/config.json` (slice-retro proposes it when the plugin is newer)
— the doctor proposes merges, never
reverts.

### Field pattern: a second SDD project on a long-lived branch

Not scaffolded by the doctor yet — recorded from moeosbb-platform
(ADR-P-0023), where the board admin panel is its own SDD project in a
worktree (`../moeosbb-admin`, branch `admin`) sharing code, specs and
ADRs with `main`:

- **Branch-only layer.** The SDD paths that belong to one project
  (`.sdd/config.json`, `CLAUDE.md`, `openspec/config.yaml`, its docs
  dir) carry a git attribute (`sdd-branch-only`) in a `.gitattributes`
  kept identical on both branches. A plain `git merge` clobbers them
  silently — a merge driver never runs for a path only one side
  changed or added — so every merge goes through a script that merges
  with `--no-commit`, resets each attributed path to the target
  branch's state (restore, or drop what only the source has), and
  stops before the commit so the verify hook gates the merged tree.
- **Direction and timing.** `main → branch` before every proposal, before
  taking a shared number (ADR), and before `branch → main`;
  `branch → main` after every archived slice, run from a session in the
  main checkout — the closing session hands it over, never runs it
  across worktrees (the verify hook gates `CLAUDE_PROJECT_DIR`, i.e.
  the wrong tree).
- **The sync script must survive being merged.** bash reads a script as
  it runs; a merge that rewrites the script mid-run executes the rest
  from the new file. Wrap the body in a function called on the last
  line with `exit` (field lesson: the first sync after a fix to the
  script ran half old, half new and split a path with spaces). It also
  checks that a merge actually started (`MERGE_HEAD`) instead of
  swallowing the failure.
- **One gate base for both branches.** A diff-scoped gate (fallow
  audit) measures from the merge-base with the branch's upstream — on
  the side branch every pushed commit becomes the base, so a duplicate
  split across commits passes there and blocks the hand-off on main.
  Pin the base to the merge-base with `origin/main` on both branches.
- **Separate local infra per worktree** (compose project name, ports):
  a `down -v` in one worktree must not wipe the other's database.

Open: whether the doctor should scaffold this (attribute file, sync
script, CLAUDE.md section) when a project declares a second SDD layer.

## Resolved questions

- OQ-1 (plugin layout): confirmed from official docs — manifest in
  `.claude-plugin/plugin.json`; `skills/<name>/SKILL.md`, `agents/*.md`,
  `hooks/hooks.json` + `scripts/` at plugin root; hook paths via
  `${CLAUDE_PLUGIN_ROOT}`; templates live inside the doctor skill dir
  (skill supporting files). Local dev: `claude --plugin-dir`.
- OQ-2 (marketplace): yes — this repo is both marketplace and plugin
  (`.claude-plugin/marketplace.json` with `source: "./"`). Install:
  `/plugin marketplace add <owner>/sdd-loop` →
  `/plugin install sdd-loop@sdd-loop`.

## Open questions

- OQ-3: how much of the POC's CLAUDE.md "lessons" section becomes
  template content vs stays project-specific (currently: generic rules —
  freeze-range, no-chained-commit — are in the templates; tool-specific
  lessons stay in the project).
