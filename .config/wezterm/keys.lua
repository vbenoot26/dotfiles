local M = {}

M.apply = function(config)
	local wezterm = require("wezterm")
	local act = wezterm.action
	local openinhelix = require("actions.open-helix")
	local projects = require("actions.projects")

	local project_dir = wezterm.home_dir .. "/projects"

	local projectpicker = projects.new(project_dir .. "/*")
	local generalpicker = projects.new(wezterm.home_dir .. "/*")

	config.keys = {
	 { key = "9", mods = "CTRL", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },

	 { key = ";", mods = "CTRL", action = projectpicker:choose_project() },
	 { key = "f", mods = "CTRL", action = generalpicker:choose_project() },

	 { key = "Enter", mods = "CTRL", action = act.TogglePaneZoomState },

	 { key = "/", mods = "CTRL", action = act.QuickSelect},
	 { key = "/", mods = "ALT|CTRL", action = openinhelix.QuickSelect()},

	 { key = 'Enter', mods = 'ALT', action = wezterm.action.DisableDefaultAssignment },

	 {key = "w", mods = "CTRL", action = wezterm.action.CloseCurrentPane { confirm = true }},

	 { key = "d", mods = "CTRL", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	 { key = "d", mods = "SHIFT|CTRL", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	 { key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
	 { key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },
	 { key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down") },
	 { key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
	}
end

return M
