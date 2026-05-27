#!/bin/bash
set -e

SDK=$(xcrun --sdk iphoneos --show-sdk-path)
echo "SDK: $SDK"

mkdir -p build/MissionControl.app

echo "Compiling..."
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
mkdir -p build/Payload
cp -r build/MissionControl.app build/Payload/
cd build && zip -rq MissionControl.ipa Payload/ && cd ..

echo ""
echo "✅ DONE: $(pwd)/build/MissionControl.ipa"
echo "Transfer this .ipa to your iPhone and install with Filza"