#!/bin/bash
set -e

# BreakReminder Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/reminder/main/scripts/install.sh | bash

APP_NAME="BreakReminder"
GITHUB_REPO="AbhinavGupta-de/reminder"

echo "Installing $APP_NAME..."

# Get latest release URL
DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep "browser_download_url.*zip" | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not find latest release"
    echo "Please download manually from: https://github.com/$GITHUB_REPO/releases"
    exit 1
fi

# Create temp directory
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# Download
echo "Downloading from $DOWNLOAD_URL..."
curl -L -o "$TMP_DIR/$APP_NAME.zip" "$DOWNLOAD_URL"

# Unzip
echo "Extracting..."
unzip -q "$TMP_DIR/$APP_NAME.zip" -d "$TMP_DIR"

# Remove old version if exists
if [ -d "/Applications/$APP_NAME.app" ]; then
    echo "Removing old version..."
    rm -rf "/Applications/$APP_NAME.app"
fi

# Move to Applications
echo "Installing to /Applications..."
mv "$TMP_DIR/$APP_NAME.app" "/Applications/"

# Remove quarantine attribute (bypass Gatekeeper for unsigned app)
xattr -d com.apple.quarantine "/Applications/$APP_NAME.app" 2>/dev/null || true

echo ""
echo "Installation complete!"
echo ""
echo "Starting $APP_NAME..."
open "/Applications/$APP_NAME.app"

echo ""
echo "Look for the clock icon in your menu bar."
echo "Open Settings to enable 'Launch at Login' for automatic startup."
