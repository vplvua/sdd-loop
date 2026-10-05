<!-- Sections the doctor MERGES into the project's CLAUDE.md (never
clobber existing content). CLAUDE.md is always English. Replace
placeholders with the project's config paths. -->

## Project handoff protocol

Before planning or implementing any substantive change, read in this
order — from general (state) to specific (specs):

1. `{{CURRENT_STATE_PATH}}` — current state and next-step guidance
   (persistent memory bank: a snapshot, not a log). A claim it makes
   about tooling state (a change proposed, applied, archived — in this
   or another repo) is checked against the tooling before acting on
   it and before writing it.
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
commit. Not a bypass: `@ts-expect-error` in a type-level test, where
the expected compile error IS the assertion (say so in its comment). Generated artifacts that
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
- **One row per named value.** A spec sentence that enumerates values
  of one state ("`report_unavailable`, `404` and `409`") gets a test
  table with a row for EACH named value, through the screen; a row
  green because the value fell into the default branch is not proof
  of that value (field case: two of three statuses had rows, the
  third reached the wrong banner and the second was right by
  accident). A table in the code counts the same way: every code a
  classifier (code → effect) names gets its own test through the
  screen, and its line in the spec — what an effect means is decided
  by what the screen does after it (field case: `409 suspended` had
  an effect row and a comment promising a banner; cached data beat
  the error and the banner never showed).
- **A zero needs a control.** A filter expected to print nothing
  (a log scan for personal data, a search for a removed phrase) first
  counts 1 on a planted control line fed through the same command
  (field case: `grep -P` does not exist on macOS, and every filter
  printed 0 — including those that had something to find; use
  `perl -ne` or `grep -E`).
- **Not from the cache.** A run whose result depends on something the
  task runner does not hash — an environment variable (`TZ`, a feature
  flag) — goes past its cache (`--skip-nx-cache`, `turbo --force`),
  and the record quotes the line that says so (field case: a timezone
  mutant stayed "4 passed", replayed from the cache).
- **Hold the transient.** A test that reads a transient state
  ("pending", a spinner) holds the request that would end it — a read
  over an unheld response is a race, even while green (field case:
  the rule lived in an old fix and its commit message, and a new test
  repeated the old shape).

## Slice workflow (SDD)

