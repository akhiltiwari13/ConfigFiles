#!/usr/bin/env bash
# Claude Code status line — mirrors Starship prompt style
input=$(cat)

# Directory: truncate to last 2 parts, using … prefix if deeper
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
home_replaced="${cwd/#$HOME/~}"
IFS='/' read -ra parts <<< "$home_replaced"
count=${#parts[@]}
if [ "$count" -le 2 ]; then
  dir="$home_replaced"
else
  dir="…/${parts[$count-2]}/${parts[$count-1]}"
fi

# Git branch (skip optional lock)
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)

# Git status indicators
git_status=""
if [ -n "$branch" ]; then
  status_output=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" status --porcelain 2>/dev/null)
  untracked=$(echo "$status_output" | grep -c '^??' || true)
  modified=$(echo "$status_output" | grep -c '^.M\|^M.' || true)
  staged=$(echo "$status_output" | grep -c '^[AMDRC]' || true)
  [ "$untracked" -gt 0 ] && git_status="${git_status}? "
  [ "$modified" -gt 0 ] && git_status="${git_status} "
  [ "$staged" -gt 0 ] && git_status="${git_status} "
fi

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Context remaining
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
ctx_part=""
[ -n "$remaining" ] && ctx_part=" ctx:$(printf '%.0f' "$remaining")%"

# Assemble output with ANSI colors matching Starship cyan theme
if [ -n "$branch" ]; then
  printf '\033[1;36m%s\033[0m \033[3;36m%s\033[0m \033[36m%s\033[0m|\033[0m%s%s' \
    "$dir" "$branch" "$git_status" "$model" "$ctx_part"
else
  printf '\033[1;36m%s\033[0m|\033[0m%s%s' \
    "$dir" "$model" "$ctx_part"
fi
