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
verify — run targeted e2e specs per slice. Lint fails on warnings
(`--max-warnings 0` or the linter's equivalent), and a warning is
fixed, never silenced: no inline disable comments (`eslint-disable…`,
`@ts-ignore`), no rule switched off or downgraded, no new ignore
patterns to make the gate green. A genuine false positive changes the
lint config as a recorded decision (ADR or journal entry) in its own
commit. Generated artifacts that
verify checks against the source (API/OpenAPI snapshots, schema or
client codegen, lockfiles) are regenerated in the SAME commit as the
source change — never planned as a separate "update the snapshot"
task: the gate rejects the tree where the snapshot lags, so that task
physically cannot become a second commit (blocked twice in the field).
A test that reads a shape owned by other code (CLI output, a fixture,
an API response) asserts the field EXISTS before asserting its value —
otherwise a shape change elsewhere turns every assertion vacuous and
the test stays green (verify cannot see this; e2e is outside the gate).
More generally, a proof counts only if it could have been red:

- **Red on the before state.** A check meant to close a defect is run
  first on the unfixed tree, on data where the property actually
  differs; a reading that is the same before and after proves nothing
  (field case: the chosen e2e criterion held on every page before the
  fix, and the chosen test account could not show the difference).
- **Worst case from the inventory.** A property that depends on data
  (width on the text, length on the address, height on the name) is
  measured on the worst row the test data holds, not the row the
  configuration happened to hand over (a "refuted" review finding
  reappeared on an ordinary row).
- **Name what it ran on.** A green run states its target (device,
  platform, environment) read from the run itself, not from the
  runner's arguments or output labels (field case: an "ios" suite drove
  the Android emulator end to end and stayed green).

## Slice workflow (SDD)

The unit of work is a capability slice from `{{PLAN_PATH}}`. Per slice:
propose the spec change → implement tasks (commits land on the trunk as
`feat(S-NN): …`) → full DoD from the plan, including: launch-and-look
check against the real integrations BEFORE the review freeze (reviewing
code that does not actually run wastes review passes), then adversarial
review by the `sdd-loop:slice-reviewer` subagent (clean context,
different model; freeze the range as `<first slice commit>^..<end SHA>`
— the slice's first commit (recorded in session 1's handoff), not the
reviewing session's start; the `^` because `git diff a..b` excludes
`a`; an explicit end SHA, never `..HEAD` — and make no commits until
the verdict lands; after a BLOCK the fix commits get their own
follow-up pass from the previous end SHA, chained until PASS;
critical/high findings block until fixed; a reviewer's suggested fix is
a hypothesis — validate it with the slice's tests before adopting),
archive the spec change, update `{{CURRENT_STATE_PATH}}` and
`{{TRACEABILITY_PATH}}`, and close with `/sdd-loop:slice-retro` →
`{{CYCLES_DIR}}/S-NN.md`.

Session hygiene: run one session per task group, not per slice, and
start a FRESH session at a boundary instead of compacting a long one —
`{{CURRENT_STATE_PATH}}` and the spec artifacts are the handoff, which
is exactly what makes a fresh context cheap. Draw the boundaries by
the NATURE of the work, not only by phase: a context that WAITS (device
and e2e runs, builds, deploys, rate-limit windows, the owner) is billed
like one that writes — every resumed turn re-reads the whole context,
and a pause past the cache TTL re-caches it. Field data: two adjacent
sessions of one slice cost $15 in 30 min (code) and $86 in 6.5 h (device
runs, owner, review, closing, all in one context); a 12 h session with
49 min of API time spent 86% of its cost past 150k. So:

- Plan "reality" (device runs, launch-and-look, real-call capture) and
  "review + closing" as separate sessions.
- A question to the owner that may wait (overnight, an action on their
  side) ends the session: hand off instead of holding a large context.
- The reviewer is spawned from a context that did NOT develop the
  slice — a fresh closing session qualifies; don't open an extra
  context just to spawn it.

Task list hygiene (the change's `tasks.md` or equivalent):

- Every session block ends with a close task — tick the boxes, write
  the handoff, record the session's `/cost` — the LAST block included,
  so the slice total is a sum, not an after-the-fact reconstruction.
- An action only the owner can perform (a check on their own account,
  a real-credential capture) is its own task, never an item inside an
  agent's task: the agent cannot tick it, and archive does not wait.
- Changes the gate checks as a pair (a snapshot field and its DB
  column + migration, a source and its generated artifact) are ONE
  task — a split leaves a tree that fails typecheck or verify.
- A box is ticked on what the diff holds, not on what the task text
  planned. If the work went another way, rewrite the task line first
  (what was done, why it differs), then tick — boxes closed after the
  review freeze are read by nobody.
