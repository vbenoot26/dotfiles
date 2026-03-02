---
name: wezterm
description: WezTerm terminal configuration, Lua scripting, key bindings, and workflows
license: MIT
compatibility: opencode
---

## What I do
- Explain WezTerm Lua configuration structure and syntax
- Help configure key bindings, appearance, and behavior
- Guide domain and SSH remote terminal setup
- Assist with Lua event handlers and scripting patterns
- Explain color schemes, fonts, and window styling
- Debug configuration validation and reload mechanics

## Configuration Files & Locations

### File Paths
- **macOS**: `~/.config/wezterm/wezterm.lua`
- **Linux**: `~/.config/wezterm/wezterm.lua`
- **Windows**: `%APPDATA%\wezterm\wezterm.lua`

### Config Reloading
- Config is evaluated when WezTerm starts
- **Reload after editing**: `CTRL+SHIFT+R` (default key binding)
- Errors appear in the "Debug Overlay" accessible via `CTRL+SHIFT+L`
- Check validity: Run `wezterm ls-fonts` or `wezterm show-keys` to verify no parse errors

### Config Structure
WezTerm configs are Lua files that return a configuration table:

```lua
local config = wezterm.config_builder()

-- All configuration goes here
config.font = wezterm.font("Fira Code")
config.font_size = 12.0

-- Return the config table
return config
```

## Core Configuration Sections

### Window Configuration
Controls window appearance and behavior:

```lua
config.window_decorations = "RESIZE"  -- "NONE", "TITLE", "RESIZE", "TITLE|RESIZE"
config.window_frame = {
  border_left_width = 0,
  border_right_width = 0,
  border_bottom_height = 0,
  border_top_height = 0,
}
config.window_background_opacity = 1.0  -- 0.0 (transparent) to 1.0 (opaque)
config.text_background_opacity = 1.0
config.initial_cols = 200
config.initial_rows = 50
config.default_workspace = "main"
```

### Font Configuration
```lua
-- Single font
config.font = wezterm.font("Fira Code", { weight = "Regular" })
config.font_size = 12.0
config.line_height = 1.0

-- Font rules for different scripts/styles
config.font_rules = {
  {
    italic = true,
    font = wezterm.font("Fira Code", { italic = true }),
  },
  {
    intensity = "Bold",
    font = wezterm.font("Fira Code", { weight = "Bold" }),
  },
}

-- List available fonts
-- Run: wezterm ls-fonts
```

### Colors & Color Schemes
```lua
-- Use a built-in scheme
config.color_scheme = "Dracula"

-- Or define custom colors
config.colors = {
  foreground = "#f8f8f2",
  background = "#282a36",
  -- cursor colors
  cursor_bg = "#f8f8f2",
  cursor_border = "#f8f8f2",
  cursor_fg = "#282a36",
  -- selection colors
  selection_bg = "#44475a",
  selection_fg = "#f8f8f2",
  -- ansi colors (16 total, indices 0-15)
  ansi = {
    "#282a36", "#ff5555", "#50fa7b", "#f1fa8c",
    "#bd93f9", "#ff79c6", "#8be9fd", "#bfbfbf",
    "#4d4d4d", "#ff6e67", "#5af78e", "#f4f99d",
    "#caa9fa", "#ff92d0", "#a4ebff", "#ffffff",
  },
}

-- List available schemes
-- Run: wezterm show-keys --lua
```

### Tab & Tab Bar
```lua
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false

config.tab_max_width = 16
config.use_fancy_tab_bar = true  -- Rounded corners on tabs
config.tab_and_split_indices_are_zero_based = false  -- 1-based indexing

-- Tab switching
config.switch_to_last_active_tab_when_closing_tab = true
```

### Pane & Split Styling
```lua
config.inactive_pane_hsb = {
  hue = 0.0,
  saturation = 1.0,
  brightness = 0.8,  -- Dim inactive panes
}

config.pane_focus_follows_mouse = false
```

