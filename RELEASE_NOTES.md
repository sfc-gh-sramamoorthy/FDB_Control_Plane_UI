# EFDB UI - Release Notes

**Version:** 1.2 (Stable with Command History)  
**Date:** November 9, 2025  
**Status:** ✅ Stable - Ready for GitHub

---

## 🎯 Overview

EFDB UI is a native macOS application for viewing and monitoring FoundationDB cluster information. It provides a clean, two-panel interface with powerful search capabilities and complete command history logging.

---

## ✨ Key Features

### Core Functionality
- ✅ **Dual Command Support**: `efdb cluster info` and `efdb cluster show-all-tasks`
- ✅ **Two-Panel Display**: Side-by-side view of cluster info and tasks
- ✅ **Auto-Refresh**: Configurable automatic data refresh
- ✅ **Unlimited Content**: NSTextView handles massive JSON outputs without truncation
- ✅ **Native Search**: Cmd+F with find bar for searching within JSON
- ✅ **Command History**: All commands logged with timestamps to ~/EFDBUI/command_history.log

### User Interface
- ✅ **Clean Design**: Modern macOS native UI
- ✅ **Resizable Panels**: Adjust panel sizes as needed
- ✅ **Loading Indicators**: Visual feedback during command execution
- ✅ **Status Display**: Last update time and loading state
- ✅ **Configurable Line Limits**: Optional output truncation (0 = unlimited)

### Technical Features
- ✅ **Login Shell Execution**: Proper auth token loading via `/bin/zsh -l -c`
- ✅ **Sequential Command Execution**: 10-second delay between commands to avoid auth conflicts
- ✅ **Timeout Protection**: 60-second timeout for hanging commands
- ✅ **Error Handling**: Graceful error messages with troubleshooting info
- ✅ **File-Based Redirection**: Avoids pipe deadlocks
- ✅ **Command Display**: Shows exact command executed above each output
- ✅ **Complete Logging**: Full command history with timestamps

---

## 📦 What's Included

### Source Files
```
EFDBUI/
├── EFDBUIApp.swift           # Main app entry with Edit menu
├── ContentView.swift          # UI layout (input + detail panels)
├── ObjectViewModel.swift      # Business logic & command execution
├── LargeTextView.swift        # NSTextView wrapper with find support
├── Package.swift              # Swift Package Manager config
├── Info.plist                 # macOS app metadata
└── .gitignore                 # Git ignore rules
```

### Documentation
```
├── README.md                  # Project overview
├── QUICKSTART.md              # Quick start guide
├── PROJECT_STATUS.md          # Complete project history
├── NSTEXTVIEW_FEATURES.md     # Search feature guide
├── UPGRADE_SUMMARY.txt        # Version 1.1 upgrade notes
├── RELEASE_NOTES.md           # This file
├── INTEGRATION_EXAMPLES.md    # Command integration examples
├── BUILD_AND_DISTRIBUTION.md  # Build instructions
├── UI_LAYOUT.md               # UI reference
├── AUTHENTICATION.md          # Authentication guide
└── USAGE.md                   # Usage instructions
```

### Build Scripts
```
├── Makefile                   # Build automation
├── build.sh                   # Build script
├── create-release.sh          # Release packaging
└── efdbui.rb                  # Homebrew formula template
```

---

## 🚀 Quick Start

### Build
```bash
cd /Users/sramamoorthy/EFDBUI
swift build -c release
./build.sh
```

### Run
```bash
open .build/EFDBUI.app
```

### First Time Setup
1. Authenticate with `efdb` CLI first: `efdb cluster info <cluster>`
2. Launch EFDBUI app
3. Enter cluster name
4. Click "Refresh All"

---

## 📊 Current Capabilities

### Inputs
- **Deployment Name**: Optional (currently for UI placeholder)
- **Cluster Name**: Required for both commands
- **Refresh Interval**: Auto-refresh period (default: 30s)
- **Max Lines**: Separate limits for cluster info and tasks (0 = unlimited)

### Outputs
- **Show All Tasks**: `efdb cluster show-all-tasks <cluster>`
  - Displays all tasks with configurable line limit
  - Searchable with Cmd+F
  - Full command shown at top
- **Cluster Info**: `efdb cluster info <cluster>`
  - Shows cluster details and instances
  - Searchable with Cmd+F
  - Full command shown at top

### History Log
- **Location**: `~/EFDBUI/command_history.log`
- **Format**: Timestamped entries with full command and output
- **Access**: Shown in left panel with "Show in Finder" button

---

## 🐛 Known Issues & Limitations

### Current Limitations
1. **No Code Signing**: Requires "Open Anyway" in macOS Security settings on first launch
2. **Authentication Required**: Must authenticate via `efdb` CLI before using app
3. **macOS Only**: Built specifically for macOS (not cross-platform)
4. **No Homebrew Distribution**: Formula template exists but not published

