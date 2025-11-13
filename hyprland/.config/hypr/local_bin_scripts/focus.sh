#!/bin/bash

win_info=$(hyprctl activewindow -j)
group=$(jq -r '.grouped' <<<"$win_info")
group_size=$(jq 'length' <<<"$group")

if [[ "$group_size" -eq 0 ]]; then
    # Not in a group, just move focus as usual
    if [[ "$1" == "left" ]]; then
        hyprctl dispatch movefocus l
    else
        hyprctl dispatch movefocus r
    fi
    exit 0
fi

# In a group, find the position of the current window
address=$(jq -r '.address' <<<"$win_info")
position=$(jq -r --arg addr "$address" 'map(tostring) | index($addr)' <<<"$group")

if [[ "$1" == "left" ]]; then
    if [[ "$position" -eq 0 ]]; then
        hyprctl dispatch movefocus l
    else
        hyprctl dispatch changegroupactive b
    fi
else
    last_index=$((group_size - 1))
    if [[ "$position" -eq "$last_index" ]]; then
        hyprctl dispatch movefocus r
    else
        hyprctl dispatch changegroupactive f
    fi
fi
