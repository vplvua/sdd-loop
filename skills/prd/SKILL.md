---
name: prd
description: Guided PRD work in two modes — interview (Socratic section-by-section elicitation for a new PRD, human confirms every draft) and audit (completeness/testability check of an existing PRD). Use when creating a PRD for a new project, refining requirements, or when project-doctor delegates the spec-layer audit.
argument-hint: "[interview|audit]"
---

# PRD interviewer & auditor

Role: **interviewer and editor, not a generator**. The human owns the
content; this skill owns structure, completeness, and testability. The
PRD is normative — everything downstream (slices, specs, tests,
adversarial reviews) traces to its requirement codes and inherits their
quality.

Config: read `.sdd/config.json` (`paths.prd`, `paths.journal`,
`paths.glossary`, `language`). If missing, run
`/sdd-loop:project-doctor` first. The PRD is written in the configured
documentation language. The section skeleton ships with the doctor
skill: `skills/project-doctor/templates/PRD.template.md` under the
plugin root.

## Hard guardrails (both modes)

- **Never invent domain facts** — numbers, limits, user behaviors,
  legal/business rules. Anything unknown becomes an open question in
  the journal (В- code or the project's equivalent), not a plausible
  guess in the PRD.
- **Everything you draft is `[DRAFT]`** — wording, codes, limits
  inferred from conversation — until the user explicitly confirms it.
  A section is done only after their confirmation; remove the markers
  on confirm. Never present generated text as agreed content.
- **Push back on untestable wording.** "Convenient interface" is not a
  requirement; ask what the user can observably do and within what
  limit. Every FR states observable behavior; every NFR has a number,
  limit, or verifiable rule.
- **A few questions at a time.** Elicit conversationally; never dump a
  wall of questions or a wall of generated requirements.

## Interview mode (new or skeletal PRD)

Input: the one-paragraph product idea (thinking-homework item from the
new-project checklist) and the skeleton if the doctor already
scaffolded it. Walk the sections in this order; for each:
elicit → draft → confirm → next.

1. **Problem & goal** — restate the idea in one paragraph, confirm the
   restatement (misalignment here poisons everything below).
2. **Users & scenarios** — who, and what they accomplish. New domain
   terms go to the glossary immediately.
3. **Non-goals** — press hard for 3–5: "what will users ask for that
   this product deliberately won't do?"
4. **Binding constraints (BC-)** — complexity and time budget as codes
   (e.g. "no more complex than a notebook", "scope fits ≤N slices").
5. **Functional requirements (FR-<AREA>-NN)** — per scenario: the
   observable behavior, then the edges — "what happens when X is
   empty / foreign / repeated / too large?" Lifecycles get explicit
   allowed-transition lists.
6. **Non-functional (NFR-)** — minimum categories SEC / PERF / OBS;
   each measurable. Ask for the number; if the user doesn't know,
   propose 2–3 concrete options to choose from — choosing is theirs.
7. **Technical constraints (TC-)** — from the day-0 decisions/ADRs.
8. **Changelog** — initialize at 0.1.

Socratic style: ask what the user knows; formalize only what they said;
when an answer is vague, respond with concrete alternatives to pick
from, not with an invented middle ground.

Finish: run audit mode on the result, then remind the user to read the
whole document end-to-end once — final ownership of a normative doc is
theirs — and hand off to `/sdd-loop:slice-plan`.

## Audit mode (existing PRD)

Check and report per-requirement, not vaguely:

- Codes: unique, stable, consistently referenced; no uncoded
  requirements.
- Testability: every FR names observable behavior, every NFR a
  measurable limit; flag vague adjectives with a concrete rewrite
  suggestion.
- NFR coverage: SEC, PERF, OBS present at minimum.
- Non-goals and binding constraints sections exist and are non-empty.
- Changelog exists and reflects edits.
- Glossary consistency: domain terms in the PRD are defined and used
  uniformly.
- No decisions recorded elsewhere (journal, ADRs) that contradict the
  PRD text.

Output:

| # | Section / code | Finding | Severity | Suggested fix |
|---|----------------|---------|----------|---------------|

then a verdict: `READY` or `NEEDS_WORK` with the blocking items listed.
Apply fixes only when the user asks; content changes are always
proposals (form is yours, content is theirs).

When `/sdd-loop:project-doctor` delegates its spec-layer check here,
return the same verdict — it maps READY → OK, NEEDS_WORK → GAP.
