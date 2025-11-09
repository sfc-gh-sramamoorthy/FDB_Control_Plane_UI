# Action Buttons Guide

**Feature**: Cluster Action Commands  
**Version**: 1.3  
**Date**: November 9, 2025

---

## 🎯 Overview

The Action Buttons feature allows you to execute cluster management commands with:
- ✅ **Argument input dialogs** for commands requiring parameters
- ✅ **Confirmation dialogs** showing the exact command before execution
- ✅ **Result display** with success/error feedback
- ✅ **Automatic refresh** after successful execution
- ✅ **Command logging** to history file

---

## 📋 Currently Implemented Commands

### 1. **Exclude Machine** ⚠️ Destructive
- **Description**: Remove a machine from the cluster
- **Arguments**: Machine IP/ID (required)
- **Command Template**: `efdb cluster exclude <cluster> <machine>`
- **Example**: `efdb cluster exclude prod1fdb2 10.0.0.1`

### 2. **Include Machine**
- **Description**: Add a machine back to the cluster
- **Arguments**: Machine IP/ID (required)
- **Command Template**: `efdb cluster include <cluster> <machine>`
- **Example**: `efdb cluster include prod1fdb2 10.0.0.1`

### 3. **Stop Topology Change** ⚠️ Destructive
- **Description**: Prevent topology changes in the cluster
- **Arguments**: None
- **Command Template**: `efdb cluster stop-topology-change <cluster>`
- **Example**: `efdb cluster stop-topology-change prod1fdb2`

### 4. **Pause Cluster** ⚠️ Destructive
- **Description**: Pause cluster operations
- **Arguments**: Reason (optional)
- **Command Template**: `efdb cluster pause <cluster> [--reason "text"]`
- **Example**: `efdb cluster pause prod1fdb2 --reason "Maintenance"`

### 5. **Unpause Cluster**
- **Description**: Resume cluster operations
- **Arguments**: None
- **Command Template**: `efdb cluster unpause <cluster>`
- **Example**: `efdb cluster unpause prod1fdb2`

---

## 🎮 How to Use

### Basic Workflow

1. **Enter Cluster Name** in the left panel
2. **Click an Action Button** (e.g., "Exclude Machine")
3. **Enter Arguments** (if required) → Click "Continue"
4. **Review Command** in confirmation dialog → Click "Execute"
5. **View Results** → Command output or error message
6. **Data Refreshes** automatically after successful execution

### Destructive Actions ⚠️

Destructive actions show:
- Orange warning icon
- "Warning: This is a destructive operation" message
- Orange "Execute Anyway" button

---

## 🔧 Customizing Commands

You can easily modify the commands in **`CommandAction.swift`** to match your actual `efdb` CLI syntax.

### Location to Edit

Open `/Users/sramamoorthy/EFDBUI/CommandAction.swift`

Find the section:
```swift
// MARK: - Predefined Commands
```

### Example: Update Exclude Machine Command

**Current placeholder**:
```swift
static func excludeMachine(clusterName: String) -> CommandAction {
    CommandAction(
        name: "Exclude Machine",
        icon: "xmark.circle",
        description: "Remove a machine from the cluster",
        arguments: [
            ArgumentPrompt(
                key: "machine",
                label: "Machine IP/ID",
                placeholder: "10.0.0.1 or machine-id",
                isRequired: true,
                helpText: "The IP address or ID of the machine to exclude"
            )
        ],
        buildCommand: { args in
            guard let machine = args["machine"] else { return "" }
            return "efdb cluster exclude \(clusterName) \(machine)"  // ← UPDATE THIS
        },
        isDestructive: true
    )
}
```

**Update the command string** to match your actual CLI:
```swift
return "efdb cluster exclude-machine --cluster \(clusterName) --ip \(machine)"
```

### Example: Add a New Command

Add to the `allActions` array:

```swift
static func allActions(for clusterName: String) -> [CommandAction] {
    [
        excludeMachine(clusterName: clusterName),
        includeMachine(clusterName: clusterName),
        stopTopologyChange(clusterName: clusterName),
        pauseCluster(clusterName: clusterName),
        unpauseCluster(clusterName: clusterName),
        // ADD NEW COMMAND HERE:
        restartCluster(clusterName: clusterName)
    ]
}

// Define new command function:
static func restartCluster(clusterName: String) -> CommandAction {
    CommandAction(
        name: "Restart Cluster",
        icon: "arrow.clockwise.circle",
        description: "Restart the entire cluster",
        command: {
            "efdb cluster restart \(clusterName)"
        },
        isDestructive: true
    )
}
```

---

## 📝 Command Types

### Simple Command (No Arguments)

```swift
CommandAction(
    name: "Stop Topology Change",
    icon: "stop.circle",
    description: "Prevent topology changes",
    command: {
        "efdb cluster stop-topology-change \(clusterName)"
    },
    isDestructive: true
)
```

### Command with Required Arguments