## Key Binding Configuration

### Basic Binding Structure
```lua
local act = wezterm.action

config.keys = {
  {
    key = "n",
    mods = "LEADER",
    action = act.SpawnTab("CurrentDomain"),
  },
  {
    key = "x",
    mods = "LEADER",
    action = act.CloseCurrentPane { confirm = true },
  },
}
```

### Modifiers
Available modifiers (combine with `|`):
- `CTRL`, `SHIFT`, `ALT`, `META` (Windows key on Windows/Linux, Cmd on macOS)
- `LEADER` (custom prefix key)
- `NONE` (no modifier)

Example: `"CTRL|SHIFT"`, `"ALT|META"`

### Common Actions
```lua
-- Tab operations
act.SpawnTab("CurrentDomain")
act.SpawnTab("DefaultDomain")
act.CloseCurrentTab { confirm = true }
act.ActivateTabRelative(1)   -- Next tab
act.ActivateTabRelative(-1)  -- Previous tab
act.ActivateTab(0)           -- Activate tab 0 (1-based if setting is true)

-- Pane operations
act.SplitVertical { domain = "CurrentDomain" }
act.SplitHorizontal { domain = "CurrentDomain" }
act.CloseCurrentPane { confirm = true }
act.ActivatePaneDirection("Left" | "Right" | "Up" | "Down")
act.TogglePaneZoomState()

-- Copy/Paste
act.CopyTo("Clipboard")
act.PasteFrom("Clipboard")

-- Window operations
act.ToggleFullScreen()
act.Hide()
act.Quit()

-- Scrollback
act.ScrollByPage(1)   -- Scroll forward one page
act.ScrollByPage(-1)  -- Scroll back one page
act.ScrollByLine(1)   -- Scroll forward one line

-- Key sending
act.SendKey { key = "Enter" }
act.SendString("text to send")

-- Workspace operations
act.SwitchToWorkspace { name = "workspace_name", spawn_in_current_window = true }
act.ShowLauncherArgs { title = "Select an action", flags = "TABS|DOMAINS" }
```

### Leader Key Setup
```lua
config.leader = {
  key = "a",
  mods = "CTRL",
  timeout_milliseconds = 2000,
}

config.keys = {
  -- CTRL+A then N to create new tab
  {
    key = "n",
    mods = "LEADER",
    action = act.SpawnTab("CurrentDomain"),
  },
  -- CTRL+A then X to close current pane
  {
    key = "x",
    mods = "LEADER",
    action = act.CloseCurrentPane { confirm = true },
  },
  -- CTRL+A again to send CTRL+A to the pane
  {
    key = "a",
    mods = "LEADER",
    action = act.SendKey { key = "a", mods = "CTRL" },
  },
}
```

### Key Binding Patterns
```lua
local act = wezterm.action

config.keys = {
  -- Alt + number to jump to tab
  { key = "1", mods = "ALT", action = act.ActivateTab(0) },
  { key = "2", mods = "ALT", action = act.ActivateTab(1) },
  { key = "3", mods = "ALT", action = act.ActivateTab(2) },

  -- Alt + direction to move between panes
  { key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection("Down") },

  -- Ctrl+Shift for split/close
  { key = "v", mods = "CTRL|SHIFT", action = act.SplitVertical { domain = "CurrentDomain" } },
  { key = "h", mods = "CTRL|SHIFT", action = act.SplitHorizontal { domain = "CurrentDomain" } },
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane { confirm = false } },
}
```

### Special Keys
Reference for key names (used in `key = "..."` field):

- **Letters**: "a" through "z" (lowercase), "A" through "Z" (uppercase)
- **Numbers**: "0" through "9"
- **Function keys**: "F1" through "F24"
- **Control keys**: "Enter", "Escape", "Tab", "Backspace", "Delete"
- **Arrow keys**: "UpArrow", "DownArrow", "LeftArrow", "RightArrow"
- **Navigation**: "Home", "End", "PageUp", "PageDown"
- **Editing**: "Insert"
- **Special**: "Space"

