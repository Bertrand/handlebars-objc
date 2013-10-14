#!/bin/sh

#
# You need to have appledoc installed to run this script
#
# 'brew install appledoc' is by far the fastest way to install it. 
#
# Please see https://github.com/tomaz/appledoc for more details
#

command -v appledoc >/dev/null 2>&1 || { echo >&2 "appledoc not installed. 'brew install appledoc' is your friend. Aborting."; exit 1; }

SCRIPT_DIR=`dirname $0`
ROOT_DIR="$SCRIPT_DIR/../.."
API_DOC_DIR="$ROOT_DIR/api_doc"
SRC_DIR="$ROOT_DIR/handlebars-objc"

# cleanup api doc dir
rm -rf "$API_DOC_DIR"

PUBLIC_HEADERS_DIR="/tmp/handlebars-objc-headers"

# copy public header files to /tmp
rm -rf "$PUBLIC_HEADERS_DIR"
"./$SCRIPT_DIR/copy_public_headers.sh" "$PUBLIC_HEADERS_DIR"

# Generate documentation
mkdir -p "$API_DOC_DIR"
appledoc --create-html --no-create-docset --output "$API_DOC_DIR" "$SCRIPT_DIR/AppledocSettings.plist" "$PUBLIC_HEADERS_DIR" 
#appledoc --no-create-html --install-docset true --index-desc "$ROOT_DIR/README.md" --output "/tmp" "$SCRIPT_DIR/AppledocSettings.plist" "$PUBLIC_HEADERS_DIR" 
