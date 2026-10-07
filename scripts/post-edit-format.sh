#!/usr/bin/env bash
# PostToolUse hook (Write|Edit): format the edited file with prettier,
# then lint-fix it with eslint. Unfixable eslint errors are fed back to
# the agent via exit code 2 so they get fixed immediately.
#
# Tools are resolved from the edited FILE's own project — the nearest
# ancestor directory holding `node_modules/.bin/<tool>` — never from the
# session's cwd. A satellite session editing the primary repo's docs
# otherwise runs the satellite's prettier version on them (field lesson:
# a different version rewrote `✓ (~)` to `✓ (~~)` in the primary's
# inventory tables and re-aligned tables the session never touched).
#
# Graceful degradation: a file whose tree has no prettier/eslint is
# silently skipped.
set -u

f=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty' 2>/dev/null)
[ -n "$f" ] && [ -f "$f" ] || exit 0

# Print the nearest ancestor of $1 that holds node_modules/.bin/$2.
find_root() {
  local d
  d=$(cd "$(dirname "$1")" 2>/dev/null && pwd -P) || return 1
  while [ -n "$d" ] && [ "$d" != "/" ]; do
    [ -x "$d/node_modules/.bin/$2" ] && { printf '%s\n' "$d"; return 0; }
    d=$(dirname "$d")
  done
  return 1
}

if root=$(find_root "$f" prettier); then
  (cd "$root" && ./node_modules/.bin/prettier --write --ignore-unknown \
    --log-level warn "$f" >/dev/null 2>&1)
  # prettier is not idempotent on some input — in markdown, an inline
  # code span wrapped across lines is dedented 2 columns per pass, so
  # the file one --write produced still fails the gate's --check (field
  # lesson: four of one slice's six gate blocks, each found only at
  # commit). Say so now, while the edit is fresh.
  if ! (cd "$root" && ./node_modules/.bin/prettier --check --ignore-unknown \
    --log-level silent "$f" >/dev/null 2>&1); then
    printf '%s\n' "sdd-loop: prettier is not stable on $f — a second pass would change it again, and the commit gate will block." \
      "In markdown this is almost always an inline code span (\`...\`) wrapped across a line break: put the span on one line (a long path or command goes on its own line or in a fenced block), then re-run \`prettier --check\` on the file." >&2
    exit 2
  fi
fi

case "$f" in
  *.ts | *.mts | *.cts | *.js | *.mjs | *.cjs)
    root=$(find_root "$f" eslint) || exit 0
    if ! out=$(cd "$root" && ./node_modules/.bin/eslint --fix --no-warn-ignored "$f" 2>&1); then
      printf '%s\n' "$out" >&2
      exit 2
    fi
    ;;
esac

exit 0
