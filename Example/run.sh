#!/bin/sh

# Builds the SDK framework and the example host app for the iOS simulator, then installs and
# launches the app. Arguments after the device are passed to the app as launch arguments.
#
# Usage: Example/run.sh [<simulator UDID> | booted] [launch arguments...]

set -e

cd "$(dirname "$0")/.."

DEVICE=${1:-booted}
[ $# -gt 0 ] && shift

# Build outside the repository, because code signing rejects folders that file sync services such as
# iCloud Drive tag with extended attributes.
BUILD=${TMPDIR:-/tmp}/UserVoiceExample
PRODUCTS=$BUILD/DerivedData/Build/Products/Debug-iphonesimulator
APP=$BUILD/UserVoiceExample.app
SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)

echo "==== Building SDK framework ===="
xcodebuild -project UserVoice.xcodeproj -scheme UserVoiceSDK -configuration Debug -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' -derivedDataPath "$BUILD/DerivedData" -quiet build

echo "==== Building example app ===="
rm -rf "$APP"
mkdir -p "$APP/Frameworks"
xcrun --sdk iphonesimulator clang -fobjc-arc -fmodules -target "$(uname -m)-apple-ios15.0-simulator" -isysroot "$SDK" \
    -F "$PRODUCTS" -framework UserVoice -Xlinker -rpath -Xlinker @executable_path/Frameworks \
    Example/main.m -o "$APP/UserVoiceExample"
cp Example/Info.plist "$APP/Info.plist"
cp -R "$PRODUCTS/UserVoice.framework" "$APP/Frameworks/"
codesign --force --sign - "$APP/Frameworks/UserVoice.framework"
codesign --force --sign - "$APP"

echo "==== Launching on $DEVICE ===="
xcrun simctl install "$DEVICE" "$APP"
xcrun simctl launch --terminate-running-process "$DEVICE" com.example.UserVoiceExample "$@"
