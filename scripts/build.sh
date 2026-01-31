#!/bin/bash
set -e

# Build script for BreakReminder
# Creates a distributable .zip file

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/dist"

echo "Building BreakReminder..."

cd "$PROJECT_DIR"

# Generate Xcode project if needed
if [ ! -d "BreakReminder.xcodeproj" ]; then
    echo "Generating Xcode project..."
    xcodegen generate
fi

# Build release version
xcodebuild -scheme BreakReminder \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    clean build

# Find the built app
APP_PATH="$BUILD_DIR/DerivedData/Build/Products/Release/BreakReminder.app"

if [ ! -d "$APP_PATH" ]; then
    echo "Error: Build failed - app not found"
    exit 1
fi

# Create dist folder
mkdir -p "$BUILD_DIR"

# Create zip
cd "$BUILD_DIR/DerivedData/Build/Products/Release"
zip -r "$BUILD_DIR/BreakReminder.zip" "BreakReminder.app"

echo ""
echo "Build complete!"
echo "Output: $BUILD_DIR/BreakReminder.zip"
