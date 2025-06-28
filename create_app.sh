#!/bin/bash

# Script to create MirageDock.app bundle
set -e

APP_NAME="MirageDock"
BUILD_DIR=".build/arm64-apple-macosx/release"
APP_DIR="$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Creating $APP_NAME.app bundle..."

# Remove existing app bundle if it exists
if [ -d "$APP_DIR" ]; then
    echo "Removing existing $APP_DIR..."
    rm -rf "$APP_DIR"
fi

# Create app bundle structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy the executable
echo "Copying executable..."
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"

# Make sure the executable is executable
chmod +x "$MACOS_DIR/$APP_NAME"

# Handle app icon
if [ -f "logo.icns" ]; then
    echo "Copying custom icon..."
    cp "logo.icns" "$RESOURCES_DIR/AppIcon.icns"
    echo "Custom icon added successfully!"
elif [ -f "icon.png" ]; then
    echo "Converting icon.png to icns..."
    # Create iconset directory
    ICONSET_DIR="$APP_NAME.iconset"
    mkdir -p "$ICONSET_DIR"
    
    # Generate different icon sizes (using sips - built into macOS)
    sips -z 16 16 icon.png --out "$ICONSET_DIR/icon_16x16.png" > /dev/null 2>&1
    sips -z 32 32 icon.png --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null 2>&1
    sips -z 32 32 icon.png --out "$ICONSET_DIR/icon_32x32.png" > /dev/null 2>&1
    sips -z 64 64 icon.png --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null 2>&1
    sips -z 128 128 icon.png --out "$ICONSET_DIR/icon_128x128.png" > /dev/null 2>&1
    sips -z 256 256 icon.png --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null 2>&1
    sips -z 256 256 icon.png --out "$ICONSET_DIR/icon_256x256.png" > /dev/null 2>&1
    sips -z 512 512 icon.png --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null 2>&1
    sips -z 512 512 icon.png --out "$ICONSET_DIR/icon_512x512.png" > /dev/null 2>&1
    sips -z 1024 1024 icon.png --out "$ICONSET_DIR/icon_512x512@2x.png" > /dev/null 2>&1
    
    # Convert to icns
    iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
    
    # Clean up
    rm -rf "$ICONSET_DIR"
    
    echo "Icon converted and added successfully!"
else
    echo "Warning: No icon file found (logo.icns or icon.png) - app will use default icon"
fi

# Create Info.plist
echo "Creating Info.plist..."
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.mirage.dock</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>MirageDock</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSMainStoryboardFile</key>
    <string>Main</string>
    <key>LSUIElement</key>
    <false/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
EOF

# Create PkgInfo
echo "Creating PkgInfo..."
echo -n "APPL????" > "$CONTENTS_DIR/PkgInfo"

# Copy entitlements file
if [ -f "MirageDock.entitlements" ]; then
    echo "Copying entitlements..."
    cp "MirageDock.entitlements" "$RESOURCES_DIR/"
fi

echo ""
echo "✅ Successfully created $APP_DIR!"
echo ""
echo "You can now:"
echo "1. Double-click $APP_DIR to launch the app"
echo "2. Copy it to /Applications to install it system-wide"
echo "3. The app will appear in Launchpad automatically"
echo "" 