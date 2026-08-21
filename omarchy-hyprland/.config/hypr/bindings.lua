-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- ---------------------------------------------------------------------------
-- quomptrade customizations
-- Ported from the retired bindings.conf (Omarchy 3). 23 of the original 27
-- bindd lines were dropped because Omarchy 4 now ships them verbatim -- same
-- chord, same description, same URL -- so rebinding them here would only
-- double-bind them. What follows are the four genuine deviations.
--
-- Before adding a binding, check whether Omarchy already ships it:
--   grep -n 'o\.bind' /usr/share/omarchy/default/hypr/bindings/*.lua
-- (some lines read `o.bind( "KEY"` with a space, which a naive grep misses)
-- ---------------------------------------------------------------------------

-- Local tmux session. Omarchy's default is a generic terminal-tmux launch; this
-- keeps the custom session name and pins it to workspace 1.
hl.unbind("SUPER + ALT + RETURN")
o.bind(
  "SUPER + ALT + RETURN",
  "Tmux",
  [[[workspace 1] uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)" bash -c "tmux attach || tmux new -s muxy-tp"]]
)

-- Remote tmux on quomptblr. This lived on SUPER + CTRL + RETURN until Omarchy 4
-- claimed that chord for Herdr; moved here rather than unbinding Herdr.
o.bind(
  "SUPER + CTRL + SHIFT + RETURN",
  "Tmux remote (qomptblr)",
  [[uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)" bash -c "ssh -t quomptblr 'tmux attach || tmux new -s qmuxyblr-elaeo-x86'"]]
)

-- Typora in place of Omarchy's Omawrite.
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", { launch = "typora --enable-wayland-ime" })

-- Slack in place of Omarchy's Google Maps.
hl.unbind("SUPER + SHIFT + S")
o.bind(
  "SUPER + SHIFT + S",
  "Slack",
  { webapp = "https://app.slack.com/client/T02FK8UBGPL/activity-inbox", focus = true }
)
