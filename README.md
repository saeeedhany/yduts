# yduts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-4.0+-blue.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux-green.svg)](https://www.linux.org/)

A minimal, distraction-free command-line tool for focused study sessions on Linux.

## What It Does

Study Tracker helps you stay focused by:
- Setting timed study sessions with a single command
- Automatically pausing notifications during focus time (dunst/mako/swaync)
- Tracking your study time and progress
- Logging completed sessions for statistics

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

## Usage

```bash
# Start a study session
study start "Mathematics" 1h30m
study start "Reading" 45m

# Check progress
study status

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

## Features

- [x] **Focus Mode** - Auto-pause notifications during study sessions  
- [x] **Progress Tracking** - Real-time status with progress bar  
- [x] **Session Logging** - CSV logs for all completed sessions  
- [x] **Statistics** - View total time, completed sessions, and daily progress  
- [x] **Lightweight** - Pure Bash, minimal dependencies  

## Requirements

- Bash 4.0+
- `notify-send` (optional, for notifications)
- `dunst` or `mako` or `swaync` (optional, for focus mode)

## Configuration

Edit `~/.local/share/study/config/settings.conf` to:
- Enable/disable focus mode
- Change notification daemon commands
- Customize paths

## Roadmap

Planned features for future releases:

- [ ] **Pomodoro Mode** - Automated work/break cycles
- [ ] **Pause/Resume** - Pause sessions and resume later
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

## Uninstall

```bash
cd yduts
./uninstall.sh
```

Your logs will be backed up automatically before removal.

## License

MIT License - See LICENSE file for details

## Contributing

Contributions welcome! Feel free to open issues or submit pull requests.

---

**Happy studying!** 📚
