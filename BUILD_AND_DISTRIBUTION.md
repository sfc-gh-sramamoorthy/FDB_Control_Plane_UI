# Build and Distribution Guide

Complete guide for building, testing, and distributing your EFDBUI macOS app.

## 📦 Quick Build Commands

```bash
# Navigate to project
cd /Users/sramamoorthy/EFDBUI

# Option 1: Use build script (recommended)
./build.sh

# Option 2: Direct Swift build
swift build -c release

# Option 3: Using Make
make build
```

## 🚀 Running the App

### From Terminal
```bash
# Run directly
.build/release/EFDBUI

# Or open the app bundle
open .build/EFDBUI.app
```

### Install to Applications
```bash
cp -R .build/EFDBUI.app /Applications/
# Then launch from Spotlight or Applications folder
```

## 🔨 Development Workflow

### Using Xcode (Recommended for Development)

1. **Create Xcode Project**
```bash
cd /Users/sramamoorthy/EFDBUI
open -a Xcode .
# File → New → Project → macOS → App
# Add the Swift files to the project
```

2. **Or use existing files directly in Xcode**
   - Open Xcode
   - File → Open → Select EFDBUI folder
   - Xcode will recognize the Swift files

3. **Build and Run in Xcode**
   - Press `Cmd+R` to build and run
   - Use Xcode's debugger and preview features

### Using Command Line

```bash
# Clean build
rm -rf .build/
./build.sh

# Quick rebuild
swift build -c release
```

## 📋 Project Structure

```
EFDBUI/
├── EFDBUIApp.swift              # Main app entry point
├── ContentView.swift             # UI components
│   ├── InputPanel               # Left panel
│   ├── DetailPanel              # Right panel
│   └── InfoCard                 # Info display component
├── ObjectViewModel.swift         # Business logic & state
├── Package.swift                 # Swift Package Manager config
├── Info.plist                    # App metadata
├── Makefile                      # Make targets
├── build.sh                      # Build script
├── create-release.sh             # Release packaging script
├── efdbui.rb                     # Homebrew formula template
├── README.md                     # Main documentation
├── QUICKSTART.md                 # Quick start guide
├── INTEGRATION_EXAMPLES.md       # Integration examples
└── .gitignore                    # Git ignore rules
```

## 🍺 Homebrew Distribution

### Step 1: Create Release Archive

```bash
# Create a release (will build and package)
./create-release.sh 1.0.0

# This creates: releases/EFDBUI-1.0.0.tar.gz
# And outputs the SHA256 hash
```

### Step 2: Host the Release

**Option A: GitHub Releases**
1. Create a GitHub repository for your project
2. Go to Releases → Create new release
3. Tag version: `v1.0.0`
4. Upload `releases/EFDBUI-1.0.0.tar.gz`
5. Publish release
6. Copy the download URL

**Option B: Self-hosted**
1. Upload to your web server
2. Ensure it's accessible via HTTPS
3. Note the full URL

### Step 3: Create Homebrew Tap

1. **Create a new GitHub repository named `homebrew-tap`**
   ```bash
   mkdir homebrew-tap
   cd homebrew-tap
   mkdir Casks
   ```

2. **Edit and add the formula**
   ```bash
   # Copy the efdbui.rb template
   cp /Users/sramamoorthy/EFDBUI/efdbui.rb Casks/efdbui.rb
   
   # Edit the file and update:
   # - Replace YOURUSERNAME with your GitHub username
   # - Update the url with your actual download URL
   # - Update the sha256 with the hash from create-release.sh
   ```

3. **Push to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Add EFDBUI formula"
   git remote add origin https://github.com/YOURUSERNAME/homebrew-tap.git
   git push -u origin main
   ```

### Step 4: Install via Homebrew

Users can now install your app:

```bash
# Add your tap
brew tap YOURUSERNAME/tap

# Install the app
brew install --cask efdbui

# The app is installed to /Applications/
```

### Step 5: Updating Your App

When you release a new version:

```bash
# 1. Create new release archive
./create-release.sh 1.1.0

# 2. Upload to GitHub releases with tag v1.1.0

# 3. Update Casks/efdbui.rb in homebrew-tap:
#    - Update version number
#    - Update url
#    - Update sha256
#    - Commit and push

