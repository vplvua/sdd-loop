---
name: slice-plan
description: Slice the PRD into capability slices and generate or audit the capability plan. Use when the user asks to (re)build the capability plan, audit it against the PRD, or check that a proposed change maps to exactly one slice.
---

# Capability Slicing

Produce or audit the capability plan — the working plan of capability
slices derived from the PRD. Paths and documentation language come from
`.sdd/config.json` at the project root (defaults: `docs/capability-plan.md`,
`docs/PRD.md`). If the config is missing, stop and run
`/sdd-loop:project-doctor` first.

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

1. Spec artifacts (proposal, design, tasks, spec deltas) filled and
   validated; all task checkboxes `[x]`.
2. The project's `verify` script passes (blocking gate).
3. Smoke test against a real backing store: create / update / delete
   the slice's data and check invariants.
4. E2e scenarios for the slice's critical paths pass, derived from the
   acceptance scenarios.
5. Adversarial review by the `sdd-loop:slice-reviewer` subagent: clean
   context, different model than the author session, one pass over the
   slice diff frozen at an explicit end SHA. `critical`/`high` findings
   fixed (verify re-run); `medium`/`low` at the author's discretion,
   dispositions logged in the retro.
6. Launch-and-look check: run the app, walk the slice's happy path,
   confirm it works; note the check in the current-state doc.
7. Spec change archived per the project's SDD tooling (e.g. OpenSpec:
   validate --strict passes, change archived, active list empty).
8. Current-state doc updated: phase, done, next 1–2 tasks, blockers.
9. Traceability matrix updated: FR → slice → spec → test → demo check.
10. Session retrospective via `/sdd-loop:slice-retro`: metrics and
    friction → cycles doc; small process fixes (≤3) applied, normative
    changes proposed to the user.

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
