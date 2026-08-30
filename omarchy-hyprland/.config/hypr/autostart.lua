-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- ---------------------------------------------------------------------------
-- quomptrade customizations
-- Ported from the retired autostart.conf (Omarchy 3).
-- ---------------------------------------------------------------------------

-- Terminal attached to the local tmux session, pinned to workspace 1.
-- Session name matches the SUPER + ALT + RETURN binding in bindings.lua.
o.exec_on_start(
	[[[workspace 1 silent] uwsm-app -- xdg-terminal-exec --dir="$HOME" bash -c "tmux attach || tmux new -s muxy-tp"]]
)

o.exec_on_start("omarchy-launch-browser")

-- o.exec_on_start(o.launch_webapp_sole("Slack", "https://app.slack.com/client/T02FK8UBGPL/activity-inbox"))