```swift
CommandAction(
    name: "Exclude Machine",
    icon: "xmark.circle",
    description: "Remove a machine",
    arguments: [
        ArgumentPrompt(
            key: "machine",
            label: "Machine IP",
            placeholder: "10.0.0.1",
            isRequired: true,
            helpText: "IP address of machine"
        )
    ],
    buildCommand: { args in
        guard let machine = args["machine"] else { return "" }
        return "efdb cluster exclude \(clusterName) \(machine)"
    },
    isDestructive: true
)
```

### Command with Optional Arguments

```swift
CommandAction(
    name: "Pause Cluster",
    icon: "pause.circle",
    description: "Pause cluster operations",
    arguments: [
        ArgumentPrompt(
            key: "reason",
            label: "Reason (optional)",
            placeholder: "Maintenance",
            isRequired: false,  // ← OPTIONAL
            helpText: "Why you're pausing"
        )
    ],
    buildCommand: { args in
        let reason = args["reason"] ?? ""
        if reason.isEmpty {
            return "efdb cluster pause \(clusterName)"
        } else {
            return "efdb cluster pause \(clusterName) --reason \"\(reason)\""
        }
    },
    isDestructive: true
)
```

### Command with Multiple Arguments

```swift
ArgumentPrompt(
    key: "instance_type",
    label: "Instance Type",
    placeholder: "AWS_STORAGE_EBS",
    isRequired: true,
    helpText: "Type of instance to add"
),
ArgumentPrompt(
    key: "count",
    label: "Count",
    placeholder: "1",
    isRequired: true,
    helpText: "Number of instances"
)
```

---

## 🎨 Customization Options

### Button Icon

Change the `icon` parameter to any SF Symbol:
- `"xmark.circle"` - X mark
- `"checkmark.circle"` - Checkmark
- `"pause.circle"` - Pause
- `"play.circle"` - Play
- `"stop.circle"` - Stop
- `"arrow.clockwise"` - Refresh
- `"plus.circle"` - Add
- `"minus.circle"` - Remove

See all SF Symbols: https://developer.apple.com/sf-symbols/

### Destructive Flag

Set `isDestructive: true` for dangerous operations:
- Shows orange warning
- Uses orange button color
- Displays warning message

### Argument Validation

Arguments marked `isRequired: true` must be filled before continuing.

### Help Text

Add `helpText` to provide context for each argument field.

---

## 📊 Command Execution Flow

```
1. User clicks button
   ↓
2. [If arguments needed] → Show argument input dialog
   ↓
3. Build command string from arguments
   ↓
4. Show confirmation dialog with command
   ↓
5. User confirms → Execute command
   ↓
6. Show result dialog (success/error)
   ↓
7. [If successful] → Auto-refresh cluster data
   ↓
8. Log command to history file
```

---

## 🔍 Testing Commands

### Test Mode (Optional)

To test without executing, you can temporarily modify the executor:

In `ObjectViewModel.swift`, find `executeCommandAction`:

```swift
func executeCommandAction(_ commandString: String) async throws -> String {
    // TEST MODE: Just log and return success
    print("Would execute: \(commandString)")
    return "Test mode: Command would execute successfully"
    
    // PRODUCTION: Uncomment below
    // let components = commandString.split(separator: " ").map(String.init)
    // ... actual execution code ...
}
```

### Check Command History

All executed commands are logged to:
```
~/EFDBUI/command_history.log
```

View the log to verify commands are formatted correctly.

---

## 🚀 After Customizing

1. **Edit** `CommandAction.swift` with your actual commands
2. **Build**:
   ```bash
   cd /Users/sramamoorthy/EFDBUI
   swift build -c release
   ./build.sh
   ```
3. **Test**:
   - Launch app
   - Enter cluster name
   - Try each button
   - Verify command format in confirmation dialog
   - Check results

---

## 📋 Quick Reference

### Files Modified
- `CommandAction.swift` - Command definitions ← **EDIT THIS**
- `CommandDialogs.swift` - UI dialogs (no changes needed)
- `ContentView.swift` - Action buttons panel (no changes needed)
- `ObjectViewModel.swift` - Command executor (no changes needed)

### To Add New Command
1. Create function in `CommandAction.swift`
2. Add to `allActions` array
3. Rebuild app

### To Update Existing Command
1. Find function in `CommandAction.swift`
2. Update `buildCommand` closure
3. Rebuild app

---

## 🎯 Next Steps

**Please provide the actual `efdb` command formats for:**

1. **Exclude machine**: Current format vs actual format
2. **Include machine**: Current format vs actual format
3. **Stop topology change**: Current format vs actual format
4. **Pause cluster**: Current format vs actual format
5. **Unpause cluster**: Current format vs actual format

**Example format to provide:**
```
Command: Exclude Machine
Actual CLI: efdb cluster exclude-machine --cluster prod1fdb2 --ip 10.0.0.1
Additional flags: --force (optional)
```

Once you provide the actual formats, I'll update `CommandAction.swift` to match your CLI!

---

**Current Status**: ✅ **Action buttons framework ready, awaiting actual command formats**

