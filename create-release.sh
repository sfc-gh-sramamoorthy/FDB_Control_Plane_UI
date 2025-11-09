#!/bin/bash

# Script to create a release archive for Homebrew distribution

set -e

VERSION=${1:-"1.0.0"}
APP_NAME="EFDBUI"
BUILD_DIR=".build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
RELEASE_DIR="releases"
ARCHIVE_NAME="${APP_NAME}-${VERSION}.tar.gz"

echo "📦 Creating release archive for version ${VERSION}..."
echo ""

# Build the app first
./build.sh

# Create releases directory
mkdir -p "${RELEASE_DIR}"

# Create archive
echo "📚 Creating archive..."
cd "${BUILD_DIR}"
tar -czf "../${RELEASE_DIR}/${ARCHIVE_NAME}" "${APP_NAME}.app"
cd ..

# Calculate SHA256
echo "🔐 Calculating SHA256..."
SHA256=$(shasum -a 256 "${RELEASE_DIR}/${ARCHIVE_NAME}" | cut -d' ' -f1)

echo ""
echo "✅ Release created successfully!"
echo ""
echo "📍 Archive: ${RELEASE_DIR}/${ARCHIVE_NAME}"
echo "🔑 SHA256: ${SHA256}"
echo ""
echo "Next steps:"
echo "1. Upload ${RELEASE_DIR}/${ARCHIVE_NAME} to GitHub releases"
echo "2. Update efdbui.rb with the SHA256: ${SHA256}"
echo "3. Update the download URL in efdbui.rb"
echo "4. Commit the formula to your Homebrew tap repository"