The unit of work is a capability slice from `{{PLAN_PATH}}`. Per slice:
propose the spec change → implement tasks (commits land on the trunk as
`feat(S-NN): …`) → full DoD from the plan, including: launch-and-look
check against the real integrations BEFORE the review freeze (reviewing
code that does not actually run wastes review passes), then adversarial
review by the `sdd-loop:slice-reviewer` subagent (clean context,
different model; freeze the range as `<first slice commit>^..<end SHA>`
— the slice's first commit = task 1.1's commit whatever its prefix
(`docs`/`test`/`chore` included, not the first `feat`), recorded in
session 1's handoff, not the reviewing session's start; the `^` because `git diff a..b` excludes
`a`; an explicit end SHA, never `..HEAD` — the trunk HEAD before the
reviewing session opened; that session's ledger/handoff commit is
docs-only and lands after the end SHA, outside the range; no code
commits until the verdict lands; after a BLOCK the fix commits get their own
follow-up pass from the previous end SHA, chained until PASS; a fix
is proven red-before on the exact line the finding named and sized
from the inventory the finding is one item of, not from its words —
each pass that finds a flaw in the previous fix is paid twice;
critical/high findings block until fixed; a reviewer's suggested fix is
a hypothesis — validate it with the slice's tests before adopting),
archive the spec change, update `{{CURRENT_STATE_PATH}}` and
`{{TRACEABILITY_PATH}}`, and close with `/sdd-loop:slice-retro` →
`{{CYCLES_DIR}}/S-NN.md`.

Proposal: a decision about user-visible behavior (what a screen shows,
when it refreshes, how a control looks) that no normative source
states — PRD, design canvas, journal — is not taken from parity with
an existing product or from an assumption. Ask the owner in the
proposal session, before the design is written: one short list, each
item with ready options and a recommendation; the answers become
journal entries. In a multi-repo slice the list is asked in the
slice's FIRST proposal, before the producer's contract is fixed (field
lesson: "day, not time" and "no polling" came from parity with the old
app; the owner's first look reversed both after the device session,
and the second loop cost about 80% of the first).

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
- A session whose work is done does NOT stay open for its `/cost` or
  for an owner verdict: it closes with the ledger cell empty and names
  its id in the handoff; the owner fills the cell later via
  `claude --resume <id>` → `/cost` (field lesson: a session idled
  2 h 19 min for one pasted line, outlived the cache TTL and became
  the slice's most expensive one; another re-cached 147k tokens
  waiting for a verdict).
- The reviewer is spawned from a context that did NOT develop the
  slice — a fresh closing session qualifies; don't open an extra
  context just to spawn it.

Session ledger — `{{CYCLES_DIR}}/S-NN.sessions.md`, one per slice (in
the primary repo; satellites write through `primaryRoot`). It is the
list of every session that worked on the slice, so parallel and
unrelated sessions cannot blur the retro's metrics:

- A session appends its row when it STARTS work on the slice's tasks
  (propose, apply, review, closing, retro) — not at the end, so a
  session lost to `/clear`, a crash or a forgotten close still shows
  up. The id is `$CLAUDE_CODE_SESSION_ID` (the transcript name and the
  `claude --resume` id); a resumed session already has its row. A
  session about something else writes nothing. Append with a shell
  `>>` (parallel sessions share the file) and commit the row with the
  session's next commit. The slice's first session is the PROPOSAL
  session — it creates the file from the cycles README template and
  writes the first row (field lesson: two slices in a row the ledger
  was created by apply session 1, and the proposal — often on another
  model — stayed unmeasured until a back-dated row).
- Row: `| <full session id> | <repo> | <change · task group> | <model> |
  <started, local MM-DD HH:MM> | <cost> |`, compact, under
  `<!-- prettier-ignore -->`. Cost is empty while the session is open,
  then the measured `/cost` total, or `not measured: <reason>`. The
  cost is written by REPLACING the empty last cell, never by appending
  one; after writing, `grep -c '||' S-NN.sessions.md` prints 0 (field
  lesson: two rows in one slice gained a seventh cell, the table
  rendered shifted and the sum script read the wrong column). A model
  switch mid-session is recorded in the model cell (`A → B`).
- At session start, read the ledger with the handoff: a CLOSED session
  whose cost is still empty → ask the owner for
  `claude --resume <id>` → `/cost`, naming the id (a session still
  running in parallel is not a gap — ask if unsure). The owner pastes
  the block into the session that ASKED, together with that id — not
  into the resumed session, where the paste wakes a finished context
  to write one cell. A `/cost` block carries no session id: it goes
  into the row whose id came with it, never by order or by "the third
  session" (the ledger also counts proposal and owner-probe rows);
  two blocks or no id → ask. Check before writing: the block's model
  is the row's model, its wall duration fits the row's start (field
  lesson: a closed session was woken 75 min later by its own pasted
  `/cost`; in another, two blocks arrived in one context and the
  figure was matched to its row by the owner's ordinal).

Task list hygiene (the change's `tasks.md` or equivalent):

- Every session block ends with a close task — tick the boxes, write
  the handoff, write the session's `/cost` into its ledger row if the
  owner pastes it right away (otherwise leave the cell empty and name
  the session id in the handoff — never wait for it) — the LAST block
  included, so the slice total is a sum, not an after-the-fact
  reconstruction.
- An action only the owner can perform (a check on their own account,
  a real-credential capture) is its own task, never an item inside an
  agent's task: the agent cannot tick it, and archive does not wait.
  The same holds for actions the harness will not let the agent run:
  auto mode's classifier stops writes to shared resources (deploy env
  vars, hosted config) and ANY command through a remote shell into an
  external or production system — reads and probes included, not only
  writes. Plan those as owner tasks from the start, each with the
  exact command the agent prepares, and hand them off from the
  PREVIOUS session with the ask to run them BEFORE the next session
  opens; that session starts by reading the pasted output, not by
  waiting for it (field lesson: both were planned as agent steps,
  blocked mid-session, and cost a pause and a round of messages each;
  later a staging read every session re-discovered as blocked, and a
  session that idled 59 min inside its context for commands ready in
  the previous handoff). The handoff and the current-state doc name
  an owner task by FILE and number (`<change>/tasks.md`, task 1.1),
  never by number alone (field lesson: "where do I read these
  steps?" was the first message of a session).
- An owner task that needs something a session produces (a deploy
  that must be live, a command that session builds, a variable it
  introduces) is a session BOUNDARY: it sits after that session's
  close task — never "by the end of session N" or between its tasks —
  and the work that needs the answer opens the next block. The
  handoff says WHERE the answer goes: into the first message of the
  NEXT session, never "into the chat" — a reply typed into the closed
  session wakes its whole context, past the cache TTL at the uncached
  price. An owner action discovered mid-session goes the same way:
  write the task, hand off, close (field lesson: three sessions of
  one slice took the owner's answers 33–61 min after handing the task
  off and worked on in the old context; the plan had timed a variable
  write "by the end of session 1", and the handoff said "paste into
  the chat").
- An owner task is written in the OWNER's language and is
  self-sufficient: where to go (which admin panel, which console),
  what to click, and the exact text to paste — SQL or a command as a
  copy-ready line, not a description of intent. A task on a device
  carries its build: the ABSOLUTE file path pasted from `ls -la <file>`
  run after the build (the line proves the file exists — a name does
  not), the commit it was built from and the install command — built
  BEFORE the preparing session closes (field lesson: "run an aggregate
  query" came back as "what is that, what do I do?"; "where is the
  build?" came back three slices running — once the build was made
  after the session's `/cost`, once the named APK had never been
  built, once the path was relative inside the install command).
- Changes the gate checks as a pair (a snapshot field and its DB
  column + migration, a source and its generated artifact) are ONE
  task — a split leaves a tree that fails typecheck or verify.
- A box is ticked on what the diff holds, not on what the task text
  planned. If the work went another way, rewrite the task line first
  (what was done, why it differs), then tick — boxes closed after the
  review freeze are read by nobody.
