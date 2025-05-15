-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()
-- This is where you actually apply your config choices
-- For example, changing the color scheme:
-- config.color_scheme = "Catppuccin Mocha"
config.color_scheme = "Catppuccin Mocha"
config.initial_cols = 65
config.initial_rows = 45
config.font = wezterm.font("JetBrains Mono", { weight = "Bold", italic = true })
config.font_size = 12.5
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.enable_scroll_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_dead_keys = false
config.debug_key_events = true
config.default_workspace = "wezy"
-- enable required plugins
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
workspace_switcher.apply_to_config(config)
-- local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")
-- modal.apply_to_config(config)
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
	{
		key = "|",
		mods = "LEADER|SHIFT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "w",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
		end),
	},
	{
		key = "W",
		mods = "ALT|SHIFT",
		action = resurrect.window_state.save_window_action(),
	},
	{
		key = "T",
		mods = "ALT|SHIFT",
		action = resurrect.tab_state.save_tab_action(),
	},
	{
		key = "s",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
			resurrect.window_state.save_window_action()
		end),
	},
	{
		key = "r",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
				local type = string.match(id, "^([^/]+)") -- match before '/'
				id = string.match(id, "([^/]+)$") -- match after '/'
				id = string.match(id, "(.+)%..+$") -- remove file extention
				local opts = {
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
				}
				if type == "workspace" then
					local state = resurrect.state_manager.load_state(id, "workspace")
					resurrect.workspace_state.restore_workspace(state, opts)
				elseif type == "window" then
					local state = resurrect.state_manager.load_state(id, "window")
					resurrect.window_state.restore_window(pane:window(), state, opts)
				elseif type == "tab" then
					local state = resurrect.state_manager.load_state(id, "tab")
					resurrect.tab_state.restore_tab(pane:tab(), state, opts)
				end
			end)
		end),
	},
	-- for renaming tabs
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new tab name",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		key = "p",
		mods = "LEADER",
		action = act.PaneSelect({
			mode = "Activate",
		}),
	},
	{
		key = "c",
		mods = "LEADER",
		action = act.PaneSelect({
			mode = "Activate",
		}),
	},
	{
		key = "s",
		mods = "LEADER",
		action = workspace_switcher.switch_workspace(),
	},
	{
		key = "S",
		mods = "LEADER",
		action = workspace_switcher.switch_to_prev_workspace(),
	},
}

-- tab navigation settings
for i = 1, 8 do
	-- CTRL+ALT + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
	-- F1 through F8 to activate that tab
	table.insert(config.keys, {
		key = "F" .. tostring(i),
		action = act.ActivateTab(i - 1),
	})
end
return config
