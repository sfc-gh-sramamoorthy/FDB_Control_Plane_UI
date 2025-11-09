.PHONY: build clean run xcode install

APP_NAME = EFDBUI
BUNDLE_ID = com.efdb.ui
BUILD_DIR = .build
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app
INSTALL_DIR = /Applications

build:
	@echo "Building $(APP_NAME)..."
	@swift build -c release --arch arm64 --arch x86_64
	@echo "Build complete!"

xcode:
	@echo "Generating Xcode project..."
	@xcodebuild -project EFDBUI.xcodeproj -scheme EFDBUI -configuration Release clean build

app: build
	@echo "Creating application bundle..."
	@rm -rf $(APP_BUNDLE)
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@mkdir -p $(APP_BUNDLE)/Contents/Resources
	@cp Info.plist $(APP_BUNDLE)/Contents/
	@cp .build/release/EFDBUI $(APP_BUNDLE)/Contents/MacOS/
	@echo "Application bundle created at $(APP_BUNDLE)"

install: app
	@echo "Installing to $(INSTALL_DIR)..."
	@cp -R $(APP_BUNDLE) $(INSTALL_DIR)/
	@echo "Installation complete!"

run: build
	@echo "Running $(APP_NAME)..."
	@.build/release/EFDBUI

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf .build
	@rm -rf *.xcodeproj
	@echo "Clean complete!"

