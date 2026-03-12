local wezterm = require("wezterm")
local M = {}
M.__index = M

function M.new(dir, workspace)
	return setmetatable({
		dir = dir,
		workspace = workspace,
	}, M)
end


function M:all_dirs()
	local projects = {}

	for _, dir in ipairs(wezterm.glob(self.dir .. "/*")) do
		table.insert(projects, {label = dir} )
	end

	return projects
end

function M:choose_project()
	return wezterm.action.InputSelector({
		title = "Projects",
		choices = self:all_dirs(),
		fuzzy = true,
		action = wezterm.action_callback(function(child_window, child_pane, _, label)
			local mux = wezterm.mux
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
				self.workspace.create(label, label)
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
