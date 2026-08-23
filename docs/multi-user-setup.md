# Multi-User Setup: i3 (you) + KDE Plasma (gf)

## Goal

- Two user accounts sharing one Arch Linux machine
- You boot straight into i3 (no greeter, no password)
- She logs into KDE Plasma when it's her turn
- One mouse click to switch between sessions — both stay running in background
- Clickable switch from both sides: Polybar on i3, panel widget on Plasma

## High-level architecture

```
Boot → LightDM → auto-login: vincentb/i3
                                        │
               ┌────────────────────────┤
               ▼                        ▼
         VT7: i3 (you)            VT8: KDE Plasma (gf)
         frozen while             frozen while
         she uses hers            you use yours
```

Both sessions run on separate **virtual terminals (VTs)**. Only one is visible at a time. The invisible session is frozen in memory — no GPU rendering, but apps stay open. Switch back and it resumes instantly.

---

## 1. Install packages

```bash
sudo pacman -S lightdm                            # display manager (already installed)
sudo pacman -S plasma-desktop                     # KDE Plasma (minimal)
sudo pacman -S polybar                            # bar for i3 (replaces i3bar)
```

`plasma-desktop` pulls in the DE without the 200+ extras that `plasma` group includes. Add KDE apps manually if she wants them (Dolphin, Konsole, Gwenview, etc.).

LightDM is already installed — you're just making sure it's present.

---

## 2. Create separate user account

```bash
sudo useradd -m -G wheel,audio,video,storage gfname
sudo passwd gfname
```

- `audio` → PipeWire/PulseAudio works
- `video` → GPU access in her session
- `storage` → mount USB drives without sudo
- `wheel` → sudo access (if needed)

---

## 3. Configure LightDM

### 3a. Auto-login

Create `/etc/lightdm/lightdm.conf.d/50-autologin.conf`:

```ini
[Seat:*]
autologin-user=vincentb
autologin-user-timeout=0
autologin-session=i3
```

Now the machine boots straight to your i3 desktop — no greeter, no password prompt.

### 3b. Make sure LightDM is enabled

```bash
sudo systemctl enable lightdm --now
```

**What this changes:** Your current boot process uses `startx` + `.xinitrc`. After this, LightDM manages X sessions. Your `.xinitrc` will no longer be sourced (steps 5a/5b handle the fallout).

---

## 4. Mark i3 as an available session

If i3 doesn't show up in LightDM's session list, create a desktop file:

`/usr/share/xsessions/i3.desktop` (should already exist from the `i3-wm` package — verify):

```ini
[Desktop Entry]
Name=i3
Comment=Improved tiling window manager
Exec=i3
Type=Application
```

Plasma's session file comes from the `plasma-desktop` package — it'll be auto-detected as `plasma.desktop`.

LightDM reads session files from `/usr/share/xsessions/` to populate the greeter's session menu (only relevant for manual login — auto-login bypasses the greeter).

---

## 5. Move .xinitrc commands to session-specific locations

Your current `.xinitrc` does audio setup and GPU configuration. LightDM bypasses `.xinitrc`, so those commands need to move somewhere LightDM-aware sessions will pick up.

### 5a. For i3 — add to your i3 config (`~/.config/i3/config`)

```ini
# Audio: force ALC897 to analog profile
exec_always --no-startup-id pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo+input:analog-stereo
exec_always --no-startup-id pw-metadata -n default 0 default.audio.sink "alsa_output.pci-0000_00_1f.3.analog-stereo"

# GPU: disable screen tearing
exec_always --no-startup-id nvidia-settings --assign CurrentMetaMode="DPY-4: 3840x2160 {ForceFullCompositionPipeline=On}"

# Monitor layout
exec_always --no-startup-id xrandr --output DP-2 --right-of DP-1
exec_always --no-startup-id xrandr --output HDMI-0 --same-as DP-1
```

These run only when i3 starts, so they won't affect her Plasma session.

