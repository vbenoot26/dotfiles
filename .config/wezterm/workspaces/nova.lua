local M = {}
local notesDir = "/Users/vincentbenoot/notes"

local function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

local function openNotes(cwd)
	local splitted = split(cwd, "/")

	local dirName = splitted[#splitted]
	local notesOpen = notesDir .. "/" .. dirName

	return notesOpen
end

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

	local _, clanker_pane = window:spawn_tab {cwd = cwd .. "/clanker"}

	local opencode_pane = clanker_pane:split({
		direction = "Right",
		size = 0.5,
		cwd = cwd .. "/clanker",
	})

	opencode_pane:send_text("opencode\n")

	local _, notes_pane = window:spawn_tab { cwd = openNotes(cwd)}
	notes_pane:send_text("hx .\n")

	helix_pane:activate {}
end

return M

