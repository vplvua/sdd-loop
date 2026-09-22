---
name: slice-plan
description: Slice the PRD into capability slices and generate or audit the capability plan. Use when the user asks to (re)build the capability plan, audit it against the PRD, or check that a proposed change maps to exactly one slice.
---

# Capability Slicing

Produce or audit the capability plan — the working plan of capability
slices derived from the PRD. Paths and documentation language come from
`.sdd/config.json` at the project root (defaults: `docs/capability-plan.md`,
`docs/PRD.md`). If the config is missing, stop and run
`/sdd-loop:project-doctor` first. With `role: satellite`, doc paths
cross into `primaryRoot` — if unreachable, ask the user to grant access
(`--add-dir` or `permissions.additionalDirectories`) before planning.

## Inputs (read in this order)

1. Current-state doc (memory bank) — where the project is now
2. The capability plan — current plan (if it exists; audit mode)
3. The PRD — normative requirements (FR-/NFR-/TC-/BC- codes)
4. The assumptions/open-questions journal (Р-/П-/В- entries or the
   project's equivalent codes)

## Slicing rules (normative)

- **One slice = one capability = one unit of agentic work.**
- **One capability = one real-behavior proof** (the slice is proven by
  observing real behavior, not only by unit tests). Work lands as a
  coherent series of `feat(S-NN):` commits on the trunk — trunk-based,
  no working branches or PRs unless the project decides otherwise.
- **Vertical**: every slice cuts the full contour UI → API → DB (or the
  project's full stack contour). No "backend-only" or "frontend-only"
  slices.
- **Self-contained**: deployable as soon as the slice lands on the
  trunk; the app stays fully working after every slice.
- Slices are ordered by dependency. If the project uses a milestone
  frame, each slice maps to exactly one milestone and the frame's order
  is respected.
- Scope that does not fit a slice is cut, not stretched.
- Every FR/NFR of the PRD must be covered by exactly one slice (traced
  in the traceability matrix); slices must not overlap on FR codes.
  Two legal exceptions, both marked explicitly in the matrix:
  plan-level constraints (cycle budgets and the like) trace to «plan»,
  not a slice; **cross-cutting NFRs** (a11y, content tone, offline
  states, compatibility) trace to the slice that proves them FIRST and
  are re-verified by a named DoD check in every later slice that adds
  surface they cover — one early slice cannot prove them for screens
  that don't exist yet, and dumping them all on the foundation slice
  both overloads it and falsifies the trace.

## Slice entry format

For each slice:

- **ID** `S-NN` and name
- **Goal**: one sentence, user-visible outcome
- **FR/NFR**: PRD codes covered
- **Vertical contour**: what changes in each stack layer
- **Acceptance scenarios**: 2–4 Given/When/Then scenarios (these become
  the slice's e2e specs)
- **Dependencies**: slice IDs it builds on
- **Non-goals**: what is explicitly out

## Definition of Done (every slice)

Throughout the slice: every session that works on it has a row in the
session ledger `<cyclesDir>/S-NN.sessions.md` (created by the PROPOSAL
session, which writes the first row; appended at session start; cost
filled by the session's close task or, later, by the owner's
`claude --resume <id>` → `/cost` — a finished session never stays open
waiting for it; see the CLAUDE.md session-ledger rules); the retro
needs every row's cost measured or marked `not measured: <reason>`.
Owner tasks in the change's task list are written in the owner's
language and are self-sufficient — where, what to click, the exact
line to paste; a device check names the build file, its commit and the
install command.

0. Multi-repo slices only: before implementation starts, every FR code
   of the consumer side is checked against the contract the producer
   side ships (DTOs, endpoints, fields). A gap is resolved in the spec
   or filed as an open question in the journal at spec acceptance —
   not discovered at the traceability matrix after the producer's ADR
   is archived (field lesson: two contract gaps surfaced only there,
   each one a superseding ADR away from a fix). Each repo's half
   counts as proposed / applied / archived only by what that repo's
   tooling shows (`openspec list` / `openspec/changes/` there), never
   by the other repo's handoff — the handoff checks it, not retells it
   (field lesson: a half interrupted at its first question was recorded
   as "proposed in both repos" and the claim lived for five sessions).
1. Spec artifacts (proposal, design, tasks, spec deltas) filled and
   validated; all task checkboxes `[x]`.
2. The project's `verify` script passes (blocking gate).
3. Smoke test against a real backing store: create / update / delete
   the slice's data and check invariants. For external gateway
   integrations, response fixtures are written from a CAPTURED REAL
   call, not from documentation — until the first real call succeeds,
   the integration counts as unverified regardless of test coverage.
4. E2e scenarios for the slice's critical paths pass, derived from the
   acceptance scenarios. Budget rate-limited external test resources
   (OTP quotas, test accounts, sandbox credits) for retries and
   per-platform runs, not for one ideal pass — and keep a spare.
5. Launch-and-look check: run the app, walk the slice's happy path
   against the real integrations, confirm it works; note the check in
   the current-state doc. Triage every owner remark from the check:
   a DEFECT against the slice's normative sources (spec, design
   canvas, PRD) is fixed inside the slice; a NEW REQUIREMENT (the
   sources don't say it, or say otherwise) becomes a journal entry and
   a separate change — never slipped into the slice (field lesson: two
   remarks on one screen went opposite ways — a spacing defect vs an
   equal-card-height requirement — and the split was re-derived in
   dialogue each time). This comes BEFORE the review freeze:
   reviewing code that does not actually run wastes chained passes
   (field lesson: five passes approved a login that was completely
   broken against the real SMS gateway).
6. Adversarial review by the `sdd-loop:slice-reviewer` subagent: clean
   context, different model than the author session, one pass over the
   slice diff frozen as `<first slice commit>^..<explicit end SHA>`.
   The start is the slice's FIRST commit — the first commit of the
   change's tasks (task 1.1), whatever its prefix: a `docs` PRD edit or
   a `test`/`chore` capture of real responses counts, the first `feat`
   is NOT the anchor — recorded in session 1's handoff; never the start
   of the session running the review, and
   the `^` is mandatory: `git diff a..b` excludes `a` (field lesson:
   three ranges in one slice series hid session 1, then the first
   commit itself; later both halves of a two-repo slice anchored on the
   first `feat` and left out the task-1.1 commits — one of them the
   capture holding scrubbed real legacy data; only reviewers reading
   around the range caught it).
   After a `BLOCK`, the fix commits get their own follow-up pass (a new
   frozen range `<previous end SHA>..<new end SHA>` — no `^` here, the
   previous end was already reviewed) — fixes are code too and introduce their own
   bugs; chain passes until `PASS`, with the union of ranges covering
   every commit that ships. For slices spanning multiple repositories,
   every involved repository's frozen range is reviewed.
   `critical`/`high` findings fixed (verify re-run); `medium`/`low` at
   the author's discretion, dispositions logged in the retro.
7. Spec change archived per the project's SDD tooling (e.g. OpenSpec:
   validate --strict passes, change archived, active list empty). An
   OpenSpec MODIFIED delta REPLACES the whole requirement block, so
   before archiving confirm each MODIFIED block carries the full
   requirement — every scenario of the main spec either kept or
   dropped on purpose; the tool itself already fails loudly on an
   unmatched header, so no post-archive text comparison is needed.
   Format the rewritten main specs before committing the archive.
   After archive the tooling no longer knows the change (`status` →
   not found, `list` → empty, apply cannot drive it), so steps 8–10
   are tracked ONLY by the current-state doc: name them explicitly
   under "Next" before the archiving session ends, or they get lost
   (field lesson: a closing task survived only a handwritten handoff).
8. Current-state doc updated: phase, done, next 1–2 tasks, blockers.
9. Traceability matrix updated: FR → slice → spec → test → demo check.
10. Session retrospective via `/sdd-loop:slice-retro`: metrics and
    friction → cycles doc (session list and cost from the ledger);
    small process fixes (≤3) applied, normative changes proposed to
    the user.

## Procedure

**Generate mode** (no plan exists): slice the PRD by the rules above,
write the capability plan with the slice entries, the shared DoD, and a
changelog section — in the documentation language from the config.

**Audit mode** (plan exists): check every rule — FR coverage is complete
and non-overlapping, slices are vertical and self-contained,
dependencies are acyclic and respected by ordering, milestone mapping
(if any) preserves the frame's order. Report violations with concrete
fixes; apply them if asked.

In both modes: product/process decisions changing normative docs are
recorded in the journal (+ changelog bumps in the touched docs). Never
edit PRD requirement codes from here.