### 5b. For Plasma — create autostart script

Create `~gfname/.config/plasma-workspace/env/10-audio-gpu-setup.sh`:

```bash
#!/bin/bash
pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo+input:analog-stereo
pw-metadata -n default 0 default.audio.sink "alsa_output.pci-0000_00_1f.3.analog-stereo"
nvidia-settings --assign CurrentMetaMode="DPY-4: 3840x2160 {ForceFullCompositionPipeline=On}"
```

Make it executable:

```bash
chmod +x ~gfname/.config/plasma-workspace/env/10-audio-gpu-setup.sh
```

KDE Plasma sources everything in `~/.config/plasma-workspace/env/` at session start.

**Monitor layout** in Plasma is set once via System Settings → Display and Monitor → arrange screens → Apply. It persists.

---

## 6. Polybar — one-click switch from i3

Replace your hidden i3bar with Polybar that:
- Stays hidden by default (floats above windows)
- Slides into view when you mouse to the top screen edge (macOS Dock behavior)
- Has one clickable button: **Switch User**

### 6a. Polybar config

Create `~/.config/polybar/config.ini`:

```ini
[bar/main]
; Float above windows — doesn't push content down
override-redirect = true
width = 100%
height = 28
offset-x = 0
offset-y = 0

; Semi-transparent Catppuccin Mocha background
background = #E61E1E2E
foreground = #CDD6F4

; Only the switch button
modules-left = switch_user
modules-center =
modules-right =

; Allow polybar-msg show/hide
enable-ipc = true

[module/switch_user]
type = custom/text
content =    Switch User
content-background = #45475A
content-foreground = #CDD6F4
click-left = ~/.config/i3/scripts/switch_user.sh

[font]
; Uses your existing Nerd Font from i3 config
default = size=12;2
```

### 6b. Switch user script

Create `~/.config/i3/scripts/switch_user.sh`:

```bash
#!/bin/bash
# Tell LightDM to show the greeter on a new VT
# This triggers fast user switching — both sessions stay alive
dm-tool switch-to-greeter
```

Make it executable:

```bash
chmod +x ~/.config/i3/scripts/switch_user.sh
```

### 6c. Hover-to-reveal script

Create `~/.config/i3/scripts/hover_bar.sh`:

```bash
#!/bin/bash
# Monitors mouse position near top edge
# Shows polybar on approach, hides after cursor leaves

# Let polybar start first
sleep 2

# Start hidden
polybar-msg cmd hide

while true; do
    eval $(xdotool getmouselocation --shell 2>/dev/null)

    if [ "$Y" -le 3 ] 2>/dev/null; then
        # Mouse at top edge — show bar
        polybar-msg cmd show 2>/dev/null
    else
        # Mouse away — debounce then hide (prevents flicker)
        polybar-msg cmd show 2>/dev/null
        if [ $? -eq 0 ]; then
            # Bar was hidden, now visible — debounce before re-hiding
            sleep 0.5
            eval $(xdotool getmouselocation --shell 2>/dev/null)
            if [ "$Y" -gt 3 ] 2>/dev/null; then
                polybar-msg cmd hide
            fi
        fi
    fi
    sleep 0.1
done
```

Make it executable:

```bash
chmod +x ~/.config/i3/scripts/hover_bar.sh
```

### 6d. Update i3 config

In `~/.config/i3/config`, **comment out or delete** the entire `bar { }` block (lines 196–208). Add:

```ini
# Polybar replaces i3bar
exec_always --no-startup-id polybar main &
exec_always --no-startup-id ~/.config/i3/scripts/hover_bar.sh &
```

Also add the `xdotool` dependency if you don't have it:

```bash
sudo pacman -S xdotool
```

Remove the old i3bar toggle since it's no longer relevant (or keep it — it won't do anything).

---

## 7. Add Switch User widget in Plasma

When your gf logs into Plasma for the first time:

1. Right-click the panel (taskbar) → **Edit Panel**
2. Click **Add Widgets** (the + button or "Add Widgets" in menu)
3. Search for **Switch User**
4. Drag it to the panel — she clicks this to switch back to you

That's it. No scripts needed on her side.

---

## 8. First boot

```bash
sudo systemctl enable lightdm --now
reboot
```

- Machine boots → LightDM auto-logs you into i3
- Test mouse hover at top edge → Polybar appears → click **Switch User**
- LightDM greeter appears on a new VT
- Log in as `gfname` with password → Plasma session starts
- Switch back from Plasma using the **Switch User** widget

---

## The workflow in practice

```
Boot ──► i3 (you) ──────────────────────────────────────────────┐
         │                                                       │
         │ Mouse to top edge → click "Switch User"               │
         │ LightDM greeter appears                               │
         │                                                       │
         └──► She logs in → Plasma starts (VT8)                 │
             Your i3 freezes in background (VT7)                │
             │                                                   │
             │ She clicks "Switch User" widget on taskbar        │
             │ LightDM greeter appears                           │
             │                                                   │
             └──► You log in → i3 resumes instantly             │
                 Her Plasma freezes in background (VT8)          │
                 │                                               │
                 └──► (repeat as needed)                         │
                                                                 │
Both sessions always running. No apps killed. No boot wait.      │
```

---

## Potential issues & caveats

### Polybar doesn't hide/show cleanly
The hover script uses polling, which isn't perfect. If the bar flickers or doesn't hide properly, adjust the sleep values or threshold (change `Y -le 3` to `Y -le 10` for a larger activation zone).

### NVIDIA + KWin
KWin (KDE's compositor) on X11 with NVIDIA should work out of the box. If she sees screen tearing:
- System Settings → Display and Monitor → Compositor
- Rendering backend: **OpenGL 3.1**
- Enable **VSync**

### picom conflict
Your i3 config has `exec_always picom`. This only runs in i3 — Plasma uses KWin instead, so picom won't conflict. No action needed.

### i3 or Plasma doesn't appear in LightDM's session list
Check that `.desktop` files exist:

```bash
ls /usr/share/xsessions/
# Should show: i3.desktop  plasma.desktop
```

If missing from the `i3-wm` or `plasma-desktop` packages, recreate them manually.

### `dm-tool switch-to-greeter` doesn't respond
Verify LightDM is running:

```bash
systemctl status lightdm
dm-tool list-seats
```

If `dm-tool` returns no seats, LightDM may not be started yet or the seat isn't active. A reboot usually fixes this.

### Password prompts break the "one click" feel
SDDM requires a password to log in each user. There's no way around this with separate user accounts (and you wouldn't want to skip it for security). The "one click" is:
- **Your side**: hover → click → done (she enters password)
- **Her side**: click widget → click your name → enter password

The password step is unavoidable, but you've still eliminated the startx/greeter-from-cold-boot friction.

---

## Verifying everything works

```bash
# Are both sessions alive?
loginctl list-sessions

# Which VT is active?
fgconsole

# Switch to a specific user's session directly
loginctl switch-user gfname
loginctl switch-user vincentb

# Does the fast user switch work?
dm-tool switch-to-greeter

# List LightDM seats
dm-tool list-seats
```

---

## Open questions / future tweaks

- [ ] **Catppuccin for Plasma** — KDE can be themed to match your current aesthetic. Look into `catppuccin/kde` on GitHub.
- [ ] **LightDM theme** — LightDM defaults to a generic greeter. Install `lightdm-gtk-greeter` and theme it, or use a Catppuccin theme.
- [ ] **Polybar polish** — The hover script works but uses polling. Could be replaced with an X11 event-based listener using `xlib` or `xinput` for lower CPU.
- [ ] **WirePlumber persistence** — The `pw-metadata` command in startup scripts is a fallback. A WirePlumber Lua rule (`~/.config/wireplumber/main.lua.d/`) would be more robust — see `docs/audio-setup.md` for details.
