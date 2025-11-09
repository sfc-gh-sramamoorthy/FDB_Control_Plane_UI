# Quick Start Guide

## 🚀 Get Started in 3 Steps

### 1. Build the App

```bash
cd /Users/sramamoorthy/EFDBUI
./build.sh
```

### 2. Run the App

```bash
open .build/EFDBUI.app
```

### 3. Use the App

1. Enter values in "Input 1" and "Input 2"
2. Click "Refresh Now" to load data
3. Toggle "Auto Refresh" for periodic updates

---

## 🔧 Build Options

### Option A: Quick Build (Recommended)
```bash
./build.sh
```

### Option B: Using Make
```bash
make build    # Build only
make run      # Build and run
make app      # Create app bundle
make install  # Install to /Applications
```

### Option C: Direct Swift Command
```bash
swift build -c release
.build/release/EFDBUI
```

---

## 📱 Installing to Applications

```bash
# After building
cp -R .build/EFDBUI.app /Applications/

# Launch from Spotlight or Applications folder
```

---

## 🍺 Creating a Homebrew Formula

### 1. Build a Release

```bash
./create-release.sh 1.0.0
```

This creates `releases/EFDBUI-1.0.0.tar.gz` and shows you the SHA256.

### 2. Create a GitHub Release

1. Create a new release on GitHub
2. Upload the `.tar.gz` file
3. Note the download URL

### 3. Update Homebrew Formula

Edit `efdbui.rb`:
- Replace `YOURUSERNAME` with your GitHub username
- Update the `sha256` with the value from step 1
- Ensure the URL matches your GitHub release

### 4. Create a Homebrew Tap

```bash
# Create a new repository: homebrew-tap
# Add efdbui.rb to Casks/efdbui.rb
# Commit and push

# Users can then install with:
brew install --cask yourusername/tap/efdbui
```

---

## 🎨 Customizing the App

### Adding Command Execution

Edit `ObjectViewModel.swift` and modify the `runCommandsAndGetInfo()` method:

```swift
private func runCommandsAndGetInfo() async throws -> [String: String] {
    // Example: Run a shell command
    let output = try await executeShellCommand("your-command", args: [input1, input2])
    
    // Parse output and return as dictionary
    return [
        "Result": output,
        // Add more fields as needed
    ]
}
```

### Adding More Input Fields

1. Add to `ObjectViewModel.swift`:
```swift
@Published var input3: String = ""
```

2. Add to `InputPanel` in `ContentView.swift`:
```swift
VStack(alignment: .leading, spacing: 4) {
    Text("Input 3:")
        .font(.caption)
        .foregroundColor(.secondary)
    TextField("Enter value", text: $viewModel.input3)
        .textFieldStyle(.roundedBorder)
}
```

---

## 🐛 Troubleshooting

### Build Fails
- Ensure you have Xcode Command Line Tools installed:
  ```bash
  xcode-select --install
  ```
- Check Swift version:
  ```bash
  swift --version
  # Should be 5.9 or later
  ```

### App Doesn't Launch
- Check macOS version (needs 13.0+)
- Try running from terminal to see error messages:
  ```bash
  .build/release/EFDBUI
  ```

### Commands Not Working
- The default implementation returns sample data
- You need to implement actual command execution in `ObjectViewModel.swift`

---

## 📚 Next Steps

1. **Customize the UI**: Edit `ContentView.swift` to modify the layout
2. **Add Command Logic**: Update `ObjectViewModel.swift` with your actual commands
3. **Test Thoroughly**: Run with different inputs
4. **Create Release**: Use `create-release.sh` to package for distribution
5. **Set Up Homebrew**: Follow the Homebrew formula steps above

---

## 💡 Tips

- Use Cmd+R in Xcode for faster development iterations
- The app uses SwiftUI previews - restart Xcode if previews break
- Check Console.app for runtime logs and errors
- The refresh timer runs on the main thread - keep operations quick

---

## 📞 Architecture Overview

```
EFDBUI
├── EFDBUIApp.swift      # App entry point
├── ContentView.swift     # UI layout (split view)
│   ├── InputPanel       # Left panel with inputs
│   └── DetailPanel      # Right panel with info
├── ObjectViewModel.swift # Business logic
│   ├── Input management
│   ├── Command execution
│   └── Auto-refresh logic
└── Info.plist           # App metadata
```

Enjoy building with EFDBUI! 🎉

