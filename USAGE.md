# EFDBUI Usage Guide

## Overview

EFDBUI is a macOS app that provides a graphical interface to view EFDB cluster information.

## Current Integration

### Command
The app executes: `efdb cluster info <cluster_name>`

### Inputs
1. **Deployment Name** (optional) - For display purposes only
2. **Cluster Name** (required) - Used in the efdb command

### How It Works

1. Enter a cluster name in the "Cluster Name" field
2. Optionally enter a deployment name for reference
3. Click "Refresh Now" to execute the command
4. The app runs: `efdb cluster info <cluster_name>`
5. Results are parsed and displayed in the right panel

## UI Components

### Left Panel - Input & Controls
```
┌─────────────────────────────┐
│ EFDB Configuration          │
│                             │
│ Deployment Name:            │
│ [e.g., production        ]  │
│                             │
│ Cluster Name:               │
│ [e.g., cluster-01        ]  │
│                             │
│ ────────────────────────    │
│                             │
│ Refresh Settings            │
│ Refresh Interval: [30]      │
│ Auto Refresh [⚪]            │
│                             │
│ ────────────────────────    │
│                             │
│ [ Refresh Now ]             │
│ [ Clear       ]             │
│                             │
│ ⏳ Loading...               │
│ Last update: 8:23 PM        │
└─────────────────────────────┘
```

### Right Panel - Cluster Information
- Displays parsed output from efdb command
- Shows key-value pairs from the output
- Scrollable when there's lots of data
- Shows error messages if command fails

## Features

### ✅ Implemented
- [x] Execute `efdb cluster info <cluster_name>` command
- [x] Input validation (alphanumeric, hyphens, underscores only)
- [x] Parse and display command output
- [x] Manual refresh on demand
- [x] Auto-refresh with configurable interval
- [x] Error handling and display
- [x] Loading indicators
- [x] Last update timestamp
- [x] Clear function to reset display

### Security Features
- Input validation using allow-list pattern
- Command executed with separate arguments (not shell string)
- Error details logged but not exposed in UI
- Safe async/await execution

## Usage Examples

### Example 1: Check a Specific Cluster
```
Deployment Name: production
Cluster Name: cluster-01
Click: Refresh Now
```

### Example 2: Monitor with Auto-Refresh
```
Cluster Name: cluster-01
Refresh Interval: 60 (seconds)
Toggle: Auto Refresh ON
```

### Example 3: Multiple Clusters
```
1. Enter cluster-01, click Refresh
2. View information
3. Enter cluster-02, click Refresh
4. Compare information
```

## Output Parsing

The app automatically parses efdb output:

1. **Key: Value format** - Lines with colons are parsed as key-value pairs
2. **Raw lines** - Lines without colons are shown as "Line N"
3. **Empty output** - Shown as "Raw Output" if no structure detected

Example efdb output:
```
Cluster ID: 12345
Status: Running
Region: us-west-2
Nodes: 5
```

Displayed as:
```
┌─────────────────────────────┐
│ Cluster ID                  │
│ 12345                       │
└─────────────────────────────┘
┌─────────────────────────────┐
│ Status                      │
│ Running                     │
└─────────────────────────────┘
```

## Error Handling

### Cluster Name Required
If no cluster name is entered:
```
Error: Cluster name is required
```

### Invalid Cluster Name Format
If cluster name contains invalid characters:
```
Error: Invalid cluster name format
Details: Only alphanumeric, hyphens, and underscores allowed
```

### Command Execution Failed
If efdb command fails:
```
Error: Failed to fetch cluster information
Details: <error message>
Cluster: <cluster_name>
```

## Tips

1. **Keep cluster names handy** - Save common cluster names for quick access
2. **Use auto-refresh for monitoring** - Set to 60-300 seconds for passive monitoring
3. **Check timestamps** - Verify when data was last updated
4. **Clear between checks** - Use Clear button to reset before checking new cluster
5. **Monitor Console.app** - Detailed errors are logged there for debugging

## Keyboard Shortcuts

- **Tab** - Navigate between input fields
- **Enter** - Focus next field (doesn't trigger refresh)
- **Cmd+Q** - Quit app

## Installation

### Current Development Version
```bash
cd /Users/sramamoorthy/EFDBUI
open .build/EFDBUI.app
```

### Install to Applications
```bash
cp -R .build/EFDBUI.app /Applications/
# Launch from Spotlight: Cmd+Space, type "EFDBUI"
```

### Uninstall
```bash
rm -rf /Applications/EFDBUI.app
```

## Troubleshooting

### "efdb: command not found"
The efdb CLI tool is not installed or not in PATH.

**Solution**: Install efdb CLI or ensure it's in your PATH:
```bash
which efdb
# Should show: /opt/homebrew/bin/efdb or similar
```

### "Failed to fetch cluster information"
The efdb command returned an error.

**Possible causes**:
- Invalid cluster name
- Cluster doesn't exist
- Authentication issues
- Network connectivity

**Solution**: 
- Run the command manually in Terminal to see full error:
  ```bash
  efdb cluster info <cluster_name>
  ```
- Check efdb authentication/configuration
- Verify cluster name is correct

### App won't launch
**Solution**: Run from Terminal to see errors:
```bash
/Applications/EFDBUI.app/Contents/MacOS/EFDBUI
```

### Data not refreshing
- Check if auto-refresh is enabled
- Verify refresh interval is reasonable (> 10 seconds)
- Check Console.app for errors
- Try manual refresh first

## Future Enhancements

Potential additions:
- [ ] Cluster name autocomplete/history
- [ ] Multiple cluster comparison view
- [ ] Export cluster info to file
- [ ] Filter/search in results
- [ ] Visual status indicators (color coding)
- [ ] Notification on status changes
- [ ] Cluster favorites/bookmarks
- [ ] Integration with other efdb commands

## Support

For issues or questions:
1. Check Console.app for detailed error logs
2. Run efdb commands manually to verify they work
3. Check the main README.md and documentation files

---

**App Version**: 1.0  
**efdb Command**: `efdb cluster info <cluster_name>`  
**Last Updated**: November 9, 2025

