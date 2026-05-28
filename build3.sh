#!/bin/bash
set -e

SDK=$(xcrun --sdk iphoneos --show-sdk-path)
echo "SDK: $SDK"

# Clean build directory
rm -rf build
mkdir -p build/MissionControl.app

echo "Compiling source files..."
clang -arch arm64 -miphoneos-version-min=14.0 -isysroot "$SDK" -fobjc-arc -c MissionControl/main.m -o build/main.o
clang -arch arm64 -miphoneos-version-min=14.0 -isysroot "$SDK" -fobjc-arc -c MissionControl/AppDelegate.m -o build/AppDelegate.o
clang -arch arm64 -miphoneos-version-min=14.0 -isysroot "$SDK" -fobjc-arc -c MissionControl/ViewController.m -o build/ViewController.o

echo "Linking..."
clang -arch arm64 -miphoneos-version-min=14.0 -isysroot "$SDK" -fobjc-arc \
    -framework UIKit -framework WebKit -framework Foundation -framework CoreGraphics \
    build/main.o build/AppDelegate.o build/ViewController.o -o build/MissionControl

echo "Packaging..."
cp build/MissionControl build/MissionControl.app/
cp MissionControl/Info.plist build/MissionControl.app/

# Copy icon PNGs into the app bundle (for home screen icon)
echo "Copying app icons..."
ICON_DIR=MissionControl/Assets.xcassets/AppIcon.appiconset
if [ -d "$ICON_DIR" ]; then
    # Copy all icon PNGs to the app bundle root (iOS finds them by filename)
    cp "$ICON_DIR"/AppIcon-60@2x.png build/MissionControl.app/AppIcon-60@2x.png
    cp "$ICON_DIR"/AppIcon-60@3x.png build/MissionControl.app/AppIcon-60@3x.png
    cp "$ICON_DIR"/AppIcon-40@2x.png build/MissionControl.app/AppIcon-40@2x.png
    cp "$ICON_DIR"/AppIcon-40@3x.png build/MissionControl.app/AppIcon-40@3x.png
    cp "$ICON_DIR"/AppIcon-29@2x.png build/MissionControl.app/AppIcon-29@2x.png
    cp "$ICON_DIR"/AppIcon-29@3x.png build/MissionControl.app/AppIcon-29@3x.png
    cp "$ICON_DIR"/AppIcon-20@2x.png build/MissionControl.app/AppIcon-20@2x.png
    cp "$ICON_DIR"/AppIcon-20@3x.png build/MissionControl.app/AppIcon-20@3x.png
    cp "$ICON_DIR"/AppIcon-1024.png build/MissionControl.app/AppIcon-1024.png
    echo "✅ Icons copied"
fi

# Try to compile asset catalog with actool (for Assets.car)
echo "Compiling asset catalog..."
ACTOOL_PATH=$(xcrun --find actool 2>/dev/null || true)
if [ -n "$ACTOOL_PATH" ]; then
    "$ACTOOL_PATH" \
        --compile build/MissionControl.app \
        --platform iphoneos \
        --minimum-deployment-target 14.0 \
        --target-device iphone \
        --app-icon AppIcon \
        --output-partial-info-plist build/assetcatalog_info.plist \
        MissionControl/Assets.xcassets 2>&1 || {
        echo "⚠️ actool failed - using icon PNGs directly instead"
    }
    
    if [ -f build/MissionControl.app/Assets.car ]; then
        echo "✅ Assets.car created successfully"
    else
        echo "⚠️ Assets.car not created - relying on icon PNGs in bundle"
    fi
else
    echo "⚠️ actool not found - relying on icon PNGs in bundle"
fi

# Create .ipa
mkdir -p build/Payload
cp -r build/MissionControl.app build/Payload/
cd build && zip -rq MissionControl.ipa Payload/ && cd ..

echo ""
echo "✅ DONE: $(pwd)/build/MissionControl.ipa"
echo "Transfer this .ipa to your iPhone and install with Filza"
