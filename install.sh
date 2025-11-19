#!/bin/bash
#
# EFDBUI Installer Script
# One-command installation for EFDBUI
#
# Usage: curl -fsSL https://raw.githubusercontent.com/sfc-gh-sramamoorthy/FDB_Control_Plane_UI/main/install.sh | bash
#

set -e

VERSION="1.0.7"
REPO="sfc-gh-sramamoorthy/FDB_Control_Plane_UI"
TARBALL="EFDBUI-${VERSION}.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/v${VERSION}/${TARBALL}"
INSTALL_DIR="/Applications"

echo "============================================"
echo "EFDBUI Installer v${VERSION}"
echo "============================================"
echo ""

# Check macOS version
if [[ "$(uname)" != "Darwin" ]]; then
    echo "ERROR: This installer is for macOS only"
    exit 1
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf '${TEMP_DIR}'" EXIT

cd "${TEMP_DIR}"

echo "📦 Downloading EFDBUI v${VERSION}..."
if curl -fsSL "${DOWNLOAD_URL}" -o "${TARBALL}"; then
    echo "✅ Download complete"
else
    echo "❌ Download failed. The release might not be available yet."
    echo ""
    echo "Please contact the maintainer or download manually from:"
    echo "  ${DOWNLOAD_URL}"
    exit 1
fi

echo ""
echo "📂 Extracting..."
tar -xzf "${TARBALL}"

if [[ ! -d "EFDBUI.app" ]]; then
    echo "❌ ERROR: EFDBUI.app not found in tarball"
    exit 1
fi

echo ""
echo "📥 Installing to ${INSTALL_DIR}..."

# Remove old version if exists
if [[ -d "${INSTALL_DIR}/EFDBUI.app" ]]; then
    echo "   Removing old version..."
    rm -rf "${INSTALL_DIR}/EFDBUI.app"
fi

# Copy to Applications
cp -R EFDBUI.app "${INSTALL_DIR}/"

# Remove quarantine flag
echo "🔓 Removing quarantine flag..."
xattr -d com.apple.quarantine "${INSTALL_DIR}/EFDBUI.app" 2>/dev/null || true

echo ""
echo "============================================"
echo "✅ Installation complete!"
echo "============================================"
echo ""
echo "To launch EFDBUI:"
echo "  open /Applications/EFDBUI.app"
echo ""
echo "Or use Spotlight: Press ⌘+Space and type 'EFDBUI'"
echo ""

