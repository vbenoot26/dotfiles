local M = {}

M.create = function(cwd, label)
  local wezterm = require 'wezterm'
	local _, helix_pane, window = wezterm.mux.spawn_window({
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
		cwd = cwd .. "/main",
	})

	helix_pane:send_text("hx main\n")
	lazygit_pane:send_text("lazygit -p main\n")

	local _, test_pane = window:spawn_tab {cwd = cwd .. "/main"}

	local opencode_pane = test_pane:split({
		direction = "Right",
		size = 0.5,
		cwd = cwd .. "/clanker",
	})

	opencode_pane:send_text("opencode\n")

	helix_pane:activate {}
end

return M

