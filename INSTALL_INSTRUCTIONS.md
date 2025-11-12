# EFDBUI Installation Instructions

## Quick Install (Recommended)

Download and install locally:

```bash
# Download the cask file
curl -O https://raw.githubusercontent.com/sfc-gh-sramamoorthy/FDB_Control_Plane_UI/main/efdbui.rb

# Install using the local file
brew install --cask ./efdbui.rb

# Clean up
rm efdbui.rb
```

This will:
1. Install EFDBUI.app to /Applications/
2. Automatically install the `efdb` CLI tool

## Alternative: Manual Installation

```bash
# Download the release
wget https://github.com/sfc-gh-sramamoorthy/FDB_Control_Plane_UI/releases/download/v1.0.2/EFDBUI-1.0.2.tar.gz

# Extract and install
tar -xzf EFDBUI-1.0.2.tar.gz
cp -R EFDBUI.app /Applications/

# Install efdb CLI separately
brew install efdb
```

## Via S3 (Internal)

```bash
aws s3 cp s3://sramamoorthy-backup/EFDBUI/EFDBUI-1.0.2.tar.gz .
tar -xzf EFDBUI-1.0.2.tar.gz
cp -R EFDBUI.app /Applications/
brew install efdb
```

## To Uninstall

```bash
brew uninstall --cask efdbui
# Or manually:
rm -rf /Applications/EFDBUI.app
```

## Requirements
- macOS Ventura (13.0) or later
- Homebrew installed

## Features
- Multi-panel cluster management interface
- Real-time status monitoring
- Cluster events viewer
- Font size controls (Cmd +, Cmd -, Cmd 0)
- Various cluster management commands
