//
//  HBExecutionContextDelegate.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/19/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HBHelper.h" 
#import "HBEscapingFunctions.h"

@class HBExecutionContext;
@class HBPartial;

/** 
 HBExecutionContext delegate protocol
 
 By implementing an execution context delegate you can control certain of its behaviours. 
 All the methods from this protocol are optional. 
 
 # Tasks #
 
 Provide your own helper provisioning mechanism using <helperBlockWithName:forExecutionContext:>
 
 Provide your own partial provisioning mechanism by implementing <partialStringWithName:forExecutionContext:>
 
 */

@protocol HBExecutionContextDelegate <NSObject>

@optional

/** 
 return a helper block with a given name
 
 Implement this method if you want to implement your own helper organization mechanism. 
 
 @param name name of the helper
 @param executionContext the execution context requesting the helper. Useful if your delegate is the delegate of serveral execution contexts.
 @return a helper block
 @since v1.1.0
 */
- (HBHelperBlock) helperBlockWithName:(NSString*)name forExecutionContext:(HBExecutionContext*)executionContext;

/**
 return a partial string with a given name
 
 Implement this method if you want to implement your own partial organization mechanism.
 
 @param name name of the partial
 @param executionContext the execution context requesting the partial string. Useful if your delegate is the delegate of serveral execution contexts.
 @return a partial string
 @since v1.1.0
 */
- (NSString*) partialStringWithName:(NSString*)name forExecutionContext:(HBExecutionContext*)executionContext;


/**
 return a partial with a given name
 
 Implement this method if you want to implement your own partial organization mechanism.
 
 @param name name of the partial
 @param executionContext the execution context requesting the partial. Useful if your delegate is the delegate of serveral execution contexts.
 @return the partial (can be nil)
 @since v1.1.0
 */
- (HBPartial*) partialWithName:(NSString*)name forExecutionContext:(HBExecutionContext*)executionContext;


/** 
 Return the localized version of a string. 
 
 Implement this method if you want to provide you own localization mechanism. 
 This method is called by helpers using the built-in localization mechanism in handlebars-objc. One such helper is the "localize" built-in helper.
 
 @param string the string to localize
 @param executionContext the execution context requesting the localized string. 
 @return the localized version of the string 
 @since v1.1.0
 */
- (NSString*) localizedString:(NSString*)string forExecutionContext:(HBExecutionContext*)executionContext;

/**
 Return the escaped version of a string for a target text mode
 
 Implement this method if you want to provide a specific escaping mechanism for a target format. If your delegate does not support the escaping of a format, this function should return nil. 
 
 @param rawString string to escape
 @param formatName the name of current mode. When mode is a well-known text format, it is generally a mime-type ("text/html" for html, "application/javascript" for javascript, ...).
 @param executionContext the execution context requesting the escaped string
 @return the escaped string or nil if this format is not supported by the delegate
 @since v1.1.0
 */
- (NSString*) escapeString:(NSString*)rawString forTargetFormat:(NSString*)formatName forExecutionContext:(HBExecutionContext*)executionContext;


@end
