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
  with changelog bump. ADRs are immutable (change = new ADR).
- Update `{{CURRENT_STATE_PATH}}` at the end of every slice/session.
- Update `{{TRACEABILITY_PATH}}` in every slice's DoD.

## Quality gates

`{{VERIFY_COMMAND}}` is the blocking ritual; it runs automatically
before every `git commit` via the sdd-loop hook. The hook fires BEFORE
the whole command executes — never chain a fix with the commit
(`fix … && git commit` verifies the unfixed tree); run fixes as a
separate command first. E2e is intentionally NOT part of verify — run
targeted e2e specs per slice.

## Slice workflow (SDD)

The unit of work is a capability slice from `{{PLAN_PATH}}`. Per slice:
propose the spec change → implement tasks (commits land on the trunk as
`feat(S-NN): …`) → full DoD from the plan, including: adversarial review
by the `sdd-loop:slice-reviewer` subagent (clean context, different
model, one pass over the slice diff; freeze the range at an explicit end
SHA — never `..HEAD` — and make no commits until the verdict lands;
critical/high findings block until fixed; a reviewer's suggested fix is
a hypothesis — validate it with the slice's tests before adopting),
launch-and-look check, archive the spec change, update
`{{CURRENT_STATE_PATH}}` and `{{TRACEABILITY_PATH}}`, and close with
`/sdd-loop:slice-retro` → `{{CYCLES_DIR}}/S-NN.md`.
