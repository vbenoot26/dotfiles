local M = {}

M.create = function(cwd, label)
  local wezterm = require 'wezterm'
	local _, helix_pane, _ = wezterm.mux.spawn_window({
		workspace = label,
		cwd = cwd,
	})

	local lazygit_pane = helix_pane:split({
		direction = "Right",
		size = 0.5,
		cwd = cwd,
	})

	lazygit_pane:split({
		direction = "Bottom",
		size = 0.3,
		cwd = cwd,
	})

	helix_pane:send_text("hx .\n")
	lazygit_pane:send_text("lazygit\n")

	helix_pane:activate {}
end

return M

