<div align="center">
  <img src="assets/yduts-logo.png" alt="yduts logo" width="280"/>
  
  <p><i>A minimal, distraction-free CLI study timer for Linux</i></p>
  
  [![License: MIT](https://img.shields.io/badge/License-MIT-F39C12.svg)](https://opensource.org/licenses/MIT)
  [![Bash](https://img.shields.io/badge/Bash-4.0+-2C3E50.svg)](https://www.gnu.org/software/bash/)
  [![Platform](https://img.shields.io/badge/Platform-Linux-2C3E50.svg)](https://www.linux.org/)
  
</div>

---

## What It Does

**yduts** (study backwards) helps you stay focused by managing timed study sessions directly from your terminal:

- Set timed study sessions with a single command
- Automatically pause notifications during focus time (dunst/mako/swaync)
- Track your study time and progress with a visual progress bar
- Live progress display in your status bar (dwmblocks, polybar, waybar)
- Interactive dmenu interface for quick access
- Log completed sessions for statistics and insights

Perfect for students, developers, and anyone who values focused work time.

---

## Installation

```bash
git clone https://github.com/saeeedhany/yduts.git
cd yduts
./install.sh
```

The installer will:
- Install to `~/.local/share/study`
- Create a symlink in `~/.local/bin/study`
- Guide you through PATH setup if needed

---

## Quick Start

### Basic Commands

```bash
# Start a study session
study start "Mathematics" 1h30m

# Pomodoro mode (work + automatic break)
study pomodoro "Physics" 25m 5m

# Pause and resume
study pause
study resume

# Check progress
study status

# Live watch mode (updates every second)
study watch

# Stop early
study stop

# View statistics
study stats
```

### Duration Formats
- `1h30m` - 1 hour 30 minutes
- `45m` - 45 minutes  
- `2h` - 2 hours
- `30m15s` - 30 minutes 15 seconds

---

## Features

- [x] **Focus Mode** - Auto-pause notifications during study sessions  
- [x] **Progress Tracking** - Real-time status with visual progress bar  
- [x] **Pause/Resume** - Pause sessions and continue later without losing progress
- [x] **Pomodoro Mode** - Automated work/break cycles with configurable durations
- [x] **dmenu Integration** - Quick access via dmenu for seamless WM integration
- [x] **Status Bar Integration** - Live progress bar in your status bar (updates every second)
- [x] **Live Watch Mode** - Terminal-based live session monitoring
- [x] **Session Logging** - CSV logs for all completed sessions  
- [x] **Statistics** - View total time, completed sessions, and daily progress  
- [x] **Lightweight** - Pure Bash, minimal dependencies

---

## Requirements

- Bash 4.0+
- `dmenu` (optional, for dmenu integration)
- `dwmblocks` or similar status bar (optional, for live progress bar)
- `notify-send` (optional, for notifications)
- `dunst` or `mako` or `swaync` (optional, for focus mode)

---

## Configuration

### Basic Settings

Edit `~/.local/share/study/config/settings.conf` to customize:

- Enable/disable focus mode
- Change notification daemon commands
- Adjust notification preferences
- Customize file paths

**Example configuration for different notification daemons:**

```bash
# For dunst (default)
FOCUS_CMD_PAUSE="dunstctl set-paused true"
FOCUS_CMD_RESUME="dunstctl set-paused false"

# For mako
FOCUS_CMD_PAUSE="makoctl set-mode dnd"
FOCUS_CMD_RESUME="makoctl set-mode default"

# For swaync
FOCUS_CMD_PAUSE="swaync-client -dn"
FOCUS_CMD_RESUME="swaync-client -en"
```

### dmenu Integration

Add keybindings to your window manager for quick access:

**i3wm / sway** (`~/.config/i3/config`):
```bash
bindsym $mod+y exec study dmenu
```

**bspwm / dwm** (add to `~/.config/sxhkd/sxhkdrc`):
```bash
super + y
    study dmenu
```

Then reload your WM config or restart sxhkd:
```bash
pkill -USR1 -x sxhkd
```

---

## Status Bar Integration (dwmblocks, polybar, waybar)

Show live progress in your status bar with updates every second!

### For dwmblocks (dwm users)

**Step 1:** Create the status script

```bash
mkdir -p ~/.local/share/dwmblocks
nano ~/.local/share/dwmblocks/study-status.sh
```

**Step 2:** Add this content:

```bash
#!/bin/bash

STATE_DIR="$HOME/.local/state/study"
PID_FILE="$STATE_DIR/study.pid"

# Check if session exists and is running
if [ ! -f "$PID_FILE" ]; then
    [ -f "$STATE_DIR/paused" ] && echo "⏸ $(cat "$STATE_DIR/topic" 2>/dev/null)" || exit 0
    exit 0
fi

if ! ps -p "$(cat "$PID_FILE" 2>/dev/null)" > /dev/null 2>&1; then
    [ -f "$STATE_DIR/paused" ] && echo "⏸ $(cat "$STATE_DIR/topic" 2>/dev/null)" || exit 0
    exit 0
fi

# Get session info
topic=$(cat "$STATE_DIR/topic" 2>/dev/null || echo "Study")
duration=$(cat "$STATE_DIR/duration" 2>/dev/null || echo "0")
start=$(cat "$STATE_DIR/start" 2>/dev/null || echo "0")
paused_time=$(cat "$STATE_DIR/paused_elapsed" 2>/dev/null || echo "0")

# Calculate progress
elapsed=$(($(date +%s) - start + paused_time))
remaining=$((duration - elapsed))
percentage=$((elapsed * 100 / duration))

# Create progress bar (10 characters)
bar_length=10
filled=$((percentage * bar_length / 100))
empty=$((bar_length - filled))
bar=$(printf "%${filled}s" | tr ' ' '█')
bar="${bar}$(printf "%${empty}s" | tr ' ' '░')"

# Format remaining time
minutes=$((remaining / 60))
hours=$((minutes / 60))
minutes=$((minutes % 60))

if [ "$hours" -gt 0 ]; then
    time_str="${hours}h${minutes}m"
elif [ "$minutes" -gt 0 ]; then
    time_str="${minutes}m"
else
    time_str="<1m"
fi

# Icon based on mode
if [ -f "$STATE_DIR/pomodoro_mode" ]; then
    pomo_type=$(cat "$STATE_DIR/pomodoro_type" 2>/dev/null || echo "work")
    [ "$pomo_type" = "work" ] && icon="🍅" || icon="☕"
else
    icon="📚"
fi

# Output: icon topic [progress] time
echo "$icon $topic [$bar] $time_str"
```

**Step 3:** Make it executable

```bash
chmod +x ~/.local/share/dwmblocks/study-status.sh
```

**Step 4:** Test it manually

```bash
# Start a session first
study start "Test" 1m

# Run the script
~/.local/share/dwmblocks/study-status.sh
# Should output: 📚 Test [░░░░░░░░░░] 1m
```

**Step 5:** Add to dwmblocks config

Edit your dwmblocks `config.h` (usually in `~/dwmblocks/` or `~/.local/src/dwmblocks/`):

```c
static const Block blocks[] = {
    /* Icon */  /* Command */                                                              /* Update Interval */  /* Signal */
    { "",       "/home/YOUR_USERNAME/.local/share/dwmblocks/study-status.sh",             1,                     0 },
    
    // ... your other blocks (date, time, volume, etc.) ...
};
```

**Important:** Replace `YOUR_USERNAME` with your actual username or use the full path from `realpath ~/.local/share/dwmblocks/study-status.sh`

**Step 6:** Recompile and restart

```bash
cd ~/dwmblocks  # or wherever your dwmblocks source is
sudo make clean install
pkill dwmblocks && dwmblocks &
```

**Result:** You'll see live progress in your status bar!

```
📚 Mathematics [█████░░░░░] 45m  |  14:30
```

### For polybar

Add to your polybar config (`~/.config/polybar/config.ini`):

```ini
[module/study]
type = custom/script
exec = ~/.local/share/dwmblocks/study-status.sh
interval = 1
```

### For waybar

Add to your waybar config (`~/.config/waybar/config`):

```json
"custom/study": {
    "exec": "~/.local/share/dwmblocks/study-status.sh",
    "interval": 1,
    "format": "{}"
}
```

### For i3blocks

Add to `~/.config/i3blocks/config`:

```ini
[study]
command=~/.local/share/dwmblocks/study-status.sh
interval=1
```

---

## Usage Examples

### Standard Study Session

```bash
# Start a 1.5 hour math session
study start "Mathematics" 1h30m

# Check progress anytime
study status

# Need a break? Pause it
study pause

# Resume when ready
study resume

# Or stop if done early
study stop
```

### Pomodoro Session

```bash
# Start pomodoro with default times (25min work, 5min break)
study pomodoro "Physics"

# Or customize the durations
study pomodoro "Coding" 50m 10m

# Work session runs (notifications paused)
# Break starts automatically
# Cycle completes!
```

### Using dmenu (Recommended Workflow)

1. Press `Super+Y` (your keybinding)
2. Select "▶ Start Session"
3. Type topic name
4. Select duration
5. Session starts!

**During session:**
- Press `Super+Y` again
- Quick actions menu appears:
  - ⏸ Pause
  - ⏹ Stop
  - ➕ Add 5min
  - ➖ Sub 5min

**Status bar shows live progress:**
```
📚 Mathematics [█████████░] 15m  |  [other blocks]
```

### Live Terminal Watch

```bash
# Open a terminal and watch live updates
study watch

# Updates every second
# Press Ctrl+C to exit (session continues)
```

---

## What You'll See

### Status Bar Display

**Active session:**
```
📚 Mathematics [█████████░] 15m
```

**Pomodoro work:**
```
🍅 Physics [████████░░] 18m
```

**Pomodoro break:**
```
☕ Break [███░░░░░░░] 3m
```

**Paused:**
```
⏸ Reading
```

### dmenu Interface

**When no session running:**
```
Study Tracker
─────────────────
▶ Start Session
🍅 Start Pomodoro
📊 Statistics
⚙ Quick Start
```

**When session active:**
```
Mathematics • 50% • 30m left
─────────────────────────────
⏸ Pause
⏹ Stop
📊 Full Status
➕ Add 5min
➖ Sub 5min
📈 Statistics
```

---

## Statistics & Tracking

View your study progress:

```bash
study stats
```

**Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Study Statistics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Total sessions: 15
  Total time:     12h 30m
  Completed:      12 sessions
  Today:          3 sessions, 2h 15m (2 completed)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Recent sessions:
  ✓ 2024-12-08 - Mathematics (1h30m)
  ✓ 2024-12-08 - Reading (45m)
  ✗ 2024-12-07 - Physics (30m)
```

**Logs are stored in:** `~/.local/share/study/logs/log.csv`

---

## Troubleshooting

### dmenu not working?

```bash
# Check if dmenu is installed
which dmenu

# Install if needed
sudo pacman -S dmenu     # Arch
sudo apt install dmenu    # Ubuntu/Debian
```

### Status bar not updating?

1. Check script works manually:
   ```bash
   ~/.local/share/dwmblocks/study-status.sh
   ```

2. Check dwmblocks is running:
   ```bash
   ps aux | grep dwmblocks
   ```

3. Verify path in config.h is absolute (no `~`)

4. Recompile dwmblocks:
   ```bash
   cd ~/dwmblocks
   sudo make clean install
   pkill dwmblocks && dwmblocks &
   ```

### Notifications not pausing?

Check your notification daemon in the config:
```bash
nano ~/.local/share/study/config/settings.conf
```

Make sure the commands match your daemon (dunst/mako/swaync).

---

## Uninstall

```bash
cd yduts
./uninstall.sh
```

Your logs will be backed up automatically before removal.

---

## Roadmap

Planned features for future releases:

- [ ] **Daily Goals** - Set and track daily study goals
- [ ] **Streaks** - Track consecutive study days
- [ ] **Topic Analytics** - Per-topic statistics and insights
- [ ] **Session Templates** - Save and reuse common study sessions
- [ ] **Break Reminders** - Notifications during long sessions
- [ ] **Session Notes** - Add notes after completing sessions
- [ ] **Tags** - Tag sessions for better organization
- [ ] **Export Reports** - JSON/Markdown export for logs
- [ ] **Interactive History** - Browse past sessions
- [ ] **Session Scheduling** - Schedule future study sessions

---

## Color Palette

The **yduts** brand uses:

- **Primary:** `#2C3E50` (Dark Navy) - Main brand color
- **Accent:** `#F39C12` (Amber Orange) - Active states and highlights
- **Text:** `#1A1A1A` (Near Black) - Body text
- **Background:** `#FFFFFF` (White) - Default background

---

## License

MIT License - See [LICENSE](LICENSE) file for details

---

## Contributing

Contributions are welcome! Feel free to:
- Report bugs or request features via [Issues](https://github.com/saeeedhany/yduts/issues)
- Submit pull requests
- Suggest improvements

---

<div align="center">
  <p><b>Happy studying!</b> ⏱️</p>
  <p><i>Made with focus by <a href="https://github.com/saeeedhany">saeeedhany</a></i></p>
</div>
