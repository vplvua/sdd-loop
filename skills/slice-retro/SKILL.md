---
name: slice-retro
description: Post-slice session retrospective — collect metrics and process friction, write the cycles doc for the slice, apply small process improvements. Run as the final DoD step at the end of a slice session (after archive), or when the user asks for a session/slice retro.
---

# Slice Retrospective

Analyze the just-finished slice session and turn friction into process
improvements. Preferably run at the END of the slice session, while the
dialogue is still in context; when it runs later in a fresh session (or
the slice spanned several), first reconstruct the dialogue from the
transcripts — see "Dialogue from transcripts". The retro artifact is
`<cyclesDir>/S-NN.md` (path, template pointer, and documentation
language come from
`.sdd/config.json`; default `docs/cycles/`). With `role: satellite` the
cycles dir lives in the primary repo via `primaryRoot` — one retro per
slice covers all involved repos; if the path is unreachable, ask the
user to grant access (`--add-dir` or
`permissions.additionalDirectories`) first.

This step is what makes the process self-improving: fixes applied here
land in CLAUDE.md, skills, and configs — the next slice starts cheaper.

## Dialogue from transcripts (only when it is not in context)

Skip this section when the retro runs inside the slice session.

- **Where**: `~/.claude/projects/<slug>/*.jsonl`, slug = the repo's
  absolute path with every `/` replaced by `-`; one file per session,
  file name = session id (what `claude --resume <id>` takes). Subagent
  transcripts (the reviewer) sit in `<id>/subagents/` and carry
  `isSidechain: true` — skip those lines when reading the owner dialogue.
  Multi-repo slices: repeat per involved repo.
- **Which sessions**: those whose first-to-last timestamps overlap the
  slice's commits (`git log --format='%h %ad' --date=iso <first>^..<end>`),
  plus the propose session just before the first commit — it often has
  no commit of its own. The first user turn names the command
  (`<command-name>/opsx:apply` + `<command-args>`), which confirms the
  change. Each such file is one paid context — that count, not the
  planned sessions, goes into the cost metric.
- **What to extract** — `transcript-signals.py <file> "<verifyCommand>"`
  next to this skill (stdlib Python) prints all of it:
  - owner turns: `type: "user"` text, excluding `isMeta` entries (skill
    bodies, subagent hand-backs) and `<local-command-caveat>`;
  - rejected tool calls: a `tool_result` containing "The user doesn't
    want to proceed with this tool use", paired with the `tool_use` it
    rejected (for `AskUserQuestion` — the questions asked) and the next
    owner turn: the escalation-quality signal;
  - verify-gate blocks: a `tool_result` with `PreToolUse` + `BLOCKED` +
    the verify command, and the failing check — git cannot show them;
  - model switches: `/model` commands and changes of `message.model`
    (a proposal on one model and an apply on another is a cost and a
    maker ≠ checker fact);
  - pasted `/cost` / `/usage` (a user turn starting `Session\n\nTotal
    cost:`): the measured figure and the share past 150k;
  - idle gaps: > 30 min between the agent's turn and the next user
    entry — they explain wall-vs-API time and the cache misses `/cost`
    reports.
- **Cost**: a session with no pasted `/cost` is priced from the
  transcript only as a floor, and not at all for models without known
  rates — ask the user for `claude --resume <id>` → `/cost`, naming the
  exact session id.
- **Privacy**: the retro artifact quotes owner turns sparingly (the
  words that carry the lesson) and never pastes raw transcript content.

## Signal sources (walk all four)

1. **Dialogue**: where did the user have to correct or re-explain
   something; how many times was a decision escalated to the user; which
   decisions the agent made on its own that should have been escalated;
   misunderstandings and re-work loops.
2. **Git history of the slice**: `git log` for the slice's commits —
   commit count, reverts/fixups, how many times the pre-commit verify
   gate blocked a commit and why.
3. **Tooling**: static-analysis false positives (needed config edits?),
   hook failures or annoyances, spec-validation errors, flaky tests,
   build-cache issues.
4. **Documentation and settings vs reality**: which statements in the
   PRD / capability plan / CLAUDE.md / skills / SDD rules turned out
   inaccurate, outdated, or missing; where the configured process
   diverged from what was actually practiced. If the installed plugin
   is newer than `templatesVersion` in the config, add "run
   `/sdd-loop:project-doctor` to reconcile template drift" to the
   proposals — the doctor does the rule-by-rule merge, not the retro.

## Metrics

Record in the artifact, marking estimates as estimates:

- **Time**: calendar session time; approximate net human time (reviews,
  answers, corrections).
- **Tokens/cost**: rough estimate from session length and tool usage;
  ask the user for the exact `/cost` figure and record theirs if given —
  never present an estimate as measured. For multi-session slices, sum
  per-session `/cost` figures — preferably the ones each session's
  closing task recorded; past sessions are readable via
  `claude --resume` → `/cost` — and count paid contexts, not planned
  sessions (a session split by an owner pause is two contexts);
  transcript-derived estimates are a
  LOWER BOUND — subagent usage is billed separately (field data: ~11%
  undercount) — and must be marked as such. Also record the cost-vs-
  context distribution when available (share of spend past 150k) — it
  drives the session-hygiene guidance.
- **Iterations**: verify-gate blocks, re-work loops until DoD.
- **Defects**: bugs found in THIS slice that belong to previous slices.
- **Spec adherence**: deviations from FR/NFR/ADR; decisions the agent
  took without escalation.

## Improvements

Split findings into two buckets:

- **Apply now (max 3 per retro)** — small, reversible process fixes:
  skill wording, CLAUDE.md clarifications, hook tweaks, linter/SDD
  config rules. Apply, list them in the artifact, and commit with the
  retro (`chore(S-NN): retro ...`).
- **Propose only** — anything normative or structural: PRD, ADRs,
  glossary, journal entries, DoD changes, new tools. NEVER edit these
  from the retro; record the proposal in the artifact and, where the
  project convention requires, draft the journal/ADR entry for the user
  to confirm.

## Procedure

1. Identify the slice ID (S-NN) and its commit range; if the slice's
   dialogue is not in this context, reconstruct it first (see
   "Dialogue from transcripts").
2. Walk the four signal sources; collect metrics.
3. Write `<cyclesDir>/S-NN.md` per the template in
   `<cyclesDir>/README.md`, in the documentation language from the
   config.
4. Apply the "apply now" fixes (≤3), stage them together with the
   artifact.
5. Update the current-state doc if the retro changed next steps.
6. Summarize to the user: metrics, top friction, what was changed, what
   awaits their decision.
