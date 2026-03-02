local wezterm = require("wezterm")
local M = {}
M.__index = M

function M.new(dir)
	return setmetatable({
		dir = dir,
	}, M)
end

local mux = wezterm.mux

function M:all_dirs()
	local projects = {}

	for _, dir in ipairs(wezterm.glob(self.dir .. "/*")) do
		table.insert(projects, dir)
	end

	return projects
end

local function dev_workspace(child_window, child_pane, cwd, label)
	local tab, helix_pane, window = mux.spawn_window({
		workspace = label,
		cwd = label,
	})

	local opencode_pane = helix_pane:split({
		direction = "Right",
		size = 0.3,
		cwd = cwd,
	})

	opencode_pane:split({
		direction = "Bottom",
		size = 0.6,
		cwd = cwd,
	})

	helix_pane:send_text("hx .\n")
	opencode_pane:send_text("opencode\n")
end

function M:choose_project()
	local choices = {}
	for _, value in ipairs(self:all_dirs()) do
		table.insert(choices, { label = value })
	end

	return wezterm.action.InputSelector({
		title = "Projects",
		choices = choices,
		fuzzy = true,
		action = wezterm.action_callback(function(child_window, child_pane, id, label)
			if not label then
				return
			end

			local existing_workspaces = mux.get_workspace_names()
			local workspace_exists = false
			for _, name in ipairs(existing_workspaces) do
				if name == label then
					workspace_exists = true
					break
				end
			end

			if not workspace_exists then
				dev_workspace(child_window, child_pane, label, label)
			end

			child_window:perform_action(
				wezterm.action.SwitchToWorkspace({
					name = label,
				}),
				child_pane
			)
		end),
	})
end

return M
