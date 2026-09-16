---
name: slice-retro
description: Post-slice session retrospective — collect metrics and process friction, write the cycles doc for the slice, apply small process improvements. Run as the final DoD step at the end of a slice session (after archive), or when the user asks for a session/slice retro.
---

# Slice Retrospective

Analyze the just-finished slice session and turn friction into process
improvements. Run at the END of the slice session, while the dialogue is
still in context. The retro artifact is `<cyclesDir>/S-NN.md` (path,
template pointer, and documentation language come from
`.sdd/config.json`; default `docs/cycles/`). With `role: satellite` the
cycles dir lives in the primary repo via `primaryRoot` — one retro per
slice covers all involved repos; if the path is unreachable, ask the
user to grant access (`--add-dir` or
`permissions.additionalDirectories`) first.

**Retro in a fresh session** (the slice session closed, or the retro
spans several sessions): the dialogue is no longer in context — read
it from the transcripts instead of reconstructing it from memory or
commits. Transcripts live in `~/.claude/projects/<slug>/*.jsonl`, where the
slug is the repo's absolute path with every `/` replaced by `-` (the reviewer subagent's in
`<session-id>/subagents/`); pick the sessions whose timestamps fall
between the first and last commit of the slice range, per involved
repo. Count from them: user messages that correct or re-explain,
rejected `AskUserQuestion` / permission prompts, and verify-gate blocks
(`BLOCKED: 'npm run verify' failed` in tool results — the gate leaves
no trace in git, so the transcript is the only record). Past sessions'
exact cost stays `claude --resume <id>` → `/cost`.

This step is what makes the process self-improving: fixes applied here
land in CLAUDE.md, skills, and configs — the next slice starts cheaper.

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
   sessions are not in this context, locate their transcripts first
   (see "Retro in a fresh session").
2. Walk the four signal sources; collect metrics.
3. Write `<cyclesDir>/S-NN.md` per the template in
   `<cyclesDir>/README.md`, in the documentation language from the
   config.
4. Apply the "apply now" fixes (≤3), stage them together with the
   artifact.
5. Update the current-state doc if the retro changed next steps.
6. Summarize to the user: metrics, top friction, what was changed, what
   awaits their decision.
