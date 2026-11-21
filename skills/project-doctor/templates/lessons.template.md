<!-- Scaffolded by the doctor to `{{LESSONS_PATH}}`. Always English,
like CLAUDE.md: it is instructions for the agent, not project docs.
Replace placeholders with the project's config paths. -->

# Slice lessons

Rules that act at ONE moment of a slice. CLAUDE.md points here and
keeps only what acts in every session — this file is read section by
section, when its moment comes, so its size is paid once per session
and not on every request. `/sdd-loop:slice-retro` appends a lesson to
the section of its moment (one bullet: the rule, then the field case
in a clause); `/sdd-loop:project-doctor` reconciles the sections with
the plugin's template.

## Proposal and design

Read before writing a proposal, its list of questions to the owner, or
a design.

A decision about user-visible behavior (what a screen shows,
when it refreshes, how a control looks) that no normative source
states — PRD, design canvas, journal — is not taken from parity with
an existing product or from an assumption. Ask the owner in the
proposal session, before the design is written: one short list, each
item with ready options and a recommendation; the answers become
journal entries. The list is the proposal session's FIRST message and
the session closes with it; the answers go into the next session's
first message, which writes the design (field lesson: a proposal held
its context 2 h 23 min over the owner's answers). In a multi-repo slice the list is asked in the
slice's FIRST proposal, before the producer's contract is fixed (field
lesson: "day, not time" and "no polling" came from parity with the old
app; the owner's first look reversed both after the device session,
and the second loop cost about 80% of the first). A design's claim
about how another system behaves (the producer, staging, a gateway)
cites that system's spec or a captured answer; without one it is
marked a hypothesis for the device session to measure, never stated
as fact. A fact about a third party that an owner task stands on (the
client's legal form, whose name an account is in, what the owner can
do in the client's system directly) is an item of the same list,
never an assumption.

## Task list and handoffs

Read before writing a task list (the change's `tasks.md` or
equivalent), a task for the owner, or the session's handoff.

- Size the groups in the task list: a group carrying a migration, an
  ADR and more than ~6 code tasks, or e2e geometry over several
  widths, is two sessions from the start; a proposal opens in its own
  fresh session, never inside one that began as a question or is
  closing another change.
- Every session block ends with a close task — tick the boxes, write
  the handoff, leave the session's ledger cost cell EMPTY and name the
  session id in the handoff — the LAST block included, so the slice
  total is a sum, not an after-the-fact reconstruction. The task line
  itself says "cost cell left empty, id in the handoff", never
  "Close: `/cost`": a session follows its task line over CLAUDE.md
  (field lesson: with "Close: `/cost`" in every block, seven sessions
  of eight waited 13–29 min each for the paste). The handoff's `/cost`
  line is copy-ready and names the destination: "`claude --resume
  <id>` → `/cost` → paste into the first message of the NEXT session,
  not here" — a line that stops at `/cost` gets the block pasted into
  the resumed session (field lesson: two closed sessions in one week
  were woken 5½ h later for one cell; both handoffs named the command,
  neither the destination).
- The handoff's "Next" names the COMMAND that opens the next session
  (`/opsx:apply <change>`, `/opsx:propose`, a trunk session with its
  sync script), not only the task group; a task whose record says
  "Done" is ticked in the same commit (field lesson: "is the next
  session propose or apply?" was the owner's first line).
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
  never by number alone, and say in the same line WHO executes it
  ("owner task" / "agent task, device session") (field lesson: "where
  do I read these steps?" was the first message of a session; an
  agent's task named by number was read by the owner as theirs).
- An owner task on a shared environment (staging) is planned after
  READING that environment's data and names it: which record, which
  account, which environment the owner's client reads. No data there →
  the task gets a preparation step or is not planned (field lesson: a
  task needed records staging did not have; the owner's app read a
  different environment than the change lived on). Logging in to it
  is a permission like a write. A record id in the owner's command is
  read from the environment when the task is written, never from a
  previous slice's record, and the command starts with a read-only
  step printing that id for the owner to compare (field lesson: an
  id from the month before failed, and the owner wrote into a closed
  session).
- The handoff's ready first line for the next session has a slot for
  every way the owner comes back — the answer, an obstacle ("cannot
  finish: <what the system said>"), a question ("question — <what is
  unclear>"), and `; /cost <id>: <paste the block>` — each answer slot
  maps to a numbered step and asks for the fact the agent decides by,
  never a command's output. The first fill of a third-party form the
  agent has never seen (a store listing, a privacy questionnaire) is a
  companion session the owner opens with a ready line when they sit
  down at it. A step on a third-party console names the menu path and
  fields from the vendor's CURRENT documentation, cited; a CLI command
  is the one the agent itself ran here, verbatim (field lesson: five
  retros running, owners' refusals, questions and form doubts went into
  closed sessions; a deprecated CLI command and console scopes from
  memory cost two commits and the owner's 20 min).
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

## Review and closing

Read before freezing the review range, and before fixing a finding.

The review range is frozen as `<first slice commit>^..<end SHA>`:

- The slice's first commit is task 1.1's commit whatever its prefix
  (`docs`/`test`/`chore` included, not the first `feat`), recorded in
  session 1's handoff — not the reviewing session's start. The `^` is
  there because `git diff a..b` excludes `a`.
- The end is an explicit SHA, never `..HEAD` — the trunk HEAD before
  the reviewing session opened; that session's ledger/handoff commit is
  docs-only and lands after the end SHA, outside the range. No code
  commits until the verdict lands.
- After a BLOCK the fix commits get their own follow-up pass from the
  previous end SHA, chained until PASS.
- A fix is proven red-before on the exact line the finding named and
  sized from the inventory the finding is one item of, not from its
  words (a fix that changes which rows a count sees takes in every
  condition counting them by another path — a publish gate, a blocker
  counter) — each pass that finds a flaw in the previous fix is paid
  twice.
- A reviewer's suggested fix is a hypothesis — validate it with the
  slice's tests before adopting.
- A doubt an implementing session saw and left (a race window, "is
  this a defect?") is a task or an owner question before the freeze; a
  note addressed to the review goes into the reviewer's prompt
  verbatim. The reviewer's COVERAGE block goes into the retro: a file
  it did not open is not reviewed, and a range with two applications
  or past ~60 files is two passes.
