local M = {}

M.toggleTransparent = function(config)
	local bg_op = config.window_background_opacity
	if bg_op == 0.6 then
		config.window_background_opacity = 1
		return
	end

	config.window_background_opacity = 0.6
end

return M
