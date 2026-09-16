# Slice retrospectives

Two files per slice:

- `S-NN.sessions.md` — the session ledger: created by the slice's
  first session, one row appended by every session that works on the
  slice, cost filled by each session's close task. Template:

```markdown
# S-NN — sessions

<!-- prettier-ignore -->
| Session id | Repo | Change · tasks | Model | Started | /cost |
| --- | --- | --- | --- | --- | --- |
| <full id> | <repo> | <change> · <task group> | <model> | MM-DD HH:MM | $0.00 or not measured: <reason> |
```

- `S-NN.md` — the retro, written by `/sdd-loop:slice-retro` at the end
  of the slice. Template:

```markdown
# S-NN — <name>: retro

## Metrics

- Time: <calendar> / <net human, estimate>
- Tokens/cost: <exact /cost figure if given; otherwise estimate, marked>
- Iterations: <verify-gate blocks, re-work loops>
- Defects leaked from earlier slices: <n>
- Spec adherence: <deviations, unescalated decisions>

## Review dispositions

<!-- slice-reviewer findings: accepted/rejected, with evidence. -->

## Friction

<!-- Top issues from the 4 signal sources. -->

## Applied now (≤3)

1. …

## Proposed (needs user decision)

- …
```
