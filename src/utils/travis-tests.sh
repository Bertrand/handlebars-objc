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

xctool -project "$ROOT_DIR/src/handlebars-objc.xcodeproj" -scheme handlebars-objc-ios  -sdk iphonesimulator -destination name=iPad build test