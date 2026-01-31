# BreakReminder

A simple macOS menu bar app that reminds you to:
- Drink water
- Rest your eyes
- Take a walk

## Install

### Quick Install (after release is published)

```bash
curl -fsSL https://raw.githubusercontent.com/AbhinavGupta-de/reminder/main/scripts/install.sh | bash
```

### Manual Install

1. Download `BreakReminder.zip` from [Releases](https://github.com/AbhinavGupta-de/reminder/releases)
2. Unzip and drag `BreakReminder.app` to `/Applications`
3. Right-click the app → Open (first time only, to bypass Gatekeeper)
4. Look for the clock icon in your menu bar

### Build from Source

Requires Xcode and [xcodegen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen
git clone https://github.com/AbhinavGupta-de/reminder.git
cd reminder
xcodegen generate
open BreakReminder.xcodeproj
# Press Cmd+R to build and run
```

## Features

- Configurable reminder intervals for each type
- Launch at Login option
- Persistent notifications until acknowledged
- Works in Focus Mode (Time Sensitive notifications)
