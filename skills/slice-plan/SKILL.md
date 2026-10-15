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
filled by the owner's `claude --resume <id>` → `/cost` after the
session closed — a finished session never stays open waiting for it;
see the CLAUDE.md session-ledger rules). The close task in `tasks.md`
SAYS so in its own words — "ledger cost cell left empty, session id
in the handoff" — never "Close: `/cost`, tick …", and the handoff's
`/cost` line is copy-ready and says WHERE the block goes: "`claude
--resume <id>` → `/cost` → paste into the first message of the NEXT
session, not here" — a line that stops at `/cost` is pasted into the
resumed session (field lesson: two slices in one week each woke a
closed session 5½ h later for one ledger cell; both handoffs named the
command and not the destination): a session executes
its task line over the CLAUDE.md rule (field lesson: with "Close:
`/cost`" in every block, seven sessions of eight held their context
13–29 min for the owner's paste, ≈ 2 h 20 min in all, despite the
rule); the retro
needs every row's cost measured or marked `not measured: <reason>`.
Owner tasks in the change's task list are written in the owner's
language and are self-sufficient — where, what to click, the exact
line to paste; the handoff names such a task by file and number
(`<change>/tasks.md`, task 1.1) together with WHO executes it — "owner
task" or "agent task, device session" in the same line as the number
(field lesson: an agent's task named by number alone came back "explain
what to do in 4.7") — and asks for it BEFORE the next
session opens, so that session reads the answer instead of waiting
(remote-shell reads into staging/production are owner tasks too —
the classifier blocks them like writes); an owner task that needs a
session's own product (a live deploy, a command it builds) sits at the
boundary AFTER that session, never inside it, and the handoff sends the
answer to the next session's first message, not to the closed one —
a reply there re-reads its whole context; an owner task on a shared
environment (staging) is planned AFTER reading that environment's data
and names it — which record, which account, which environment the
client the owner uses actually reads — and a task the environment has
no data for gets a preparation step or is not planned (field lesson: a
task needed two ballots awaiting a first signature and staging had
none; "which ballot, of which building?" came back on another; the
owner could not vote because the app read a different environment than
the change lived on); a device check names the build file by its ABSOLUTE
path pasted from `ls -la <file>` run after the build (proof it exists,
not a name), its commit and the install command.

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
   validated; all task checkboxes `[x]`. A test that asserts a KNOWN
   GAP (an open В-NN) against a MUST of the spec lands in the same
   commit as the exception in that spec sentence ("…except <gap>,
   В-NN") — otherwise the spec and the test say opposite things and
   only the reviewer notices (field lesson: "the expiry leaves it in
   the cache" was the test's expectation and the delta's sentence
   stayed unconditional; a medium finding and a delta pass). A decision about user-visible
   behavior (what a screen shows, when it refreshes, how a control
   looks) that no normative source states — PRD, design canvas,
   journal — is not taken by the proposal from parity with an existing
   product or from an assumption: it is ASKED to the owner in the
   proposal session, before the design is written — one short list,
   each item with ready options and the proposal's recommendation; the
   answers become journal entries. In a multi-repo slice the list is
   asked in the slice's FIRST proposal, before the producer's contract
   is fixed (field lesson: a chat slice took "day, not time" and "no
   polling" from parity with the old app; the owner's first look
   reversed both after the device session, and the second loop — a new
   producer change and nine contexts — cost about 80% of the first).
   A design's claim about how ANOTHER system behaves (the producer,
   staging, a gateway) cites that system's spec or a captured answer
   when the proposal is written; without one it is marked a
   HYPOTHESIS for the device session to measure, never stated as fact
   — in the design or in a journal entry (field lesson: a design and
   its journal entry said "account deletion resets the consent"; the
   platform's spec never listed it, the device session measured the
   opposite, and it took a review finding to correct the journal).
2. The project's `verify` script passes (blocking gate). A check
   OUTSIDE verify that enumerates the project's operations (an authz
   walk over every endpoint, a presence list, a permissions matrix)
   gets each operation the task adds in the SAME commit, and the task
   runs it there — as with a regenerated snapshot, but no gate will
   reject the lag (field lesson: five new operations updated the
   OpenAPI snapshot task by task; the auth walk's list ended at the
   previous slice and was found red only at the DoD sweep, seven
   sessions later).
3. Smoke test against a real backing store: create / update / delete
   the slice's data and check invariants. For external gateway
   integrations, response fixtures are written from a CAPTURED REAL
   call, not from documentation — until the first real call succeeds,
   the integration counts as unverified regardless of test coverage.
   The local stub of that gateway checks each route's REQUEST
   (`Accept`, `Content-Type`, auth header) as the real one does, from
   the captured call — not only its response shape: a stub that
   answers whatever it is sent hides the `406`/`415` the real system
   returns (field lesson: one shared `Accept: application/json` was
   green on every stubbed route and `406` on the real file download;
   staging found it, at the cost of a fix block and a second deploy).
   The same holds for the external system's SHAPE (column widths,
   types, enums, nullability) in an inventory, a test bound or a
   question to the owner: it is read from a probe of the real system
   (or the ADR that recorded one), never from the local stand-in (a
   compose seed DDL, a mock) — a stand-in drifts, and the question
   names which source it read (field lesson: a width inventory read
   the compose DDL, 255 where the real legacy has 50; the owner was
   asked under the false premise, the reviewer read the same file,
   and a `high` finding turned out to be a defect of the dev stand
   only).
   A lookup that grants access by an identifier the client types
   (email, phone, login) is tested on the real store with values its
   comparison FOLDS into a stored one — accents, `ı`, `ß`, trailing
   spaces under a `_ci` collation, not only case: the store's `=`
   narrows candidates, the code compares the stored value with the
   typed one exactly after normalization (field lesson: the collation
   was in the inventory from session 1, seven sessions tested case and
   spaces, and `exámple.org` opened the session of `example.org` until
   the reviewer tried it).
4. E2e scenarios for the slice's critical paths pass, derived from the
   acceptance scenarios. A recovery rule (restart, orphan, expiry) is
   proven from the entry point the user has AFTER the failure — the
   same start call, a reloaded page — over a seeded orphan, not only
   through a path that holds the lost id; two scenarios each green
   alone ("interrupted", "a second one is refused") get a test of
   their intersection (field lesson: an interrupted job held its
   meeting's slot forever — recovery ran only on a read by an id that
   lived in the lost tab; only the reviewer found it, at the cost of a
   delta pass). The same for exits: session-lived state gets a row
   for every way the session ends (sign-out, deletion, expiry) and for every COPY of it —
   the stored key AND what the start moved into memory (a slot, a cover
   flag, a query cache): a table that erases only the key leaves the copy
   alive (field lesson: the reviewer found a kept slot and a cover that
   outlived an expiry between the hold and the tabs), and a
   screen a deep link or a push opens is proven by leaving it too —
   back, a context switch — reading the stack under it; an acceptance
   scenario that ends at "the screen opens" stops the proof one
   gesture short (field lesson: tests, the device run and the owner's
   look all stopped at "tap → detail"; the owner's next "back" found
   the detail with nothing under it). A guarded state transition
   lists every fact it ASSERTS (not only the status it checks) and
   every writer of each fact; all writers meet on one lock, and the
   race barrier runs each pair of them (field lesson: "signed over the
   current answers" checked status and slot; the current document was
   replaced by another writer outside the lock, and a resubmission
   kept the old signature). A fact read from ANOTHER row counts too (a
   field of the parent record the check compares against): its writer
   takes that row's lock, the guard reads it under a shared lock (`FOR
   SHARE`) inside the transaction — never a value read before it — and
   the barrier runs that pair (field lesson: the next slice listed every
   writer on the ballot row and missed the authorized person's name on
   the meeting row; the countersign compared against a name read before
   the lock — the slice's medium finding). Budget rate-limited external test resources
   (OTP quotas, test accounts, sandbox credits) for retries and
   per-platform runs, not for one ideal pass — and keep a spare: the
   first unit goes to ONE cell on the riskiest configuration (the
   largest font, the platform the flow is likeliest to break on), the
   rest of the matrix after it — a defect of the flow itself then
   costs one unit, not four (field lesson: a six-cell flow spent nine
   of ten daily codes, three of them on the flow's own layout bugs,
   and the remaining cells waited a day).
5. Launch-and-look check: run the app, walk the slice's happy path
   against the real integrations, confirm it works; note the check in
   the current-state doc. A flow that hands the user to another app
   (a system browser tab, a signing or payment app) is also walked
   with the app's PROCESS killed under it (`adb shell am kill <pkg>`
   while the other app is open) — an emulator with spare memory never
   kills it, an owner's phone does. A property over time ("no frame of
   the tabs before the check") is read from a screen RECORDING of the
   whole interval, frame by frame, in the first probe — a screenshot
   at the end misses 2–3 frames (field lesson: the owner's phone lost
   the screens after the signing tab, which no device session had
   produced; then two flashes of ~45 ms each cost their own code →
   device iteration, 4 contexts of 9). A command that does not exit
   when its work is done (`expo run:ios`/`run:android` install the
   build and then stream logs; a dev server) is never waited on by the
   background task's exit notice — it never comes: wait with `Monitor`
   until the success line appears in its log (or the installed
   bundle's mtime changes), then stop the command; a turn never ends
   on "waiting for the build" (field lesson: the build was installed at
   10:47 and the context stood idle until the owner asked "still
   running?" at 11:20). An owner look that covers several checks
   gets a report line with one slot PER check (`icon: <PASS | remark>`,
   `toggles: …`), never one bare `<PASS | remark>` — a single slot
   comes back "PASS" about what the owner happened to look at (field
   lesson: a four-point look returned PASS naming two; the icon and
   the five toggles went unreported). Triage every owner remark from the check:
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
   The record of the review (ledger, retro, handoff) names the
   reviewer's model as the subagent transcript's `message.model` shows
   it — never the pinned model of the agent definition or an
   assumption: the pin can fall back, and maker ≠ checker is the fact
   the record exists to prove (field lesson: a retro named "Opus 5.5";
   the transcript said `claude-sonnet-5-5`).
   The start is the slice's FIRST commit — the first commit of the
   change's tasks (task 1.1), whatever its prefix: a `docs` PRD edit or
   a `test`/`chore` capture of real responses counts, the first `feat`
   is NOT the anchor — recorded in session 1's handoff; never the start
   of the session running the review, and
   the `^` is mandatory: `git diff a..b` excludes `a`. The end is the
   trunk HEAD as the reviewing session found it; that session's own
   ledger row / handoff commit is docs-only, lands AFTER the end SHA
   and stays outside the range (its SHA exists before the freeze line
   is written) — no code commits until the verdict lands (field lesson:
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
   A fix for a finding is proven like the original work: red on the
   before state on the EXACT line the finding named (same file, same
   field — not an invented line the check already caught), and its
   scope is drawn from the inventory the finding is one item of (every
   money field of the contract, every transition of the state table),
   collected in one command and closed in one commit — not from the
   finding's words, one word per pass. A fix to a test is checked
   against two mutants: the one the finding described and one that
   survives a narrower fix. Every mutant runs under a time bound
   (`timeout N …`; macOS has none — `perl -e 'alarm N; exec @ARGV' …`):
   a mutant that drops a lock or a re-check can HANG instead of
   failing, and a hang past the bound counts as red (field lesson: a
   race-test mutant left jest waiting on a lock for 31 min until the
   owner asked whether anything was still running). (Field lesson on
   the fixes: one slice spent three extra
   reviewer passes, another two — each pass a flaw in the previous
   fix: a plausible mutant nobody ran, a planted violation on the wrong
   field, a guard list grown one word per finding).
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
