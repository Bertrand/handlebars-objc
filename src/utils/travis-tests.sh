#!/bin/sh

#  travis-tests.sh
#  handlebars-objc
#
#  Created by Bertrand Guiheneuf on 3/27/14.
#  Copyright (c) 2014 Fotonauts. All rights reserved.

SCRIPT_DIR=`dirname $0`
ROOT_DIR="$SCRIPT_DIR/../.."

#
# run xctool ourselves.
#
# We need to set destination to iPad, otherwise test fails with
#  "The run destination iPhone is not valid for Running the scheme 'handlebars-objc-ios'."
#
# The bug seems to be fixed in XCode 5.1
#

# unfortunately, -destination is only supported in xctool 0.1.14 and travis boxes have 0.1.13
# so first, let's upgrade brew
brew update > /dev/null
# then upgrade xctool
brew upgrade xctool || echo "xctool upgrade failed"
# and check current version
xctool --version

# now launch the actual tests
xctool -project "$ROOT_DIR/src/handlebars-objc.xcodeproj" -scheme handlebars-objc-ios  -sdk iphonesimulator -destination name=iPad build test
