# New-project checklist

What to prepare BEFORE running `/sdd-loop:project-doctor` on a fresh
project, and what the launch sequence looks like. The doctor audits and
scaffolds the *process* layer — it does not invent your product or
scaffold your application.

## A. Thinking homework (before opening a terminal)

The doctor's interview will ask for these; answers straight from your
head produce a weak PRD. Write them down first:

- [ ] **Product idea in one paragraph** — the problem, for whom, what
      the MVP does. Seeds the PRD draft.
- [ ] **Explicit non-goals** — 3–5 things the MVP will NOT do. Scope is
      cut by this list, not stretched.
- [ ] **Binding constraints** — budget of complexity and time, stated
      as requirement codes (e.g. "no more complex than a notebook",
      "scope must fit ≤N slices"). The most underrated item: these are
      what actually cut scope when a slice balloons.
- [ ] **Day-0 engineering decisions already made** — stack, hosting/
      deploy, auth approach, database. Each becomes a first ADR.
      Anything genuinely undecided goes to the open-questions journal
      instead — don't fake certainty.
- [ ] **Documentation language** (code, commits, CLAUDE.md are always
      English; this is only for `docs/`).

## B. Technical foundation (the doctor won't do this)

- [ ] Repo initialized; trunk branch chosen (trunk-based delivery is
      the assumed default: slices land as `feat(S-NN):` commits, no
      working branches).
- [ ] Application scaffold generated with your stack's CLI
      (`create-nx-workspace`, `npm create vite`, `nest new`, …) —
      `package.json` must exist.
- [ ] Prettier + ESLint configured (the plugin's format-on-edit hook
      picks them up; without them it silently skips).
- [ ] TypeScript + unit test runner wired; e2e framework if known
      (needed by the slice DoD, can be added by slice 1).

## C. Claude Code environment

- [ ] Plugin installed and enabled at **project scope** (teammates and
      the `slice-reviewer` agent need it):
      `/plugin marketplace add vplvua/sdd-loop` →
      `/plugin install sdd-loop@sdd-loop`.
- [ ] MCP servers for the stack connected (framework docs, browser
      automation for e2e debugging).
- [ ] OpenSpec (or equivalent spec working layer): `npx openspec init` —
      the doctor checks for it but does not install it.

## D. Launch sequence

1. `/sdd-loop:project-doctor` — interview → `.sdd/config.json` →
   scaffold layer by layer, one commit per layer.
2. **Review the PRD draft yourself.** The doctor generates a skeleton
   with drafts from your one-paragraph idea; the PRD is normative — the
   human owns its content. Fix requirement codes, limits, non-goals
   before anything traces to them.
3. `/sdd-loop:slice-plan` (generate mode) — vertical slices + shared
   DoD from the reviewed PRD.
4. Re-run `/sdd-loop:project-doctor` — the readiness matrix must be all
   green / N/A before slice 1 starts.
5. First slice: propose → implement → full DoD including
   `sdd-loop:slice-reviewer` and `/sdd-loop:slice-retro`.

Rule of thumb: A is human work, B is one hour of CLI scaffolding, C is
five minutes, D is where the loop takes over.
