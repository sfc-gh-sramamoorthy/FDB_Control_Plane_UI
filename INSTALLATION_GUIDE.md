# EFDBUI Installation & Usage Guide for Colleagues

## 🚀 Quick Install (Recommended)

### Option 1: Install via Homebrew Cask (Easiest)

```bash
# Add the tap (one time only)
brew tap sramamoorthy/efdbui https://github.com/sramamoorthy/EFDBUI.git

# Install EFDBUI
brew install --cask efdbui

# Launch the app
open /Applications/EFDBUI.app
```

### Option 2: Download Pre-built Release

1. Download the latest release from GitHub:
   ```bash
   # Download v1.0.5
   curl -L https://github.com/sramamoorthy/EFDBUI/releases/download/v1.0.5/EFDBUI-1.0.5.tar.gz -o EFDBUI-1.0.5.tar.gz
   
   # Extract
   tar -xzf EFDBUI-1.0.5.tar.gz
   
   # Move to Applications
   mv EFDBUI.app /Applications/
   
   # Launch
   open /Applications/EFDBUI.app
   ```

### Option 3: Build from Source

```bash
# Clone the repository
git clone https://github.com/sramamoorthy/EFDBUI.git
cd EFDBUI

# Build
swift build -c release

# Run
.build/release/EFDBUI
```

---

## 📋 Prerequisites

Before using EFDBUI, ensure you have:

1. **macOS 13.0+** (Ventura or later)
2. **`efdb` CLI tool** installed and configured
3. **Valid credentials** for your EFDB clusters

---

## 🎯 Features

### ✅ Current Features (v1.0.5)

- **Multi-pane Dashboard**: View cluster info, tasks, status, and events simultaneously
- **Auto-complete**: Smart cluster and deployment name suggestions
- **Command Actions**: Execute EFDB commands with guided prompts
- **Cross-pane Search**: Search across all panes with highlighting and navigation
- **Task Filtering**: Filter out background tasks (like DELETE_INSTANCE) in "Show All Tasks"
- **Keyboard Shortcuts**: Fast navigation and actions
- **Better Error Handling**: Reduced timeouts, proper process termination

### 🆕 What's New in v1.0.5

- ✨ **Task Filtering**: Filter out background tasks by type in "Show All Tasks" window
- ✨ **Custom Filters**: Add comma-separated task types to filter out
- 🐛 **Bug Fixes**: Improved JSON parsing for task data

---

## 🎮 How to Use

### 1. Launch the App

```bash
open /Applications/EFDBUI.app
```

### 2. Enter Cluster Information

- **Cluster Name**: Type the cluster name (e.g., `prod1fdb2`, `azurecentralusfdb1`)
  - Auto-complete will suggest matching clusters
- **Deployment Name**: Auto-filled when you select a cluster
  - Or type manually if needed

### 3. View Dashboard Data

Click any of these buttons to load data:

- **Refresh Cluster Info**: Shows cluster configuration and status
- **Show All Tasks**: Displays all running tasks
- **Get Status JSON**: Shows detailed cluster status in JSON format
- **Get Cluster Events**: Lists recent cluster events
- **Refresh All**: Loads all panes at once

### 4. Use Search Feature

1. Type your search term in the search box at the top
2. Press **Enter** to search across all panes
3. Press **Enter** again to jump to the next match
4. Matches are highlighted in orange

### 5. Filter Tasks (New!)

In the "Show All Tasks" panel:

1. Click the **Filter** button (🔽 icon)
2. Toggle **"Filter out DELETE_INSTANCE tasks"** to remove background tasks
3. Add custom task types to filter (comma-separated)
4. Click **Apply Filters**

### 6. Execute Commands

Click **Actions** dropdown to:

- **Get Instance Info**: Show details about a specific instance
- **Replace Instance**: Replace a failed instance
- **Mark Instance Unreachable**: Mark an instance as unreachable
- **Sanssh Include**: Include a machine in sanssh
- **Custom Command**: Run any custom `efdb` command

**Note**: Commands like "Replace Instance" now automatically use the deployment name from the main panel!

