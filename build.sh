#!/bin/sh

set -e

DIST=dist/UserVoiceSDK-3.2.12
HEADERS=build/UVHeaders

echo "==== Building for iOS devices ===="
echo ""
xcodebuild -target UserVoice -configuration Release -sdk iphoneos

echo "==== Building for iOS simulator ===="
echo ""
xcodebuild -target UserVoice -configuration Release -sdk iphonesimulator

rm -rf $DIST $HEADERS
mkdir -p $DIST $HEADERS/UserVoice

echo "Creating XCFramework"
cp Include/*.h UserVoiceSDK/UserVoiceSDK.h $HEADERS/UserVoice/
xcodebuild -create-xcframework \
    -library build/Release-iphoneos/libUserVoice.a -headers $HEADERS \
    -library build/Release-iphonesimulator/libUserVoice.a -headers $HEADERS \
    -output $DIST/UserVoice.xcframework

echo "Copying other files"
cp -R Resources $DIST/UVResources
cp README.md $DIST/README.md
cp CHANGELOG.md $DIST/CHANGELOG.md

echo "Creating archive"
tar -czf $DIST.tar.gz $DIST
rm -Rf $DIST

echo "Done! UserVoice iOS SDK built: $DIST.tar.gz"
