#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation directories
INSTALL_DIR="$HOME/.local/share/study"
BIN_DIR="$HOME/.local/bin"
STATE_DIR="$HOME/.local/state/study"
LOG_DIR="$INSTALL_DIR/logs"

# Check if running from project directory
if [ ! -f "bin/study" ]; then
    echo -e "${RED}Error: install.sh must be run from the study-tracker directory${NC}"
    echo "Please cd into the study-tracker directory first"
    exit 1
fi

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Study Tracker Installation        ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo ""

# Check for existing installation
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠ Existing installation found${NC}"
    read -p "Do you want to upgrade/reinstall? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    
    # Backup existing logs
    if [ -d "$LOG_DIR" ] && [ -f "$LOG_DIR/log.csv" ]; then
        echo -e "${BLUE}→ Backing up existing logs...${NC}"
        BACKUP_FILE="$HOME/study-logs-backup-$(date +%Y%m%d-%H%M%S).csv"
        cp "$LOG_DIR/log.csv" "$BACKUP_FILE"
        echo -e "${GREEN}✓ Logs backed up to: $BACKUP_FILE${NC}"
    fi
fi

# Create directories
echo -e "${BLUE}→ Creating directories...${NC}"
mkdir -p "$INSTALL_DIR"/{bin,lib,config,logs}
mkdir -p "$BIN_DIR"
mkdir -p "$STATE_DIR"
echo -e "${GREEN}✓ Directories created${NC}"

# Copy files
echo -e "${BLUE}→ Installing files...${NC}"
cp bin/study "$INSTALL_DIR/bin/"
cp lib/helpers.sh "$INSTALL_DIR/lib/"
cp config/settings.conf "$INSTALL_DIR/config/"
cp config/notifications.conf "$INSTALL_DIR/config/"

# Make executable
chmod +x "$INSTALL_DIR/bin/study"
echo -e "${GREEN}✓ Files installed${NC}"

# Create symlink
echo -e "${BLUE}→ Creating symlink...${NC}"
ln -sf "$INSTALL_DIR/bin/study" "$BIN_DIR/study"
echo -e "${GREEN}✓ Symlink created at $BIN_DIR/study${NC}"

# Check if bin directory is in PATH
echo -e "${BLUE}→ Checking PATH configuration...${NC}"
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "${YELLOW}⚠ $BIN_DIR is not in your PATH${NC}"
    echo ""
    echo "To use 'study' command, add this line to your shell config:"
    echo -e "${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    echo ""
    
    # Detect shell
    SHELL_NAME=$(basename "$SHELL")
    SHELL_RC=""
    
    case "$SHELL_NAME" in
        bash)
            SHELL_RC="$HOME/.bashrc"
            ;;
        zsh)
            SHELL_RC="$HOME/.zshrc"
            ;;
        fish)
            SHELL_RC="$HOME/.config/fish/config.fish"
            ;;
    esac
    
    if [ -n "$SHELL_RC" ] && [ -f "$SHELL_RC" ]; then
        read -p "Add to $SHELL_RC automatically? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "" >> "$SHELL_RC"
            echo "# Added by Study Tracker installer" >> "$SHELL_RC"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
            echo -e "${GREEN}✓ Added to $SHELL_RC${NC}"
            echo -e "${YELLOW}→ Run: source $SHELL_RC${NC}"
        fi
    fi
else
    echo -e "${GREEN}✓ PATH is correctly configured${NC}"
fi

# Check dependencies
echo ""
echo -e "${BLUE}→ Checking dependencies...${NC}"

# Check bash version
BASH_VERSION_MAJOR="${BASH_VERSINFO[0]}"
if [ "$BASH_VERSION_MAJOR" -ge 4 ]; then
    echo -e "${GREEN}✓ Bash $BASH_VERSION (OK)${NC}"
else
    echo -e "${RED}✗ Bash version too old (need 4.0+, have $BASH_VERSION)${NC}"
fi

# Check notify-send
if command -v notify-send >/dev/null 2>&1; then
    echo -e "${GREEN}✓ notify-send found${NC}"
else
    echo -e "${YELLOW}⚠ notify-send not found (optional)${NC}"
    echo "  Install with: sudo apt install libnotify-bin (Debian/Ubuntu)"
    echo "               sudo pacman -S libnotify (Arch)"
    echo "               sudo dnf install libnotify (Fedora)"
fi

# Check dunst
if command -v dunstctl >/dev/null 2>&1; then
    echo -e "${GREEN}✓ dunstctl found (focus mode available)${NC}"
else
    echo -e "${YELLOW}⚠ dunstctl not found (optional)${NC}"
    echo "  Focus mode requires dunst notification daemon"
    echo "  Install with: sudo apt install dunst"
    echo "  Or disable in config: ENABLE_FOCUS_MODE=false"
fi

# Installation complete
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation Complete! 🎉            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Installation Directory:${NC} $INSTALL_DIR"
echo -e "${BLUE}Executable:${NC} $BIN_DIR/study"
echo -e "${BLUE}Logs:${NC} $LOG_DIR"
echo ""
echo -e "${YELLOW}Quick Start:${NC}"
echo -e "  ${GREEN}study start 'Mathematics' 1h30m${NC}  Start a session"
echo -e "  ${GREEN}study status${NC}                     Check progress"
echo -e "  ${GREEN}study stop${NC}                       Stop early"
echo -e "  ${GREEN}study stats${NC}                      View statistics"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo -e "  Edit: ${BLUE}$INSTALL_DIR/config/settings.conf${NC}"
echo ""

# Offer to run test
read -p "Would you like to run a test session (5 seconds)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ ":$PATH:" == *":$BIN_DIR:"* ]]; then
        study start "Installation Test" 5s
    else
        "$BIN_DIR/study" start "Installation Test" 5s
    fi
fi

echo ""
echo -e "${GREEN}Happy studying! 📚${NC}"