### Workarounds
- **Auth Tokens**: Run commands through login shell (`/bin/zsh -l -c`)
- **Pipe Deadlocks**: Use file-based redirection instead of pipes
- **Sequential Auth**: 10-second delay between commands prevents auth conflicts

---

## 📝 Version History

### v1.2 - Current (Nov 9, 2025)
- ✅ Added command display in output panels
- ✅ Implemented command history logging
- ✅ Added history log location display in UI
- ✅ Added "Show in Finder" button for log file

### v1.1 - NSTextView Integration
- ✅ Replaced SwiftUI TextEditor with NSTextView
- ✅ Added native Cmd+F search support
- ✅ Removed line limits (unlimited content)
- ✅ Added find bar for easy searching

### v1.0 - Initial Working Version
- ✅ Two-panel UI working
- ✅ Both efdb commands integrated
- ✅ Sequential execution with delay
- ✅ Login shell authentication
- ✅ Configurable line limits
- ✅ Auto-refresh functionality

---

## 🔧 Technical Details

### Architecture
- **Language**: Swift 5.9+
- **Framework**: SwiftUI for UI, AppKit for NSTextView
- **Build System**: Swift Package Manager
- **Minimum macOS**: 13.0 (Ventura)

### Key Technical Solutions
1. **Login Shell Execution**: `Process` runs commands via `/bin/zsh -l -c` to load auth tokens
2. **File Redirection**: Commands redirect to temp files to avoid pipe deadlocks
3. **Sequential Auth**: 10-second delay between commands prevents auth conflicts
4. **NSTextView**: Native component for unlimited content and search support
5. **Command Formatting**: Output includes command header for clarity
6. **Persistent Logging**: All commands logged to file with timestamps

### Performance
- **Build Time**: ~2-3 seconds (release mode)
- **App Size**: ~50KB executable (excluding frameworks)
- **Memory Usage**: Low (NSTextView is efficient)
- **Startup Time**: Instant
- **Command Execution**: 5-10 seconds (depends on cluster size)

---

## 📋 Backup History

Stable backups created during development:
- `EFDBUI_STABLE_WITH_CMD_HISTORY_20251109_123754` ← **Current stable**
- `EFDBUI_BEFORE_CMD_HISTORY_20251109_114815`
- `EFDBUI_BEFORE_NSTEXTVIEW_20251109_112427`
- `EFDBUI_WORKING_20251109_100639`
- `EFDBUI_backup_20251109_095712`

---

## 🎯 Future Enhancements (Ideas)

### Potential Features
- [ ] Multiple cluster monitoring (tabs or windows)
- [ ] Export data to JSON/CSV files
- [ ] Custom command support (user-defined efdb commands)
- [ ] Diff view (compare two snapshots)
- [ ] Alert notifications (when status changes)
- [ ] Dark mode support (system theme integration)
- [ ] Code signing for easier distribution
- [ ] Homebrew formula publication
- [ ] Syntax highlighting for JSON

### Nice-to-Have
- [ ] Save/load cluster configurations
- [ ] Quick filters (show only unhealthy, specific types, etc.)
- [ ] Collapsible JSON tree view
- [ ] Graph/chart visualizations
- [ ] Instance details drill-down

---

## 🤝 Contributing

When pushing to GitHub:
1. Ensure `.gitignore` is included
2. Don't include `.build/` directory
3. Don't include backup directories
4. Don't include `command_history.log`
5. Include all documentation files

### Repository Structure
```
.
├── .gitignore
├── README.md
├── QUICKSTART.md
├── RELEASE_NOTES.md
├── Package.swift
├── Info.plist
├── *.swift (source files)
├── *.md (documentation)
├── *.sh (build scripts)
├── Makefile
└── efdbui.rb
```

---

## 📞 Support

### Prerequisites
- macOS 13.0 or later
- Swift 5.9 or later
- `efdb` CLI tool installed and authenticated

### Common Issues
1. **"Application cannot be opened"**
   - Go to System Settings → Privacy & Security → "Open Anyway"

2. **Authentication errors**
   - Authenticate via CLI first: `efdb cluster info <cluster>`
   - Tokens loaded from login shell

3. **Cmd+F doesn't work**
   - Click in the text panel first to focus it
   - Try using Edit menu → Find → Find...

4. **Empty output**
   - Check command history log: `~/EFDBUI/command_history.log`
   - Verify cluster name is correct
   - Ensure efdb CLI works independently

---

## 📄 License

To be determined when publishing to GitHub.

---

## 🙏 Acknowledgments

Built with:
- SwiftUI for modern macOS UI
- AppKit's NSTextView for text handling
- Swift Package Manager for build system

---

**Status**: ✅ **Ready for GitHub Publication**

All features working, documented, and stable. Five complete backups created during development.