## Domain Configuration (SSH & Remote Terminals)

### SSH Domain Setup
```lua
config.ssh_domains = {
  {
    name = "my-server",
    remote_address = "user@example.com",
    username = "user",
    -- Optional: specify SSH key
    ssh_option = {
      identityfile = os.getenv("HOME") .. "/.ssh/id_rsa",
    },
  },
}

config.default_domain = "DefaultDomain"  -- Local domain
```

### Dynamic Domain Configuration
```lua
-- Load SSH config from ~/.ssh/config
local function get_ssh_domains()
  local ssh_domains = {}
  -- Read and parse ~/.ssh/config
  -- Return table of domains
  return ssh_domains
end

-- Apply if implemented
-- config.ssh_domains = get_ssh_domains()
```

### Using Domains
- Open new tab in SSH domain: `act.SpawnTab("my-server")`
- Specify in split: `act.SplitVertical { domain = "my-server" }`
- List available domains: `wezterm ls-domains`

## Lua Scripting & Event Handlers

### Event Handler Pattern
```lua
-- Event fires on specific actions
wezterm.on("event_name", function(window, pane, ...)
  -- Handle event
end)

config = wezterm.config_builder()
-- ... rest of config
return config
```

### Common Event Handlers

**window-config-reloaded**: Config file was reloaded
```lua
wezterm.on("window-config-reloaded", function(window, pane)
  wezterm.log_info("Config reloaded!")
end)
```

**format-tab-title**: Customize tab title appearance
```lua
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local title = tab.active_pane.title
  if tab.is_active then
    return {
      { background = "#0b0022" },
      { foreground = "#eaeaea" },
      { text = " " .. title .. " " },
    }
  else
    return title
  end
end)
```

**update-right-status**: Customize status bar on right
```lua
wezterm.on("update-right-status", function(window, pane)
  local time = wezterm.strftime("%a %b %d %H:%M")
  window:set_right_status(time)
end)
```

**trigger**: Custom event triggered by key binding or command
```lua
wezterm.on("trigger", function(window, pane, args)
  -- Handle custom trigger
end)
```

### Logging & Debugging
```lua
-- Log messages (visible in debug overlay: CTRL+SHIFT+L)
wezterm.log_info("This is an info message")
wezterm.log_warn("This is a warning")
wezterm.log_error("This is an error")

-- These appear in stderr or log file
```

## Configuration Validation

### Check for Syntax Errors
```bash
# Show all key bindings (validates config syntax)
wezterm show-keys

# List available fonts
wezterm ls-fonts

# List available color schemes
wezterm show-keys --lua

# Manually reload config in active session
# Press CTRL+SHIFT+R
```

### Debug Overlay
- **Show**: `CTRL+SHIFT+L`
- Displays log messages, errors, and diagnostics
- Helpful for identifying Lua syntax issues

### Common Errors

**"attempt to index a nil value"**
- You're trying to access a field that doesn't exist
- Check spelling of config options
- Ensure you're using correct table structure

**"unexpected symbol"**
- Lua syntax error (missing comma, wrong bracket, etc.)
- Check balanced braces: `{`, `[`, `(`
- Ensure strings are quoted properly

**"unrecognized action"**
- Action name doesn't exist or is misspelled
- Verify action syntax in this document
- Check `wezterm show-keys` for available actions

## Module & Library Functions

### wezterm Module
```lua
-- Get wezterm module
local wezterm = require("wezterm")

-- Action builders
local act = wezterm.action

-- Utility functions
wezterm.font("Font Name")
wezterm.font_with_fallback({"Font 1", "Font 2"})
wezterm.format(table)  -- Format text with styling
wezterm.strftime(format_string)  -- Format current time

-- Environment
os.getenv("HOME")  -- Get environment variables
os.getenv("SHELL")

-- Logging
wezterm.log_info(message)
wezterm.log_warn(message)
wezterm.log_error(message)
```

