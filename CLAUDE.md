# CLAUDE.md

sdd-loop — a Claude Code plugin (skills, agent, hooks) encoding a
spec-driven development workflow with a self-improvement loop. This
repo is both the plugin and its own marketplace
(`/plugin marketplace add vplvua/sdd-loop`).

## Maintenance workflow (the loop applied to itself)

- The plugin improves from FIELD RUNS: its skills run in real projects
  and the retros come back here. First consumers:
  `~/Projects/MoeOSBB/moeosbb-mobile-app` (primary) and
  `moeosbb-platform` (satellite); retros land in the primary's
  `docs/cycles/S-NN.md`. When the user shares a retro or transcript,
  mine it for normative lessons.
- Per retro / field run apply AT MOST 3 small fixes to skills,
  templates, or the agent — the same ≤3 rule `slice-retro` prescribes.
  Anything bigger: propose first, change after agreement.
- Where a lesson lands decides who gets it: skills and the agent reach
  every installed project on the next session; the CLAUDE.md sections
  template and the DoD copied into a project's plan reach it only when the doctor
  reconciles template drift (`templatesVersion`). A lesson that must
  act in live projects now goes into a skill/agent, not only the
  template.
- Every substantive change bumps `version` in
  `.claude-plugin/plugin.json` in the SAME commit — installed copies
  auto-update on session start, an unbumped change reaches nobody.
- `claude plugin validate .` must pass before every commit.
- Commit messages carry the full rationale of each release (they are
  the project's changelog and field-lesson history — keep that
  discipline).
- Plugin content (skills, templates, docs) is English; conversation
  with the user is Ukrainian.

## Layout

- `skills/{project-doctor,prd,slice-plan,slice-retro}/SKILL.md` — the
  four skills; the doctor's `templates/` are the artifacts it scaffolds
  into target projects (translated to the project's docs language).
- `agents/slice-reviewer.md` — adversarial slice reviewer
  (maker ≠ checker: clean context, pinned different model).
- `hooks/hooks.json` + `scripts/` — format-on-edit and
  verify-on-commit (anchored `git commit` match, graceful degradation).
- `.claude-plugin/plugin.json`, `marketplace.json` — manifest +
  marketplace; `docs/DESIGN.md` — architecture and design decisions;
  `docs/new-project-checklist.md` — what a human prepares before the
  doctor runs.

## Testing changes

Live-load the working copy with `claude --plugin-dir .` (skill edits
apply immediately; hooks/agents need `/reload-plugins`). The published
version installs from the marketplace — don't test against the cache.
