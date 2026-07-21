#!/usr/bin/env bash
# PostToolUse hook (Write|Edit): format the edited file with prettier,
# then lint-fix it with eslint. Unfixable eslint errors are fed back to
# the agent via exit code 2 so they get fixed immediately.
#
# Graceful degradation: tools are resolved with `npx --no-install`;
# projects without prettier/eslint are silently skipped.
set -u

f=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty' 2>/dev/null)
[ -n "$f" ] && [ -f "$f" ] || exit 0

if npx --no-install prettier --version >/dev/null 2>&1; then
  npx --no-install prettier --write --ignore-unknown --log-level warn "$f" >/dev/null 2>&1
fi

case "$f" in
  *.ts | *.mts | *.cts | *.js | *.mjs | *.cjs)
    npx --no-install eslint --version >/dev/null 2>&1 || exit 0
    if ! out=$(npx --no-install eslint --fix --no-warn-ignored "$f" 2>&1); then
      printf '%s\n' "$out" >&2
      exit 2
    fi
    ;;
esac

exit 0
