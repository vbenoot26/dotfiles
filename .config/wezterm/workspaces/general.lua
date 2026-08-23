return {
  create = function(cwd, label)
    local wezterm = require 'wezterm'
    local _, pane, _ = wezterm.mux.spawn_window({
      workspace = label,
      cwd = cwd,
    })

    pane:activate {}
  end
}

