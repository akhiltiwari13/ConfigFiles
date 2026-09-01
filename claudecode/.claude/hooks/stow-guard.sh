#!/usr/bin/env bash
# stow-guard.sh — PreToolUse hook: refuse `stow` / `bootstrap.sh` from a linked
# git worktree of a stow-managed dotfiles repo.
#
# WHY
#   Every live symlink in $HOME (~/.bashrc, ~/.config/hypr, ~/.config/foot/foot.ini,
#   and ~/.stowrc itself) holds an ABSOLUTE path into whichever tree was stowed
#   last. Running stow from a parallel-agent worktree silently repoints $HOME at
#   that worktree; deleting the worktree afterwards then breaks the shell, the
#   window manager and the terminal. `stow --adopt` is worse still — it pulls live
#   files into the worktree, reverting tracked config with no obvious trace.
#
#   scripts/bootstrap.sh carries the same guard internally, which covers every
#   harness. This hook is the Claude-side layer, and additionally catches bare
#   `stow` invocations that never go through bootstrap.sh.
#
# SCOPE
#   This is registered in the GLOBAL ~/.claude/settings.json, so it runs for every
#   project. It must stay silent everywhere except the exact case above:
#     - not a Bash tool call            -> allow
#     - command isn't stow/bootstrap.sh -> allow
#     - cwd isn't inside a git repo     -> allow
#     - repo has no stow/.stowrc        -> allow  (pqr, platform, everything else)
#     - cwd IS the primary worktree     -> allow
#   Anything unexpected (missing git, malformed payload) also allows: a broken
#   guard must not wedge every Bash call in every project.
#
# CONTRACT
#   stdin: PreToolUse JSON payload. exit 0 = allow, exit 2 = block (stderr shown).

set -uo pipefail

payload="$(cat)"

tool="$(jq -r '.tool_name // empty' <<<"$payload" 2>/dev/null)" || exit 0
[ "$tool" = "Bash" ] || exit 0

command_str="$(jq -r '.tool_input.command // empty' <<<"$payload" 2>/dev/null)" || exit 0
[ -n "$command_str" ] || exit 0

# `stow` as an actual command word (not "git show", not the word inside a path),
# or any invocation of bootstrap.sh.
grep -Eq '(^|[;&|(]|\s)stow(\s|$)|bootstrap\.sh' <<<"$command_str" || exit 0

cwd="$(jq -r '.cwd // empty' <<<"$payload" 2>/dev/null)"
[ -n "$cwd" ] && [ -d "$cwd" ] || cwd="$PWD"

command -v git >/dev/null 2>&1 || exit 0
git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1 || exit 0

gitdir="$(git -C "$cwd" rev-parse --absolute-git-dir 2>/dev/null)" || exit 0
common="$(cd "$cwd" 2>/dev/null && realpath "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null)" || exit 0
[ -n "$gitdir" ] && [ -n "$common" ] || exit 0

# Primary worktree: per-worktree gitdir IS the shared object store. Allow.
[ "$gitdir" = "$common" ] && exit 0

# Linked worktree — but only guard stow-managed dotfiles repos.
primary="$(dirname "$common")"
[ -f "$primary/stow/.stowrc" ] || exit 0

toplevel="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)" || toplevel="$cwd"

cat >&2 <<EOF
BLOCKED: stow must never run from a linked worktree.

  this worktree : $toplevel
  primary       : $primary

Stowing here would repoint the live \$HOME symlinks (~/.bashrc, ~/.config/hypr,
~/.config/foot/foot.ini, ~/.stowrc) at this worktree. Deleting the worktree would
then break the shell, Hyprland and the terminal. \`stow --adopt\` would additionally
pull live files in here, silently reverting tracked config.

Worktrees are edit-and-commit only. Commit on this branch, merge into main, then
stow from the primary:

  cd $primary && ./scripts/bootstrap.sh omarchy --dry-run

(If you genuinely need to inspect what stow would do, run it from the primary with
-n. There is no safe way to run it from here.)
EOF
exit 2
