<!-- Sections the doctor MERGES into the project's CLAUDE.md (never
clobber existing content). CLAUDE.md is always English. Replace
placeholders with the project's config paths. -->

## Project handoff protocol

Before planning or implementing any substantive change, read in this
order — from general (state) to specific (specs):

1. `{{CURRENT_STATE_PATH}}` — current state and next-step guidance
   (persistent memory bank: a snapshot, not a log)
2. `{{PLAN_PATH}}` — the working plan: capability slices and the
   per-slice Definition of Done
3. Accepted specs ({{SPECS_LOCATION}})
4. `{{ADR_DIR}}` — accepted architecture decisions

## Docs are normative (SDD)

- `{{PRD_PATH}}` — requirements with stable codes; every requirement is
  normative and testable.
- Engineering decisions → new ADR in `{{ADR_DIR}}` (+ registry row).
  Product decisions → journal entry in `{{JOURNAL_PATH}}` + PRD edit
  with changelog bump. An ADR is mutable while its slice is in flight
  and immutable once the slice's spec change is archived (then:
  change = new superseding ADR).
- Update `{{CURRENT_STATE_PATH}}` at the end of every slice/session.
- Update `{{TRACEABILITY_PATH}}` in every slice's DoD.

## Quality gates

`{{VERIFY_COMMAND}}` is the blocking ritual; it runs automatically
before every `git commit` via the sdd-loop hook. The hook fires BEFORE
the whole command executes — never chain a fix with the commit
(`fix … && git commit` verifies the unfixed tree); run fixes as a
separate command first. Generated files bypass the format-on-edit hook
— after a spec archive or any generator, run the project formatter as
a separate command before committing. E2e is intentionally NOT part of
verify — run targeted e2e specs per slice.

## Slice workflow (SDD)

The unit of work is a capability slice from `{{PLAN_PATH}}`. Per slice:
propose the spec change → implement tasks (commits land on the trunk as
`feat(S-NN): …`) → full DoD from the plan, including: launch-and-look
check against the real integrations BEFORE the review freeze (reviewing
code that does not actually run wastes review passes), then adversarial
review by the `sdd-loop:slice-reviewer` subagent (clean context,
different model; freeze the range at an explicit end SHA — never
`..HEAD` — and make no commits until the verdict lands; after a BLOCK
the fix commits get their own follow-up pass, chained until PASS;
critical/high findings block until fixed; a reviewer's suggested fix is
a hypothesis — validate it with the slice's tests before adopting),
archive the spec change, update `{{CURRENT_STATE_PATH}}` and
`{{TRACEABILITY_PATH}}`, and close with `/sdd-loop:slice-retro` →
`{{CYCLES_DIR}}/S-NN.md`.

Session hygiene: run one session per task group, not per slice. At
phase boundaries (implementation → review → closing) start a FRESH
session instead of compacting a long one — `{{CURRENT_STATE_PATH}}`
and the spec artifacts are the handoff, which is exactly what makes a
fresh context cheap. Field data: the costliest sessions are the ones
that compact twice instead of restarting, and most spend lands past
150k context.
