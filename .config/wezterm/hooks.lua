local wezterm = require 'wezterm'

local function segments_for_right_status(window)
	return {
		window:active_workspace(),
		wezterm.strftime("%a %b %-d %H:%M"),
		wezterm.hostname(),
	}
end

wezterm.on('augment-command-palette', function(_, _)
  return {
    {
      brief = 'Kill workspace',
      icon = 'md_skull',

      action = wezterm.action_callback(function(currentwindow, _, _)
				local killworkspace = require("actions.workspace-kill")
				local w = currentwindow:active_workspace()
      	killworkspace.kill_workspace(w)
    	end
      )
      ,
    },
  }
end)

wezterm.on("update-status", function(window, _)
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
	local segments = segments_for_right_status(window)

	local color_scheme = window:effective_config().resolved_palette
	local bg = wezterm.color.parse(color_scheme.background)
	local fg = color_scheme.foreground

	local gradient_to, gradient_from = bg, bg

	local appearance = require 'appearance'
	if appearance.is_dark() then
		gradient_from = gradient_to:lighten(0.2)
	else
		gradient_from = gradient_to:darken(0.2)
	end

	local gradient = wezterm.color.gradient(
		{
			orientation = "Horizontal",
			colors = { gradient_from, gradient_to },
		},
		#segments -- only gives us as many colours as we have segments.
	)

	local elements = {}

	for i, seg in ipairs(segments) do
		local is_first = i == 1

		if is_first then
			table.insert(elements, { Background = { Color = "none" } })
		end
		table.insert(elements, { Foreground = { Color = gradient[i] } })
		table.insert(elements, { Text = SOLID_LEFT_ARROW })

		table.insert(elements, { Foreground = { Color = fg } })
		table.insert(elements, { Background = { Color = gradient[i] } })
		table.insert(elements, { Text = " " .. seg .. " " })
	end

	window:set_right_status(wezterm.format(elements))
end)

wezterm.on("update-status", function(window, pane)
	local tab = window:active_tab()

	local window_dims = window:get_dimensions()

	local pane_info = {}
	for _, curr_pane in ipairs(tab:panes_with_info()) do
		if curr_pane.is_active then
			pane_info = curr_pane
		end
	end

	if pane_info.is_zoomed then
		return
	end

	local tab_dims = tab:get_size()

	local target_width = math.floor(2 * tab_dims.cols / 3)
	local target_height = math.floor(2 * tab_dims.rows / 3)

	local pane_dims = pane:get_dimensions()
	local pane_width = pane_dims.cols
	local pane_height = pane_dims.viewport_rows

	local delta_width = math.tointeger(target_width - pane_width)
	local delta_height = math.tointeger(target_height - pane_height)

	local act = wezterm.action
	if pane_width < target_width then
		local dir = 'Right'
		if pane_info.left > 0 then
			dir = 'Left'
		end
		wezterm.log_info("adjusting: " .. delta_width)
		wezterm.log_info("dir: " .. dir)
		window:perform_action(act.AdjustPaneSize{dir, delta_width}, pane)
	end


	if pane_height < target_height then
	local dir = 'Down'
		if pane_info.top > 0 then
			dir = 'Up'
		end
		wezterm.log_info("adjusting: " .. delta_height)
		wezterm.log_info("dir: " .. dir)
		window:perform_action(act.AdjustPaneSize{dir, delta_height}, pane)
	end
end)
