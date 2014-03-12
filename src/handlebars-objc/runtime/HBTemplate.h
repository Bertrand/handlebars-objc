//
//  HBTemplate.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/1/13.
//
//  The MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "HBHelper.h"

@class HBHelperRegistry;
@class HBPartialRegistry;

/** 
 The HBTemplate is the class representing templates in HBHandlebars. 
 
 You create template with <initWithString:>. 
 
 You can then optionnaly compile them with the <compile> method. If you don't do it, the template will be compiled automatically the first time your application tries to render it. Compilation is cached, meaning that it's done once only.
 
 You can render a template with the <renderWithContext:> method. Please see <HBHandlebars> for a discussion of what a context object is. 
 
 Templates can also have "local" helpers and partial, ie helpers and partials that are only available to this template. To register local helpers, use the <helpers> property and manipulate the corresponsing registry directly. To add local partial use <partial> property. 
 */

@interface HBTemplate : NSObject

/** 
 the actual template string 
 */
@property (retain, nonatomic) NSString* templateString;

/**
 Designated initializer
 
 This method initializes an HBTemplate object. If you want this template to be part of a shared execution context, please use <[HBExecutionContext templateWithString:]> instead.
 
 @param string The template string
 @see [HBExecutionContext templateWithString:]
 @since v1.0
 */
- (id) initWithString:(NSString*)string;

/**
 Render a template 
 
 This method renders the template for the provided context. Variables used in the template will be taken from the context. 
 
 @param context The object containing the data used in the template. Can be any property-list compatible object for instance.
 @param error Pointer to an NSError object that will be set in case an error occurs during rendering.
 @since v1.0
 */
- (NSString*)renderWithContext:(id)context error:(NSError**)error;

/** @name Compilation */

/**
 Compile the receiver. 
 
 This method compiles the template string. This method can be safely called multiple time, template will only be compiled once. There is no need to call it before rendering, it'll be called lazily if needed, at render time. Calling this method provides a way to control when compilation should occur in your application lifetime. 
 @param error pointer to an error object that is set in case of parsing error.
 @return YES if the template was compiled. Returns NO if an error occurred.
 @since v1.0
 */
- (BOOL) compile:(NSError**)error; // done automatically when rendering. Can be called at will, upfront if wanted.

/** @name Helpers and partials */

/**
 Helpers registry. 
 
 This method gives access to the helpers specific to this template.
 Please see <HBHelperRegistry> for more details. 
 */
- (HBHelperRegistry*) helpers;

/**
 Helpers registry.
 
 This method gives access to the partials specific to this template.
 Please see <HBTemplateRegistry> for more details.
 */
- (HBPartialRegistry*) partials;

/** @name localization of strings */

/**
 Return the localized version of a string.
 
 Used by helpers which want to benefit from the built-in localization mechanisms in handlebars-objc.
 
 @param string the string to localize
 @return the localized version of the string
 @since v1.1.0
 */
- (NSString*) localizedString:(NSString*)string;

@end
