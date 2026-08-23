local M = {}

local function trim(str)
  return (str:gsub("^%s*(.-)%s*/n*$", "%1"))
end

M.getWorkspace = function(cwd)
  local location = cwd .. "/.wezconf"
  print(location)
  local file =io.open(location, "r")

  if not file then
    return nil
  end

  local content = file:read("*all")
  file:close()

  content = trim(content)
  print(content)
  if string.find(content, "NOVA") then
    return require 'workspaces.nova'
  elseif string.find(content, "PROJECT") then
    return require 'workspaces.project'
  end
end

return M
