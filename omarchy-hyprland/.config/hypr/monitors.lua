-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

-- quomptrade: these two are Omarchy's defaults but conflict with the explicit
-- layout in the customizations block below (GDK_SCALE 2 doubles UI scale on
-- these 1x panels, and the catch-all rule fights the per-monitor rules).
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- ---------------------------------------------------------------------------
-- quomptrade customizations
-- Ported from the retired monitors.conf (Omarchy 3), which the Omarchy 4
-- upgrade had only partially carried over.
--
-- Monitors are matched by desc: rather than DP-N, because the DP port numbers
-- get reassigned across dock/replug cycles while the descriptor is stable.
-- Both BenQ panels support 75Hz -- the upgrade's generated file had silently
-- dropped them to 60. Confirm modes with: hyprctl monitors all
-- ---------------------------------------------------------------------------

-- -------------------------------------------------------------- Starlit Work Setup ------------------------------------------------------
-- local left_monitor = "desc:BNQ BenQ GW3290QT 88P00389019"
-- local middle_monitor = "desc:BNQ BenQ GW3290QT ACP00296019"
-- local laptop_monitor = "desc:AU Optronics 0xFA9B"

-- NOTE: transform: 1 = 90 degrees, 3 = 270 degrees.
-- hl.monitor({ output = left_monitor, mode = "2560x1440@75", position = "0x0", scale = 1, transform = 1 })
-- hl.monitor({ output = middle_monitor, mode = "2560x1440@75", position = "1440x0", scale = 1, transform = 3 })
-- Laptop panel (eDP-1) -- centered under the middle BenQ.
--
-- NOTE: this one uses the empty catch-all, NOT laptop_monitor. Hyprland's
-- desc: matching works for both BenQs and for the workspace rules below, but
-- silently fails for this eDP panel in hl.monitor -- the rule is ignored and
-- the panel falls back to scale 2. Verified by A/B reload. Keep it last so the
-- two specific BenQ rules still take precedence.
--
-- Also do NOT pass an empty monitor to hl.workspace_rule: doing so breaks this
-- panel's scale again even with the catch-all present.
-- hl.monitor({ output = "", mode = "preferred", position = "2880x0", scale = 1 })

-- Pin workspaces to monitors.
-- hl.workspace_rule({ workspace = "1", monitor = left_monitor, default = true }) -- tmux/ghostty (muxy)
-- hl.workspace_rule({ workspace = "2", monitor = middle_monitor, default = false }) -- chromium
-- hl.workspace_rule({ workspace = "3", monitor = laptop_monitor, default = false }) -- slack

-- NOTE: Send apps to the workspace they belong on.
-- o.window("chromium", { workspace = "2" })
-- Slack webapp: chromium derives this class from the URL, and --class is
-- ignored under Wayland, so match the derived class instead.
--
--
-- -------------------------------------------------------------- Eldecco Work Setup ------------------------------------------------------
local top_monitor = "desc:LG Electronics LG IPS QHD 507TFYA1G282"
local laptop_monitor = "desc:AU Optronics 0xFA9B"
hl.monitor({ output = top_monitor, mode = "2560x1440@60", position = "0x0", scale = omarchy_monitor_scale })
-- Laptop panel (eDP-1) -- centered under the top LG monitor.
hl.monitor({ output = laptop_monitor, mode = "1920x1200@60", position = "320x1440", scale = omarchy_monitor_scale })
hl.workspace_rule({ workspace = "1", monitor = top_monitor, default = true }) -- tmux/ghostty (muxy)
hl.workspace_rule({ workspace = "2", monitor = laptop_monitor, default = false }) -- chromium
o.window("chromium", { workspace = "2" })
