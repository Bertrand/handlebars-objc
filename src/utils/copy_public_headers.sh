#!/bin/sh

SCRIPT_DIR=`dirname "$0"` 
ROOT_DIR="$SCRIPT_DIR/../.."
SRC_DIR="$ROOT_DIR/src/handlebars-objc"

DEST_DIR="$1"

mkdir -p "$DEST_DIR"
for i in HBHandlebars.h runtime/HBTemplate.h runtime/HBExecutionContext.h runtime/HBExecutionContextDelegate.h runtime/HBEscapingFunctions.h context/HBDataContext.h context/HBHandlebarsKVCValidation.h helpers/HBHelper.h helpers/HBHelperRegistry.h helpers/HBHelperCallingInfo.h helpers/HBHelperUtils.h helpers/HBEscapedString.h partials/HBPartial.h partials/HBPartialRegistry.h errorHandling/HBErrorHandling.h ; do
  cp "$SRC_DIR/$i" "$DEST_DIR"
done