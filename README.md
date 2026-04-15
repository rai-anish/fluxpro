# Flux Pro `v1.0.0`

A polished Conky dashboard for WSLg and modern Linux desktops. Flux Pro combines a clean timeline layout, transparent desktop styling, live weather, and hardware monitoring in a portable package that can be installed, configured, and started with minimal setup.

## Preview

### Setup 1
![Flux Pro Preview 1](assets/lofi.jpg)

### Setup 2
![Flux Pro Preview 2](assets/retro.png)

### Setup 3
![Flux Pro Preview 3](assets/pokemon.png)

## Features

- Portable WSL-friendly launcher with `StartFluxPro.vbs`
- Template-based Conky config generation
- Automatic WSLg-safe startup fallback for `override` windows
- OpenWeather integration with PowerShell and `curl` fallback
- Real-time Battery monitoring (Percentage & Charging/DC status)
- Network Connectivity tracking (WiFi SSID & Live Download Speed)
- CPU and memory monitoring tuned for WSL accuracy via PowerShell bridge
- NVIDIA GPU utilization and temperature support
- Bundled font installation
- User configuration kept separate from tracked files

## Project Structure

```text
FluxPro/
├── Flux/
│   ├── Flux.conf.template
│   ├── Flux.conf
│   ├── config.user
│   ├── config.user.example
│   ├── start_flux.sh
│   ├── fonts/
│   ├── res/
│   └── scripts/
│       └── weather.sh
├── assets/
├── install.sh
├── StartFluxPro.vbs
├── LICENSE
├── README.md
└── .gitignore
```

## Requirements

### Windows / WSL setup

- Windows 11 with WSL2
- WSLg-enabled Linux distro
- Ubuntu recommended
- Internet connection for package install and weather data

### Linux packages

install.sh installs these automatically:

- conky-all
- python3
- curl
- x11-utils

### Optional

