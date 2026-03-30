#!/usr/bin/env bash
# Claude Code status line — mirrors Starship config (directory + git branch + git status)
# plus Claude-specific context info.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- Directory (truncate to last 2 components, matching truncation_length = 2) ---
dir_display=$(python3 -c "
import os, sys
p = sys.argv[1]
home = os.path.expanduser('~')
if p.startswith(home):
    p = '~' + p[len(home):]
parts = p.rstrip('/').split('/')
if len(parts) > 2:
    print('…/' + '/'.join(parts[-2:]))
else:
    print('/'.join(parts))
" "$cwd" 2>/dev/null || echo "$cwd")

# --- Git branch ---
git_branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)

# --- Git status symbols (matching Starship git_status format) ---
git_status_str=""
if [ -n "$git_branch" ]; then
    git_status_raw=$(git -C "$cwd" status --porcelain 2>/dev/null)
    untracked=$(echo "$git_status_raw" | grep -c '^\?\?' || true)
    modified=$(echo "$git_status_raw" | grep -c '^.M\|^M.' || true)
    staged=$(echo "$git_status_raw" | grep -c '^[MADRC]' || true)
    deleted=$(echo "$git_status_raw" | grep -c '^.D\|^D.' || true)

    [ "$untracked" -gt 0 ] && git_status_str="${git_status_str}? "
    [ "$modified"  -gt 0 ] && git_status_str="${git_status_str} "
    [ "$staged"    -gt 0 ] && git_status_str="${git_status_str} "
    [ "$deleted"   -gt 0 ] && git_status_str="${git_status_str} "

    # ahead/behind
    upstream=$(git -C "$cwd" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    if [ -n "$upstream" ]; then
        ahead=$(git -C "$cwd" rev-list --count "@{upstream}..HEAD" 2>/dev/null || echo 0)
        behind=$(git -C "$cwd" rev-list --count "HEAD..@{upstream}" 2>/dev/null || echo 0)
        [ "$ahead"  -gt 0 ] && [ "$behind" -gt 0 ] && git_status_str="${git_status_str}⇕⇡${ahead}⇣${behind} "
        [ "$ahead"  -gt 0 ] && [ "$behind" -eq 0 ] && git_status_str="${git_status_str}⇡${ahead} "
        [ "$behind" -gt 0 ] && [ "$ahead"  -eq 0 ] && git_status_str="${git_status_str}⇣${behind} "
    fi

    [ -z "$git_status_str" ] && git_status_str=" "
fi

# --- Assemble output ---
line=""

# Directory
printf '%s' "$dir_display"

# Git
if [ -n "$git_branch" ]; then
    printf ' %s %s' "$git_branch" "$git_status_str"
fi

# Separator
printf ' |'

# Model
if [ -n "$model" ]; then
    printf ' %s' "$model"
fi

# Context window
if [ -n "$used_pct" ]; then
    printf ' | ctx: %s%%' "$(printf '%.0f' "$used_pct")"
fi

printf '\n'
