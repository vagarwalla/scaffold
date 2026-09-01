#!/usr/bin/env bash
# Stop a password, API key or token from being saved into the project.
#
# Once a secret is committed it is in the history for good, and several of
# these repos are public — so this refuses the commit rather than reporting it
# afterwards. It never prints the secret it found, only the file and line.
#
# Runs before any `git commit`. Reads the tool payload on stdin, writes an
# allow-or-refuse decision on stdout.
set -uo pipefail

cmd=$(jq -r '.tool_input.command // ""' 2>/dev/null)
case "$cmd" in *"git commit"*) ;; *) echo '{}'; exit 0 ;; esac

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo '{}'; exit 0; }

# Shapes that are unambiguously credentials. Deliberately narrow: a check that
# cries wolf on every UUID gets switched off, and then it protects nothing.
NAMED='sk-ant-api[0-9]{2}-[A-Za-z0-9_-]{40,}|sk-[A-Za-z0-9]{32,}|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36}|xox[baprs]-[A-Za-z0-9-]{12,}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
# A secret assigned to an obviously-secret name, long enough not to be a label.
ASSIGNED='(api[_-]?key|secret|token|password|passwd|client[_-]?secret)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9_/+.-]{24,}["'"'"']'
# Placeholders in examples and docs are not secrets.
PLACEHOLDER='example|changeme|your[_-]|placeholder|xxxx|\.\.\.|<[a-z]|\$\{|REPLACE|dummy|fake|test[_-]?key'

added=$(git diff --cached -U0 2>/dev/null | grep '^+' | grep -v '^+++')
# `git commit -a` stages tracked edits as it runs, so they are not staged yet.
case "$cmd" in
  *" -a"*|*" -am"*|*"--all"*)
    added="${added}
$(git diff -U0 2>/dev/null | grep '^+' | grep -v '^+++')" ;;
esac

[ -n "$added" ] || { echo '{}'; exit 0; }

hits=$(printf '%s\n' "$added" \
  | grep -EI "$NAMED|$ASSIGNED" 2>/dev/null \
  | grep -EIv "$PLACEHOLDER" 2>/dev/null \
  | head -5)

[ -n "$hits" ] || { echo '{}'; exit 0; }

# Name the files, never the values.
files=$(git diff --cached --name-only 2>/dev/null | tr '\n' ' ')
count=$(printf '%s\n' "$hits" | grep -c . || echo 0)

reason="Refused: this commit looks like it contains ${count} secret(s) — an API key, token or password.

Staged files: ${files}

The values are not shown here on purpose. Check those files, move the secret into .env.local (already ignored), and commit again.

If it is a false alarm (a hash or a fixture that only looks like a key), say so and I will commit it as-is."

jq -nc --arg r "$reason" \
  '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