- NVIDIA drivers and nvidia-smi for GPU stats
- OpenWeather API key for live weather
- **Laptop Battery:** Requires a battery-enabled device (won't show data on Desktops).

## Installation

### Recommended

```bash
git clone https://github.com/Rai-Anish/FluxPro.git
cd FluxPro
bash install.sh
```

The installer will:

- Install required packages
- Install bundled fonts
- Create Flux/config.user from Flux/config.user.example if missing
- Set executable permissions for launcher scripts

## Configuration

Edit Flux/config.user before first use.

Example:

```
TIMEZONE="Asia/Kathmandu"
ALIGNMENT="top_right"
GAP_X=50
GAP_Y=70

WINDOW_TYPE="override"
STARTUP_MODE="auto"

CITY_QUERY="Kathmandu,np"
API_KEY="your_openweathermap_api_key_here"
```

### Config options

- TIMEZONE: your system timezone
- ALIGNMENT: top_right, top_left, bottom_right, or bottom_left
- GAP_X, GAP_Y: spacing from the screen edge
- WINDOW_TYPE: final Conky window mode
- STARTUP_MODE: auto or direct
- CITY_QUERY: OpenWeather city query
- API_KEY: your OpenWeather API key

...
### Config options
- TIMEZONE: your system timezone
- ... (rest of your list)

## Performance Tuning
Flux Pro uses a "PowerShell Bridge" to pull hardware data (CPU, Battery, Network) from Windows into WSL. To balance responsiveness with CPU efficiency, the following logic is used:

- **The Clock:** Updates every `1` second for real-time accuracy.
- **Hardware Stats:** Use `execi` intervals (5–20 seconds). This prevents the "process spawning" of `powershell.exe` from lagging your system.
- **Weather:** Updates every `600` seconds to stay within free API rate limits.

> **Tip:** If you are on a lower-end laptop and notice Conky "flickering," open `Flux/Flux.conf.template` and change `update_interval` from `1` to `2`.


## Window Startup Behavior

Flux Pro supports two startup modes:

- STARTUP_MODE="auto"  
  Recommended. Starts once in normal mode, then switches to your final WINDOW_TYPE. This improves reliability on WSLg where override windows may be invisible on first login.

- STARTUP_MODE="direct"  
  Starts directly in the configured WINDOW_TYPE.

For most WSLg users, keep:

```
WINDOW_TYPE="override"
STARTUP_MODE="auto"
```

## Running Flux Pro

Start Flux Pro manually with:

```bash
bash Flux/start_flux.sh
```

The launcher will:

- Read Flux/config.user
- Generate Flux/Flux.conf from the template
- Wait for the display server to become ready
- Stop any older Conky process
- Start Flux Pro and write logs to /tmp/fluxpro.log

## Startup Methods

Flux Pro supports two Windows startup methods.

### Method 1: Startup Folder (simpler but less reliable)

This is the simplest option.

Press ```Win + R```
Run ```shell:startup```  
Copy StartFluxPro.vbs into the Startup folder

At login, Windows will run the VBS file, which:
- resolves its own folder path
- converts that path to WSL format
- detects your default WSL username
- launches Flux/start_flux.sh silently

#### Important Note on WSLg Latency
The Startup folder method can be less reliable because Windows often executes these scripts before the WSLg display server is fully initialized. 

If Flux Pro does not appear after login:
- **Increase the Sleep Timer:** Edit `StartFluxPro.vbs` and increase the `WScript.Sleep` value.
  ```vbs
  WScript.Sleep 45000  ' Increase to 45 or 60 seconds

### Method 2: Task Scheduler (reccomended)

Use this if you want more control over timing and privileges.

Press ```Win + R```  
Run ```taskschd.msc```  
Click Create Task

#### General tab

Name: Flux Pro  
Description: Start Flux Pro on login  
Select Run only when user is logged on  
Enable Run with highest privileges

#### Triggers tab

Create a new trigger with:

- Begin the task: At log on
- Specific user: your Windows account
- Delay task for: 30 seconds or 1 minute
- Enabled: checked

#### Actions tab

Create a new action with:

- Action: Start a program
- Program/script: wscript.exe
- Add arguments: full Windows path to StartFluxPro.vbs

Example:

```
"C:\Users\<YourUserName>\Documents\FluxPro\StartFluxPro.vbs"
```

#### Important note

Do not point Task Scheduler directly to a \\wsl.localhost\... UNC path if you can avoid it. It is more reliable to keep the repository in a normal Windows-accessible folder and reference the local Windows path to StartFluxPro.vbs.

## WSLg Notes

Flux Pro is optimized for WSLg.

On some systems, Conky with own_window_type = 'override' may start invisibly immediately after login even though the process is running. Flux Pro works around this by supporting:

```
WINDOW_TYPE="override"
STARTUP_MODE="auto"
```

That warm-up sequence makes startup more reliable without forcing users to permanently use normal mode.

## Logs and Debugging

Flux Pro writes logs here:

```
/tmp/fluxpro.log
```

If startup from Windows is failing, also check:

```
/tmp/fluxpro-launch.log
```

Useful commands:

```bash
bash Flux/start_flux.sh
cat /tmp/fluxpro.log
```

## Troubleshooting

### Flux Pro says it started but nothing is visible

This is usually a WSLg window-mapping issue. Set:

```
WINDOW_TYPE="override"
STARTUP_MODE="auto"
```

If needed, temporarily test with:

```
WINDOW_TYPE="normal"
STARTUP_MODE="direct"
```

### Weather shows N/A

Check:

- API_KEY
- CITY_QUERY
- internet connectivity

### Fonts look incorrect

Rebuild the font cache:

```bash
fc-cache -fv
```

Then restart Flux Pro.

### GPU section fails

If your system does not have nvidia-smi, remove or comment out the GPU block in Flux/Flux.conf.template.

### config.user not found

Run:

```bash
cp Flux/config.user.example Flux/config.user
```

### Startup script does nothing

Check that:

- WSL is installed
- your default distro works
- wsl whoami succeeds from Windows
- StartFluxPro.vbs is being called with a normal Windows file path

### WiFi/Battery shows N/A or stays blank
- **Adapter Name:** The script looks for a Windows adapter named `'Wi-Fi'`. If your adapter is named "Wireless Network Connection", rename it in Windows Network Settings or update the string in the template.
- **Desktop Users:** Battery status will naturally be empty on desktop PCs.
- **PowerShell Execution:** Ensure your Windows user has permission to run basic PowerShell commands (standard on most systems).

## Security Note

Do not commit your personal Flux/config.user. It may contain your API key and local preferences. The repository is set up to ignore it by default.

## License

Released under the MIT License.

## Author

Created by Anish.
