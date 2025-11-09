# EFDB UI

A minimal multi-panel macOS application built with SwiftUI for managing and displaying object information.

## Features

- **Multi-panel Interface**: Clean split view with input controls on the left and detailed information on the right
- **Flexible Inputs**: Currently supports 2 input fields, easily extensible for more
- **Auto-refresh**: Configurable automatic refresh with customizable interval
- **Manual Refresh**: On-demand data refresh capability
- **Native macOS UI**: Built with SwiftUI for a native look and feel

## Requirements

- macOS 13.0 (Ventura) or later
- Swift 5.9 or later
- Xcode 15.0 or later (for Xcode-based builds)

## Building the App

### Option 1: Command Line Build (Swift Package Manager)

```bash
cd /Users/sramamoorthy/EFDBUI

# Build the app
swift build -c release

# Run the app
.build/release/EFDBUI
```

### Option 2: Using Make

```bash
# Build the application
make build

# Run the application
make run

# Create application bundle
make app

# Install to /Applications
make install
```

### Option 3: Using Xcode

1. Generate an Xcode project:
```bash
cd /Users/sramamoorthy/EFDBUI
xcodegen generate  # if you have xcodegen installed
# OR
# Create a new macOS App project in Xcode and add the source files
```

2. Open in Xcode:
```bash
open EFDBUI.xcodeproj
```

3. Build and run using Xcode (Cmd+R)

## Creating an Xcode Project Manually

If you prefer to use Xcode:

1. Open Xcode
2. File → New → Project
3. Select "App" under macOS
4. Name it "EFDBUI"
5. Choose SwiftUI interface and Swift language
6. Save to `/Users/sramamoorthy/EFDBUI`
7. Replace the generated files with the provided source files

## Usage

1. **Enter Object Identifiers**: Input values in the two input fields
2. **Configure Refresh**: Set the refresh interval (in seconds)
3. **Enable Auto-Refresh**: Toggle the auto-refresh switch if you want periodic updates
4. **Manual Refresh**: Click "Refresh Now" to fetch data immediately
5. **View Information**: The right panel displays the object information

## Customization

### Modifying the Command Execution

The app currently returns sample data. To integrate with your actual commands:

1. Open `ObjectViewModel.swift`
2. Locate the `runCommandsAndGetInfo()` method
3. Replace the placeholder implementation with your actual command execution logic
4. Use the provided `executeShellCommand()` method as a template for running shell commands

### Adding More Input Fields

To add more input fields:

1. Add new `@Published` properties to `ObjectViewModel`
2. Add corresponding `TextField` components in `InputPanel`
3. Update the command execution logic to use the new inputs

### Changing the Refresh Interval

The default refresh interval is 30 seconds. Users can modify this in the UI, or you can change the default in `ObjectViewModel.swift`:

```swift
@Published var refreshInterval: Int = 30  // Change this value
```

## Distribution via Homebrew

To distribute this app via Homebrew:

1. **Create a release build and archive**:
```bash
make app
cd .build
tar -czf EFDBUI-1.0.tar.gz EFDBUI.app
```

2. **Host the archive** (e.g., on GitHub releases)

3. **Create a Homebrew formula** (`efdbui.rb`):
```ruby
class Efdbui < Formula
  desc "EFDB UI - Object information viewer"
  homepage "https://github.com/yourusername/efdbui"
  url "https://github.com/yourusername/efdbui/releases/download/v1.0/EFDBUI-1.0.tar.gz"
  sha256 "YOUR_SHA256_HERE"
  version "1.0"

  def install
    prefix.install "EFDBUI.app"
    bin.write_exec_script "#{prefix}/EFDBUI.app/Contents/MacOS/EFDBUI"
  end

  def caveats
    <<~EOS
      EFDBUI has been installed to:
        #{prefix}/EFDBUI.app
      
      You can also open it from Applications or run 'efdbui' from the terminal.
    EOS
  end
end
```

4. **Create a tap** or submit to homebrew-cask

## Architecture

- **EFDBUIApp.swift**: Main application entry point
- **ContentView.swift**: UI layout with multi-panel design
- **ObjectViewModel.swift**: Business logic and state management
- **Info.plist**: Application metadata
- **Package.swift**: Swift Package Manager configuration

## Security Notes

- Input validation is performed before command execution
- Shell commands use the secure `Process` API that separates commands from arguments
- No hardcoded credentials or sensitive data

## License

Copyright © 2025. All rights reserved.

