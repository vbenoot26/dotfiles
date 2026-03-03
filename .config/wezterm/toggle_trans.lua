local M = {}
local wezterm = require("wezterm")

-- Initialize with the current opacity value
M.create_toggle_action = function(current_opacity)
		if current_opacity == current_opacity then
			current_opacity = 1.0
		else
			current_opacity = 0.6
		end

		local command = 'echo "return ' .. current_opacity .. '" > ~/.config/wezterm/opacity.lua'

		return wezterm.action_callback(function(window, _)
			window:toast_notification('wezterm', 'toggling!', nil, 4000)
			wezterm.background_child_process { command }
			wezterm.reload_configuration()
		end)
end

return M