### Config Builder
```lua
-- Create config with defaults
local config = wezterm.config_builder()

-- Set values
config.font_size = 12.0
config.font = wezterm.font("Monaco")

-- Return at end
return config
```

## Advanced Patterns

### Conditional Configuration Based on Hostname
```lua
local hostname = wezterm.hostname()

if hostname == "work-laptop" then
  config.font_size = 13.0
  config.color_scheme = "Dracula"
elseif hostname == "home-desktop" then
  config.font_size = 14.0
  config.color_scheme = "Catppuccin Mocha"
end
```

### Conditional Configuration Based on OS
```lua
if wezterm.target_triple:find("windows") then
  -- Windows-specific config
  config.default_domain = "WSL:Ubuntu"
elseif wezterm.target_triple:find("darwin") then
  -- macOS-specific config
  config.font = wezterm.font("Monaco")
else
  -- Linux
  config.font = wezterm.font("Fira Code")
end
```

### Dynamic Tab Title
```lua
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local title = pane.title

  if pane.current_working_dir then
    title = string.match(pane.current_working_dir, "([^/]+)$") or title
  end

  if tab.is_active then
    return { { background = "#3c3c7c", text = " " .. title .. " " } }
  end
  return title
end)
```

### Custom Keybinding with Lua Scripting
```lua
local act = wezterm.action

config.keys = {
  {
    key = "t",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      -- Custom logic here
      wezterm.log_info("Custom action triggered!")
      pane:send_text("echo 'Hello from WezTerm'\n")
    end),
  },
}
```

## Configuration File Structure Summary

```lua
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Window & appearance
config.window_decorations = "RESIZE"
config.font = wezterm.font("Fira Code")
config.font_size = 12.0
config.color_scheme = "Dracula"

-- Tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = true

-- Keybindings
config.leader = { key = "a", mods = "CTRL" }
config.keys = {
  { key = "n", mods = "LEADER", action = act.SpawnTab("CurrentDomain") },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane { confirm = true } },
}

-- Domains
config.ssh_domains = {}
config.default_domain = "DefaultDomain"

-- Event handlers
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  return tab.active_pane.title
end)

-- Return config
return config
```

## Troubleshooting

### Config Won't Reload
- Check syntax: Run `wezterm show-keys`
- Check debug overlay: `CTRL+SHIFT+L`
- Restart WezTerm completely if hot-reload fails

### Key Binding Not Working
- Verify modifier spelling (CTRL, SHIFT, ALT, META)
- Check key name is correct (case-sensitive)
- Ensure no conflicting system keybindings
- Reload config: `CTRL+SHIFT+R`

### Font Not Applying
- Verify font name with: `wezterm ls-fonts`
- Use exact font name as shown in output
- Some fonts may not support all weights/styles
- Fallback fonts: Use `wezterm.font_with_fallback()`

### Colors Not Showing Correctly
- Verify `TERM` variable in your shell: `echo $TERM`
- WezTerm sets `TERM=wezterm` by default
- Ensure your shell/app supports 24-bit color (truecolor)
- Check if color scheme name is valid: List available schemes in docs

### Performance Issues
- Reduce window_background_opacity animations
- Disable font anti-aliasing if CPU-bound
- Check for expensive event handlers
- Monitor with: `wezterm --help` and review startup flags

## Related Documentation

- **Official WezTerm Configuration**: https://wezfurlong.org/wezterm/config/index.html
- **Lua API Reference**: https://wezfurlong.org/wezterm/config/lua/index.html
- **Action Reference**: https://wezfurlong.org/wezterm/config/lua/wezterm/action/index.html
- **Color Schemes**: https://wezfurlong.org/wezterm/config/appearance.html
