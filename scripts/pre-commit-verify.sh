#!/usr/bin/env bash
# PreToolUse hook (Bash): quality gate — when the command contains
# `git commit`, run the project's blocking `verify` npm script first.
# On failure the commit is blocked (exit 2) and the tail of the output
# is fed back to the agent.
#
# Contract: the project defines a `verify` script in package.json
# (scaffolded by /sdd-loop:project-doctor). Projects without one are
# NOT gated — a warning is emitted instead of a hard block, so the
# plugin is safe to enable globally.
set -u

cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)

# Anchored match: fire only when `git commit` sits in command position
# (line start or after ; & | (), allowing `git -C dir` / `git -c k=v`.
# A heredoc or echo merely MENTIONING the phrase must not trigger the
# gate (first-field-run lesson: it blocked an unrelated write). A line
# inside a heredoc that literally starts with `git commit` still
# matches — acceptable: the failure mode is a needless verify run.
if ! printf '%s\n' "$cmd" |
  grep -qE '(^|[;&|(])[[:space:]]*git[[:space:]]+(-[^[:space:]]+[[:space:]]+([^[:space:]]+[[:space:]]+)?)*commit([[:space:]]|$)'; then
  exit 0
fi

proj="${CLAUDE_PROJECT_DIR:-$PWD}"

if [ ! -f "$proj/package.json" ]; then
  exit 0
fi

if ! node -e "const p=require('$proj/package.json');process.exit(p.scripts&&p.scripts.verify?0:1)" 2>/dev/null; then
  echo "sdd-loop verify gate: no 'verify' script in package.json — commit is NOT gated. Run /sdd-loop:project-doctor to set it up." >&2
  exit 0
fi

echo "sdd-loop verify gate: git commit detected — running 'npm run verify'" >&2
if ! out=$(cd "$proj" && npm run verify 2>&1); then
  printf '%s\n' "$out" | tail -60 >&2
  echo "" >&2
  echo "BLOCKED: 'npm run verify' failed — fix the issues above, then retry the commit. Never chain fixes with the commit in one command: the gate verifies the tree BEFORE the whole command runs." >&2
  exit 2
fi

exit 0
