# Homebrew Tap Setup Instructions

## Overview
To make EFDBUI installable via Homebrew, you need to create a Homebrew tap repository.

## Steps to Create Homebrew Tap

### 1. Create a New GitHub Repository
Create a new repository named: `homebrew-tap`
- Repository: `https://github.com/sfc-gh-sramamoorthy/homebrew-tap`
- Description: "Homebrew tap for EFDBUI and related tools"
- Public repository (required for Homebrew)

### 2. Set Up Repository Structure
```bash
# Clone your new tap repository
git clone https://github.com/sfc-gh-sramamoorthy/homebrew-tap.git
cd homebrew-tap

# Create Casks directory
mkdir -p Casks

# Copy the formula
cp /Users/sramamoorthy/EFDBUI/efdbui.rb Casks/efdbui.rb

# Create README
cat > README.md << 'EOF'
# Homebrew Tap for EFDBUI

## Installation

```bash
# Add the tap
brew tap sfc-gh-sramamoorthy/tap

# Install EFDBUI
brew install --cask efdbui
```

## Available Casks
- **efdbui** - FoundationDB Control Plane UI

## Manual Installation

If you prefer not to use Homebrew, download the latest release from:
https://github.com/sfc-gh-sramamoorthy/FDB_Control_Plane_UI/releases
EOF

# Commit and push
git add .
git commit -m "Initial tap setup with EFDBUI cask"
git push origin main
```

### 3. Users Can Now Install EFDBUI

Once your tap is published, users can install with:

```bash
# Add your tap
brew tap sfc-gh-sramamoorthy/tap

# Install EFDBUI
brew install --cask efdbui
```

Or in a single command:
```bash
brew install --cask sfc-gh-sramamoorthy/tap/efdbui
```

## Updating the Formula

When you release a new version:

1. Update `efdbui.rb` in your tap repository with new version and SHA256
2. Commit and push the changes
3. Users update with: `brew upgrade efdbui`

## Current Release

- **Version**: 1.0.3
- **SHA256**: `e4f69037da586025de85057442d3bcf7b9f4dec11dd5163e3ab35d522e02ebb9`
- **Download URL**: https://github.com/sfc-gh-sramamoorthy/FDB_Control_Plane_UI/releases/download/v1.0.3/EFDBUI-1.0.3.tar.gz

## Testing Your Tap Locally

Before publishing, test locally:

```bash
# Add your local tap for testing
brew tap sfc-gh-sramamoorthy/tap /path/to/homebrew-tap

# Try installing
brew install --cask efdbui

# Uninstall test
brew uninstall --cask efdbui
```

## Homebrew Cask Requirements

✅ Public GitHub repository
✅ Properly formatted cask formula
✅ Valid download URL pointing to GitHub release
✅ SHA256 checksum matches the archive
✅ App bundle is properly structured

All requirements are met for EFDBUI v1.0.3!

