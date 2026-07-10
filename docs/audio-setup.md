# Audio Debugging Notes — Gigabyte B760 DS3H AX (ALC897)

## Hardware

- **Onboard:** Realtek ALC897 (Intel HDA PCH, card0)
- **GPU:** NVIDIA RTX 4060 HDMI audio (card1)
- **Connections:** Aux 3.5mm from back panel green Line Out jack to external audio setup
- **Session:** X11 + i3, PipeWire 1.6.7 via PulseAudio compat (`pactl`)
- **Default sink (problematic):** `alsa_output.pci-0000_01_00.1.hdmi-stereo` (NVIDIA → SAMSUNG monitor)

## Commands to Check Current State

```bash
# List sinks (outputs)
pactl list sinks short

# List sources (inputs)
pactl list sources short

# Show card details and available profiles
pactl list cards

# ALSA mixer state for the ALC897
amixer -c 0

# List ALSA playback devices
aplay -l

# PipeWire session info
pactl info
```

## Common Issues

### 1. Wrong Card Profile

The ALC897 can be stuck on `iec958-stereo` (S/PDIF / optical) instead of `analog-stereo`. The aux jack needs the analog profile.

**Check active profile:**
```bash
pactl list cards | grep -A2 "Card #" | grep -E "Name|Active Profile"
```

**Fix — switch to analog:**
```bash
pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo+input:analog-stereo
```

Available profiles for the ALC897 (card `alsa_card.pci-0000_00_1f.3`):
- `output:analog-stereo+input:analog-stereo` — Analog Stereo Duplex (recommended)
- `output:analog-stereo` — Analog Stereo Output only
- `output:iec958-stereo+input:analog-stereo` — S/PDIF + analog input (mutes analog output)
- `output:iec958-stereo` — S/PDIF only

### 2. Wrong Default Sink

NVIDIA HDMI may be set as default instead of the onboard analog output.

**Check default:**
```bash
pactl info | grep "Default Sink"
```

**Fix:**
```bash
pactl set-default-sink alsa_output.pci-0000_00_1f.3.analog-stereo
```

### 3. Analog Ports Show "Not Available" (Jack Detection)

Line Out or Headphone ports may report `available: no` even when a cable is plugged in. This can prevent the analog profile from working.

**Check port availability:**
```bash
pactl list cards | grep -A3 "analog-output"
```

**ALSA state to check** (via `amixer -c 0`):
- `Front` — must be unmuted (`[on]`) for Line Out to work
- `Headphone` — for front panel jack
- `Auto-Mute Mode` — should be `Disabled` for rear outputs to work when headphones are plugged in

If ports are incorrectly detected as unplugged:
- Use `hdajackretask` (from `alsa-tools`) to inspect and override jack detection pins
- Or pass kernel parameter: `snd-hda-intel.detect=0`
- Or toggle the profile twice to force a rescan

### 4. MPD Uses ALSA Directly

MPD config at `~/.config/mpd/mpd.conf` uses ALSA directly (bypassing PipeWire). If it doesn't output through the aux:

```
audio_output {
    type            "alsa"
    name            "ALSA sound card"
    device          "hw:0,0"    # ALC897 analog (force device)
}
```

ALSA hardware paths (from `aplay -l`):

| Path | Device |
|------|--------|
| `hw:0,0` | ALC897 Analog (aux) |
| `hw:0,1` | ALC897 Digital (S/PDIF) |
| `hw:1,3` | NVIDIA HDMI → SAMSUNG |
| `hw:1,7` | NVIDIA HDMI 2 |
| `hw:1,8` | NVIDIA HDMI 3 |
| `hw:1,9` | NVIDIA HDMI 4 |

## Persistence

Card profile and default sink are transient — they reset on reboot.

**Option A — `~/.xinitrc`** (runs once on X11 startup):
```bash
pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo+input:analog-stereo
pactl set-default-sink alsa_output.pci-0000_00_1f_3.analog-stereo
```

**Option B — i3 config** (runs on every i3 restart):
```
exec_always --no-startup-id pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo+input:analog-stereo
exec_always --no-startup-id pactl set-default-sink alsa_output.pci-0000_00_1f_3.analog-stereo
```

Note: When setting the default sink in `pactl`, dots in the sink name are sometimes replaced with underscores in config files (`pci-0000_00_1f.3` → `pci-0000_00_1f_3`). Use `pactl list sinks short` to confirm the exact name.

**Option C — WirePlumber** (if installed):
```
~/.config/wireplumber/main.lua.d/51-default-sink.lua
```
This requires a Lua rule — more robust but more code.

## System Info

- **Kernel:** 6.18.36-1-lts (Arch Linux)
- **PipeWire:** 1.6.7
- **Motherboard:** Gigabyte B760 DS3H AX
- **CPU:** Intel Raptor Lake (UHD Graphics 770 iGPU)
- **GPU:** NVIDIA RTX 4060
- **Codec:** Realtek ALC897 (HDA: `10ec0897,1458a194,00100402`)