---

## ⌨️ Keyboard Shortcuts

- **⌘ + R**: Refresh all panes
- **⌘ + F**: Focus search box
- **⌘ + K**: Open Actions menu
- **⌘ + Q**: Quit app
- **Enter** (in search): Search or go to next match

---

## 🔧 Troubleshooting

### App Won't Launch

```bash
# Remove quarantine attribute (macOS security)
xattr -d com.apple.quarantine /Applications/EFDBUI.app
```

### Authentication Timeout

- The app now has a **30-second timeout** for authentication
- If it times out, check your `efdb` credentials:
  ```bash
  efdb account list
  ```

### App Freezes

- Force quit: `⌘ + Option + Esc` → Select EFDBUI → Force Quit
- Relaunch: `open /Applications/EFDBUI.app`

### Can't Type in Fields

- Click on the app window to ensure it has focus
- Try `⌘ + Tab` to switch to EFDBUI
- If issue persists, restart the app

### Search Not Working

- Make sure you press **Enter** after typing your search term
- Search only triggers on Enter (not as you type) for performance

### Task Filtering Not Working

- Ensure you click **Apply Filters** after selecting filter options
- The output format must be valid JSON from `efdb cluster show-all-tasks`
- Check that task types in custom filters match exactly (case-sensitive)

---

## 📊 Sample Workflow

### Example 1: Check Cluster Health

```
1. Enter cluster name: azurecentralusfdb1
2. Click "Refresh All"
3. Review "Cluster Info" for status
4. Search for "healthy" to find health status
```

### Example 2: Find and Replace Failed Instance

```
1. Enter cluster name: prod1fdb2
2. Click "Show All Tasks"
3. Click "Filter" → Toggle "Filter out DELETE_INSTANCE tasks"
4. Search for "FAILED" or "ERROR"
5. Click "Actions" → "Replace Instance"
6. Enter instance details
```

### Example 3: Monitor Running Tasks

```
1. Enter cluster name
2. Click "Show All Tasks"
3. Click "Filter" button
4. Add "DELETE_INSTANCE,BACKUP_TASK" to custom filters
5. Click "Apply Filters"
6. Review active tasks only
```

---

## 🆘 Getting Help

### Check Documentation

- **README.md**: Project overview
- **USAGE.md**: Detailed usage instructions
- **QUICKSTART.md**: Quick start guide
- **ACTION_BUTTONS_GUIDE.md**: Guide to all action buttons
- **RELEASE_NOTES.md**: Version history and changes

### Report Issues

If you encounter bugs or have feature requests:

1. Check existing issues: https://github.com/sramamoorthy/EFDBUI/issues
2. Create a new issue with:
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots (if applicable)
   - macOS version and EFDBUI version

---

## 📦 Version History

- **v1.0.5** (Current): Task filtering, improved UI
- **v1.0.4**: Timeout fixes, authentication improvements
- **v1.0.3**: Cross-pane search with highlighting
- **v1.0.2**: Command actions use deployment from main panel
- **v1.0.1**: UX improvements
- **v1.0.0**: Initial release

---

## 🔄 Updating EFDBUI

### If installed via Homebrew:

```bash
brew update
brew upgrade --cask efdbui
```

### If installed manually:

1. Download the latest release
2. Replace the old `/Applications/EFDBUI.app` with the new one
3. Relaunch the app

---

## 💡 Tips & Tricks

1. **Auto-complete is Smart**: Just type the cluster name, deployment auto-fills
2. **Search is Fast**: Press Enter once to search, again for next match
3. **Filters are Persistent**: Your filter settings stay until you change them
4. **Refresh is Efficient**: "Refresh All" loads all data in parallel
5. **Commands are Safer**: 30-second timeout prevents hanging on auth failures
6. **Task Filtering**: Use it to focus on important tasks, hide background noise

---

## 📞 Contact

For questions or support, contact:
- **Maintainer**: sramamoorthy
- **Repository**: https://github.com/sramamoorthy/EFDBUI

---

**Happy EFDB Managing! 🎉**

