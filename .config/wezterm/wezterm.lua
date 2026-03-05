local wezterm = require("wezterm")
local appearance = require("appearance")

local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 28
config.font_size = 18

config.color_scheme = "kanagawabones"

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.inactive_pane_hsb = {
	saturation = 0.5,
	brightness = 0.4,
}

config.window_frame = {
	font_size = 15.0,
}

require 'hooks'
config.keys = require 'keys'
config.window_background_opacity = require 'opacity'

return config
