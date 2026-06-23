local M = {}

M.apply = function(config)
	local wezterm = require("wezterm")
	local act = wezterm.action
	local openinhelix = require("actions.open-helix")
	local projects = require("actions.projects")

	local project_dir = wezterm.home_dir .. "/projects/nova"
	local personal_dir = wezterm.home_dir .. "/projects/personal"

	local novapicker = projects.new(project_dir)
	local generalpicker = projects.new(wezterm.home_dir)
	local personalpicker = projects.new(personal_dir)

	config.keys = {
		{ key = "9", mods = "CMD", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
		{ key = "n", mods = "CMD", action = act.SwitchWorkspaceRelative(1) },
		{ key = "p", mods = "CMD", action = act.SwitchWorkspaceRelative(-1) },

		{ key = ";", mods = "CMD", action = novapicker:choose_project() },
		{ key = "f", mods = "CMD", action = generalpicker:choose_project() },
		{ key = "'", mods = "CMD", action = personalpicker:choose_project() },


		{ key = "Enter", mods = "CMD", action = act.TogglePaneZoomState },

		{ key = "/", mods = "CMD", action = act.QuickSelect},
		{ key = "/", mods = "ALT|CMD", action = openinhelix.QuickSelect()},

		{ key = 'Enter', mods = 'ALT', action = wezterm.action.DisableDefaultAssignment },

		{key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane { confirm = true }},

		{ key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "d", mods = "SHIFT|CMD", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "h", mods = "CMD", action = act.ActivatePaneDirection("Left") },
		{ key = "l", mods = "CMD", action = act.ActivatePaneDirection("Right") },
		{ key = "j", mods = "CMD", action = act.ActivatePaneDirection("Down") },
		{ key = "k", mods = "CMD", action = act.ActivatePaneDirection("Up") },
	}
end

return M
