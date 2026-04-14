# Flux Pro Conky Theme

A minimalist, timeline-based Conky dashboard optimized for **WSLg** (Windows 11) and modern Linux desktop environments. Flux Pro features a sleek, high-precision aesthetic with a Dracula-inspired color palette, dual-font typography, real-time weather, and hardware monitoring.

## 🖼️ Previews

### Setup 1: Picturesque Landscape
![Picturesque Setup](assets/lofi.jpg)

### Setup 2: Retro Gaming
![Retro Setup](assets/retro.png)

### Setup 3: Pixel Art Nature
![Pixel Art Setup](assets/pokemon.png)

---

## ✨ Features

- **Dynamic Timeline Layout** — Vertical dot-and-bar design tracking system sections.
- **Glassmorphic Window** — Fully transparent, borderless overlay that sits below all windows.
- **Dracula Color Palette** — Yellow, pink, green, cyan, and purple accent colors.
- **Dual-Font Precision** — `Outfit` for headers, `Inter` for data, `Dosis` for timeline separators.
- **Real-time Weather** — OpenWeatherMap integration via `weather.sh` (PowerShell + curl fallback).
- **Hardware Stats** — CPU load, RAM usage (via PowerShell for WSL accuracy), NVIDIA GPU util & temp.
- **Session Uptime** — Live system uptime display.
- **Template-based Config** — `Flux.conf` is generated from `Flux.conf.template` at launch — no hardcoded paths.
- **Portable Startup** — `StartFluxPro.vbs` auto-detects the WSL username and project path.

---

## 📁 Project Structure

```
FluxPro/
├── Flux/
│   ├── Flux.conf.template      # Conky config template (placeholders substituted at launch)
│   ├── Flux.conf               # Auto-generated at runtime — do not edit (git-ignored)
│   ├── config.user             # Your personal settings (git-ignored)
│   ├── config.user.example     # Template for config.user — copy and edit this
│   ├── start_flux.sh           # Main launch script (builds Flux.conf, waits for display, starts Conky)
│   ├── fonts/
│   │   └── Dosis/              # Bundled Dosis font files
│   ├── res/                    # Sidebar accent images (sys.png, gpu.png, wth.png, foo.png)
│   └── scripts/
│       └── weather.sh          # Weather fetcher (OpenWeatherMap API)
├── assets/                     # README preview screenshots
├── install.sh                  # One-command installer (deps, fonts, config setup)
├── StartFluxPro.vbs            # Windows autostart script (fully portable, no edits needed)
├── LICENSE
└── README.md
```

---

## 🛠️ Prerequisites

- **WSL2** with a Linux distro (Ubuntu recommended) — or a native Linux desktop
- **Conky** (`conky-all` package)
- **Python 3** — for weather data parsing
- **curl** — weather API fallback
- **NVIDIA drivers** + `nvidia-smi` — for GPU monitoring (optional)
- **X display** — WSLg on Windows 11, or a native X11/Wayland session

---

## 🚀 Installation

### Option A — One-command install (recommended)

```bash
git clone https://github.com/your-username/FluxPro.git
cd FluxPro
bash install.sh
```

`install.sh` will:
1. Install `conky-all` via `apt`
2. Copy the bundled fonts to `~/.local/share/fonts/` and refresh the font cache
3. Copy `config.user.example` → `config.user` (only if it doesn't already exist)
4. Make `start_flux.sh` executable

### Option B — Manual install

```bash
# 1. Clone
git clone https://github.com/your-username/FluxPro.git
cd FluxPro

# 2. Install Conky
sudo apt install -y conky-all

# 3. Install fonts
mkdir -p ~/.local/share/fonts
cp Flux/fonts/Dosis/* ~/.local/share/fonts/
fc-cache -fv

# 4. Create your config
cp Flux/config.user.example Flux/config.user
```

---

## ⚙️ Configuration

Edit `Flux/config.user` before launching. The file is self-documented:

```bash
# Flux/config.user

# Your timezone — find yours with: timedatectl list-timezones
TIMEZONE="Asia/Kathmandu"

# Widget position: top_right | top_left | bottom_right | bottom_left
ALIGNMENT="top_right"

# Gap from screen edge in pixels (adjust for your resolution/scaling)
GAP_X=50
GAP_Y=70
```

> [!NOTE]
> `Flux/config.user` is git-ignored so your personal settings are never committed. The provided `config.user.example` tracks default values.

### Weather Configuration

Edit `Flux/config.user` and set your city and API key — **no need to touch `weather.sh`**:

```bash
# City query: "<CityName>,<2-letter country code>"
CITY_QUERY="Kathmandu,np"

# Get a free key at https://openweathermap.org/api
API_KEY="e46d6b1c945f2e9983f0735f8928ea2f" #Replace with your own API key
```

`weather.sh` automatically sources `config.user` at runtime, so this is the only file you need to edit.

---

## ▶️ Running

```bash
bash Flux/start_flux.sh
```

`start_flux.sh` will:
1. Read `Flux/config.user`
2. Substitute all `__PLACEHOLDER__` values in `Flux.conf.template` → generate `Flux.conf`
3. Wait up to 60 seconds for the X display to be ready
4. Kill any existing Conky instances
5. Launch Conky in the background and confirm it started (check `/tmp/fluxpro.log` on failure)

---

## 🪟 Auto-start on Boot (Windows / WSL2)

`StartFluxPro.vbs` in the repo root is a **fully portable** Windows Script that launches Flux Pro silently at login — no edits required.

### Setup

1. Press `Win + R`, type `shell:startup`, hit Enter — your Windows Startup folder opens.
2. Copy `StartFluxPro.vbs` from the repo root into that folder.
3. Done. The script auto-detects everything at runtime:

| What | How |
|---|---|
| WSL username | `wsl whoami` |
| Project path | `wsl wslpath` converts the script's own Windows location to a WSL path |

> [!NOTE]
> The script targets your **default WSL distro**. If you need a specific distro, open `StartFluxPro.vbs` and add `-d <DistroName>` to the `wsl.exe` call (e.g. `-d Ubuntu`).

---

## 🖥️ Compatibility Notes

| Environment | Notes |
|---|---|
| **WSLg / Windows 11** | Primary target. Uses `powershell.exe` for CPU/RAM stats and `wslpath` for path resolution. |
| **Native Linux** | Fully supported. Replace the `powershell.exe` `execi` blocks in `Flux.conf.template` with standard Conky variables (`${cpu}`, `${memperc}`, etc.). |
| **No NVIDIA GPU** | Remove or comment out the `GRAPHICS` section in `Flux.conf.template`. |

---

## 🐛 Troubleshooting

| Problem | Fix |
|---|---|
| Conky doesn't start | Run `bash Flux/start_flux.sh` manually and check the output |
| Conky crashes silently | Check `/tmp/fluxpro.log` for errors |
| `config.user not found` | Run `cp Flux/config.user.example Flux/config.user` |
| Fonts look wrong | Run `fc-cache -fv` and restart Conky |
| Weather shows `N/A` | Check `API_KEY` and `CITY_QUERY` in `Flux/config.user` |
| VBS script does nothing | Ensure WSL is installed and `wslpath` is available (`wsl wslpath .`) |

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

*Created with ❤️ by Anish*
