#!/usr/bin/env bash
# worktree-guard.sh — PreToolUse hook: steer `git worktree add` to the policy path.
#
# This is the ADVISORY layer, not the guarantee. ~/.config/bin/git is what actually
# enforces the policy, for every harness, by refusing off-policy `git worktree add`.
# This hook exists so Claude is told *before* the command runs, with the correct
# command to use — a clear instruction beats a shell error the model has to interpret.
#
# Deliberately heuristic: it reads a shell command string, not argv, so it cannot
# parse destinations as precisely as the shim. It therefore only blocks the clear
# case (a `git worktree add` that names no path under the policy root) and stays
# silent whenever it is unsure. The shim catches whatever slips past.
#
# SCOPE — registered in the GLOBAL ~/.claude/settings.json, so it must no-op unless
# the cwd is inside a repo under ~/Work. Never interferes with other projects.
#
# CONTRACT: stdin = PreToolUse JSON. exit 0 = allow, exit 2 = block (stderr shown).

set -uo pipefail

WT_ROOT="${WT_POLICY_ROOT:-$HOME/Work/worktrees}"
WT_SCOPE="${WT_POLICY_SCOPE:-$HOME/Work}"

payload="$(cat)"

tool="$(jq -r '.tool_name // empty' <<<"$payload" 2>/dev/null)" || exit 0
[ "$tool" = "Bash" ] || exit 0

cmd="$(jq -r '.tool_input.command // empty' <<<"$payload" 2>/dev/null)" || exit 0
[ -n "$cmd" ] || exit 0

# Only `git worktree add`, allowing for flags between the words.
grep -Eq 'worktree[[:space:]]+add' <<<"$cmd" || exit 0

# Deliberate escapes: leave them alone.
grep -q 'WT_POLICY_BYPASS' <<<"$cmd" && exit 0

# Already targeting the policy root (or using the helper) -> nothing to say.
grep -qF "$WT_ROOT" <<<"$cmd" && exit 0
grep -qF '~/Work/worktrees' <<<"$cmd" && exit 0

cwd="$(jq -r '.cwd // empty' <<<"$payload" 2>/dev/null)"
[ -n "$cwd" ] && [ -d "$cwd" ] || cwd="$PWD"

command -v git >/dev/null 2>&1 || exit 0
common="$(cd "$cwd" 2>/dev/null && git rev-parse --git-common-dir 2>/dev/null)" || exit 0
common="$(cd "$cwd" 2>/dev/null && realpath -m -- "$common" 2>/dev/null)" || exit 0
primary="$(dirname "$common")"

# Out of scope, or an allowlisted repo -> the shim will decide; stay quiet.
case "$primary/" in "$WT_SCOPE"/*) ;; *) exit 0 ;; esac
case "$primary/" in "$HOME"/Work/learn/quant-research/*) exit 0 ;; esac

repo="$(basename "$primary")"
branch="$(grep -oE '\-b[[:space:]]+[^[:space:]]+' <<<"$cmd" | head -1 | awk '{print $2}')"
[ -n "$branch" ] || branch="<branch>"

cat >&2 <<EOF
BLOCKED: worktrees must live at ${WT_ROOT/#$HOME/\~}/<repo>/<lane>.

  repo : ${primary/#$HOME/\~}
  use  : ${WT_ROOT/#$HOME/\~}/$repo/${branch//\//-}

Run one of these instead:

  wt add $branch
  git worktree add -b $branch ${WT_ROOT/#$HOME/\~}/$repo/${branch//\//-}

One shared root keeps every lane visible to \`gwq list -g\` and \`wt-audit\`, and
keeps repo directories free of nested trees. ~/.config/bin/git enforces this for
every harness, so an off-policy add would be refused anyway.

Genuine exception? Add a glob to ~/.config/worktree-policy.conf, or for a one-off:
  WT_POLICY_BYPASS=1 git worktree add ...
EOF
exit 2