# Users update with:
brew upgrade efdbui
```

## 🔐 Code Signing (Optional but Recommended)

For distribution, you should code sign your app:

### 1. Get a Developer Certificate
- Enroll in Apple Developer Program ($99/year)
- Create a Developer ID Application certificate

### 2. Sign the App
```bash
# After building
codesign --force --deep --sign "Developer ID Application: Your Name" \
  .build/EFDBUI.app

# Verify signing
codesign --verify --verbose .build/EFDBUI.app
```

### 3. Notarize (for macOS 10.15+)
```bash
# Create a ZIP
ditto -c -k --keepParent .build/EFDBUI.app EFDBUI.zip

# Submit for notarization
xcrun notarytool submit EFDBUI.zip \
  --apple-id "your@email.com" \
  --password "app-specific-password" \
  --team-id "TEAM_ID" \
  --wait

# Staple the notarization ticket
xcrun stapler staple .build/EFDBUI.app
```

## 📊 Testing Checklist

Before distribution, test:

- [ ] App launches successfully
- [ ] All input fields work
- [ ] Refresh button works
- [ ] Auto-refresh works
- [ ] Data displays correctly
- [ ] Error handling works
- [ ] App can be quit properly
- [ ] App works on different macOS versions
- [ ] Commands execute correctly
- [ ] UI is responsive

## 🐛 Troubleshooting Builds

### "Command not found: swift"
```bash
# Install Xcode Command Line Tools
xcode-select --install
```

### "Cannot find module 'SwiftUI'"
```bash
# Update to latest Swift
# Check version
swift --version
# Should be 5.9 or later
```

### "Permission denied"
```bash
# Make scripts executable
chmod +x build.sh create-release.sh
```

### Build succeeds but app won't launch
```bash
# Check for runtime errors
./build/release/EFDBUI
# Errors will be shown in terminal

# Or check Console.app for crash logs
```

## 🎨 Customization for Your Use Case

### 1. Update Bundle Identifier
Edit `Info.plist`:
```xml
<key>CFBundleIdentifier</key>
<string>com.yourcompany.yourapp</string>
```

### 2. Change App Name
- Rename files (EFDBUIApp.swift → YourAppApp.swift)
- Update Package.swift with new name
- Update all references

### 3. Modify UI
Edit `ContentView.swift`:
- Change colors, fonts, spacing
- Add/remove panels
- Customize layout

### 4. Add Business Logic
Edit `ObjectViewModel.swift`:
- Implement `runCommandsAndGetInfo()`
- Add your command execution logic
- See INTEGRATION_EXAMPLES.md for examples

## 📦 Creating a DMG Installer (Alternative to Homebrew)

```bash
# After building
hdiutil create -volname "EFDBUI" \
  -srcfolder .build/EFDBUI.app \
  -ov -format UDZO \
  EFDBUI-1.0.0.dmg

# This creates a DMG file users can download and open
```

## 🌐 Alternative Distribution Methods

### 1. Direct Download
- Build the app
- Code sign and notarize
- Upload .app.zip or .dmg to your website
- Users download and install manually

### 2. Mac App Store
- Requires Apple Developer account
- More complex review process
- Additional app store requirements
- Handled through Xcode

### 3. GitHub Releases
- Upload .app.zip to GitHub Releases
- Users download from Releases page
- Can combine with Homebrew formula

## 📝 Release Checklist

Before each release:

1. [ ] Update version in `Info.plist`
2. [ ] Update version in `efdbui.rb`
3. [ ] Test all functionality
4. [ ] Build release version
5. [ ] Code sign (if applicable)
6. [ ] Notarize (if applicable)
7. [ ] Create release archive
8. [ ] Upload to distribution platform
9. [ ] Update Homebrew formula
10. [ ] Test installation from Homebrew
11. [ ] Update documentation
12. [ ] Create release notes

## 🚀 CI/CD Automation (Optional)

Consider setting up GitHub Actions:

```yaml
# .github/workflows/build.yml
name: Build
on: [push, pull_request]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build
        run: swift build -c release
      - name: Test
        run: swift test
```

## 📞 Support and Maintenance

1. Monitor issues from users
2. Keep dependencies updated
3. Test on new macOS versions
4. Regular security updates
5. Performance improvements

---

For more information:
- See `README.md` for overview
- See `QUICKSTART.md` for quick start
- See `INTEGRATION_EXAMPLES.md` for integration examples

