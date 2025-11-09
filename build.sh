#!/bin/bash

# Build script for EFDBUI macOS app

set -e

APP_NAME="EFDBUI"
BUILD_CONFIG="release"
BUILD_DIR=".build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"

echo "🚀 Building ${APP_NAME}..."
echo ""

# Clean previous builds
if [ -d "${BUILD_DIR}" ]; then
    echo "🧹 Cleaning previous build..."
    rm -rf "${BUILD_DIR}"
fi

# Build using Swift Package Manager
echo "📦 Compiling with Swift Package Manager..."
swift build -c ${BUILD_CONFIG}

# Create application bundle
echo "📱 Creating application bundle..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy executable
cp "${BUILD_DIR}/${BUILD_CONFIG}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"

# Copy Info.plist
cp Info.plist "${APP_BUNDLE}/Contents/"

# Make executable
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

echo ""
echo "✅ Build complete!"
echo "📍 Application bundle: ${APP_BUNDLE}"
echo ""
echo "To run: open ${APP_BUNDLE}"
echo "To install: cp -R ${APP_BUNDLE} /Applications/"

