#!/bin/sh


SCRIPT_DIR=`dirname "$0"` 
ROOT_DIR="$SCRIPT_DIR/../.."
SOURCES_DIR="$ROOT_DIR/src"
XCODE_PROJECT="$SOURCES_DIR/handlebars-objc.xcodeproj"

BINARY_DISTRIBUTION_DIR="$ROOT_DIR/binaries"

for i in ios osx; do 
  rm -rf "$BINARY_DISTRIBUTION_DIR/$i"
  mkdir -p "$BINARY_DISTRIBUTION_DIR/$i"
done

##############################################################
# Build ios framework

IOS_FRAMEWORK_DIR="$BINARY_DISTRIBUTION_DIR/ios/HBHandlebars.framework"

# create framework skeleton
mkdir -p "$IOS_FRAMEWORK_DIR/Versions/A/Headers"
/bin/ln -sfh A "$IOS_FRAMEWORK_DIR/Versions/Current"
/bin/ln -sfh Versions/Current/Headers "$IOS_FRAMEWORK_DIR/Headers"
/bin/ln -sfh "Versions/Current/HBHandlebars" "$IOS_FRAMEWORK_DIR/HBHandlebars"

# copy headers into framework
"$SCRIPT_DIR/copy_public_headers.sh" "$IOS_FRAMEWORK_DIR/Headers"

# build all the variants we need 
BUILD_DIRECTORY="/tmp/handlebars-objc/build"
rm -rf "$BUILD_DIRECTORY"

xcodebuild -project "$XCODE_PROJECT" -target handlebars-objc-ios SYMROOT="$BUILD_DIRECTORY/symroot-ios-armv7" DSTROOT="$BUILD_DIRECTORY/dstroot-ios-armv7" OBJROOT="$BUILD_DIRECTORY/objroot-ios-armv7"  SDKROOT=iphoneos6.0 ARCHS="armv7 armv7s" install

xcodebuild -project "$XCODE_PROJECT" -target handlebars-objc-ios SYMROOT="$BUILD_DIRECTORY/symroot-ios-emulator" DSTROOT="$BUILD_DIRECTORY/dstroot-ios-emulator" OBJROOT="$BUILD_DIRECTORY/objroot-ios-emulator"  SDKROOT=iphonesimulator6.0 ARCHS="i386 x86_64" install


xcodebuild -project "$XCODE_PROJECT" -target handlebars-objc-ios SYMROOT="$BUILD_DIRECTORY/symroot-ios-arm64" DSTROOT="$BUILD_DIRECTORY/dstroot-ios-arm64" OBJROOT="$BUILD_DIRECTORY/objroot-ios-arm64"  SDKROOT=iphoneos6.0 ARCHS="arm64" install

# mix all variants in a fat binary inside our framework skeleton 
lipo -create "$BUILD_DIRECTORY/objroot-ios-armv7/UninstalledProducts/libhandlebars-objc-ios.a" "$BUILD_DIRECTORY/objroot-ios-emulator/UninstalledProducts/libhandlebars-objc-ios.a" "$BUILD_DIRECTORY/objroot-ios-arm64/UninstalledProducts/libhandlebars-objc-ios.a" -output "$IOS_FRAMEWORK_DIR/HBHandlebars"


##############################################################
# build osx framework

xcodebuild -project "$XCODE_PROJECT" -target handlebars-objc-osx SYMROOT="$BUILD_DIRECTORY/symroot-osx" DSTROOT="$BUILD_DIRECTORY/dstroot" OBJROOT="$BUILD_DIRECTORY/objroot-osx"  INSTALL_PATH="/Framework" SDKROOT=macosx10.8 ARCHS="x86_64" install

cp -RPf "$BUILD_DIRECTORY/dstroot/Framework/HBHandlebars.framework" "$BINARY_DISTRIBUTION_DIR/osx"