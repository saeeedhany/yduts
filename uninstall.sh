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

echo -e "${RED}╔════════════════════════════════════════╗${NC}"
echo -e "${RED}║     Study Tracker Uninstallation      ║${NC}"
echo -e "${RED}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if installed
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Study Tracker is not installed.${NC}"
    exit 0
fi

# Show what will be removed
echo -e "${YELLOW}The following will be removed:${NC}"
echo "  • $INSTALL_DIR"
echo "  • $BIN_DIR/study"
echo "  • $STATE_DIR"
echo ""

# Check for logs
if [ -f "$LOG_DIR/log.csv" ]; then
    SESSION_COUNT=$(($(wc -l < "$LOG_DIR/log.csv") - 1))
    if [ "$SESSION_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}⚠ You have $SESSION_COUNT logged study sessions${NC}"
        echo ""
        read -p "Do you want to backup your logs before uninstalling? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            BACKUP_FILE="$HOME/study-logs-backup-$(date +%Y%m%d-%H%M%S).csv"
            cp "$LOG_DIR/log.csv" "$BACKUP_FILE"
            echo -e "${GREEN}✓ Logs backed up to: $BACKUP_FILE${NC}"
            echo ""
        fi
    fi
fi

# Confirm uninstallation
read -p "Are you sure you want to uninstall Study Tracker? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

# Stop any running sessions
if [ -f "$STATE_DIR/study.pid" ]; then
    PID=$(cat "$STATE_DIR/study.pid")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo -e "${BLUE}→ Stopping active study session...${NC}"
        kill "$PID" 2>/dev/null || true
        
        # Resume notifications if dunst
        if command -v dunstctl >/dev/null 2>&1; then
            dunstctl set-paused false 2>/dev/null || true
        fi
        
        echo -e "${GREEN}✓ Session stopped${NC}"
    fi
fi

# Remove files
echo -e "${BLUE}→ Removing installation directory...${NC}"
rm -rf "$INSTALL_DIR"
echo -e "${GREEN}✓ Removed $INSTALL_DIR${NC}"

echo -e "${BLUE}→ Removing symlink...${NC}"
rm -f "$BIN_DIR/study"
echo -e "${GREEN}✓ Removed $BIN_DIR/study${NC}"

echo -e "${BLUE}→ Removing state directory...${NC}"
rm -rf "$STATE_DIR"
echo -e "${GREEN}✓ Removed $STATE_DIR${NC}"

# Check for PATH modifications
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
    if grep -q "Added by Study Tracker installer" "$SHELL_RC" 2>/dev/null; then
        echo ""
        echo -e "${YELLOW}Note: PATH modification found in $SHELL_RC${NC}"
        echo "You may want to manually remove the line:"
        echo -e "${BLUE}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    fi
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Uninstallation Complete              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Study Tracker has been removed from your system.${NC}"
echo ""
echo "Thanks for using Study Tracker! 📚"
echo ""
