#!/bin/bash
# Build Mission Control iOS app using only Xcode Command Line Tools
# No full Xcode or Apple Developer account needed
# Produces an unsigned .ipa that works with AppSync Unified (jailbroken)

set -e

echo "=== Mission Control iOS Build ==="
echo ""

# Find SDK
SDK=$(xcrun --sdk iphoneos --show-sdk-path 2>/dev/null)
if [ -z "$SDK" ]; then
    echo "ERROR: iOS SDK not found. Install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
fi
echo "SDK: $SDK"

# Find clang
CLANG=$(xcrun --sdk iphoneos -f clang)
echo "Compiler: $CLANG"

# Create build dirs
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/MissionControl.app"
rm -rf "$BUILD_DIR"
mkdir -p "$APP_DIR"

# Architecture
ARCH="arm64"
MIN_IOS="14.0"

echo ""
echo "Compiling..."
cd MissionControl

# Compile each source file
for src in main.m AppDelegate.m ViewController.m; do
    echo "  $src"
    "$CLANG" \
        -arch "$ARCH" \
        -miphoneos-version-min="$MIN_IOS" \
        -isysroot "$SDK" \
        -fobjc-arc \
        -framework UIKit \
        -framework WebKit \
        -framework Foundation \
        -framework CoreGraphics \
        -c "$src" \
        -o "$BUILD_DIR/${src%.m}.o"
done

# Link
echo "  Linking..."
"$CLANG" \
    -arch "$ARCH" \
    -miphoneos-version-min="$MIN_IOS" \
    -isysroot "$SDK" \
    -fobjc-arc \
    -framework UIKit \
    -framework WebKit \
    -framework Foundation \
    -framework CoreGraphics \
    $BUILD_DIR/*.o \
    -o "$BUILD_DIR/MissionControl"

# Copy to .app bundle
echo "  Creating .app bundle..."
cp "$BUILD_DIR/MissionControl" "$APP_DIR/MissionControl"
cp Info.plist "$APP_DIR/"

# Create a simple AppIcon (just use a solid color, no custom icon needed)
echo "  Done with .app"

cd ..

# Create .ipa (just a zip with specific structure)
IPA_DIR="$BUILD_DIR/Payload"
mkdir -p "$IPA_DIR"
cp -r "$APP_DIR" "$IPA_DIR/"

echo ""
echo "Packaging .ipa..."
cd "$BUILD_DIR"
zip -rq MissionControl.ipa Payload/
cd ..

IPA_SIZE=$(du -h "$BUILD_DIR/MissionControl.ipa" | cut -f1)
echo ""
echo "=== BUILD SUCCESS ==="
echo "IPA: $(pwd)/build/MissionControl.ipa ($IPA_SIZE)"
echo ""
echo "To install on your jailbroken iPhone:"
echo "  1. Copy MissionControl.ipa to your iPhone (Filza can download from URL)"
echo "  2. Open in Filza → Install"
echo "  3. Make sure AppSync Unified is installed (Cydia)"