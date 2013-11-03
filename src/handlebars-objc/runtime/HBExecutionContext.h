//
//  HBExecutionContext.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/4/13.
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
#import "HBExecutionContextDelegate.h"

@class HBHelperRegistry;
@class HBPartialRegistry;
@class HBTemplate;
@class HBPartial;

/**
 
 HBExecutionContexts are objects you can create if your application generates documents that use different sets of partials and helpers.

 In this case, rather than registering your helpers and partial at the global level, you create an HBExecutionContext instance, add your helpers (using the <registerHelperBlocks:> method for instance), add your partials (using the <registerPartialStrings:> method for instance).
 
 You can then create templates (using <templateWithString:>) that automatically have access to all the helpers and partials you've registered in the execution context instance they've been created from. 
 
 Note that templates created from an execution context will also have access to any helper and partial added *after* the template was created. 
 
 Please note also that templates created from an execution context *still have access* to the global helpers and partials. 
 
 As an implementation note, all methods on [HBHandlebars] that register global helpers and partials actually register them in a singleton execution context available using the <globalExecutionContext> method. It is totally fine to manipulate the global execution context directly. 
 
 */

@interface HBExecutionContext : NSObject

/** 
 Helper registry. This is the actual place where helpers of the execution context are registered. 
 */
@property (retain, nonatomic) HBHelperRegistry* helpers;
 
/**
 Partial registry. This is the actual place where partials of the execution context are registered.
*/
@property (retain, nonatomic) HBPartialRegistry* partials;

/**
 Delegate. Please see <HBExecutionContextDelegate> for details of what you can control with the delegate 
 */
@property (assign, nonatomic) id<HBExecutionContextDelegate> delegate;

/**
 Access the global execution context. 
 
 Helpers and partials registered in the global execution context are available to all templates.
 */
+ (instancetype) globalExecutionContext;

/**
 Creates a template that has access to the helpers and partials from the receiver.
 @param string template string
 */
- (HBTemplate*) templateWithString:(NSString*)string;

/** @name managing helpers */

/** 
 Register a helper in the execution context
 
 Use this method registers a helper in the receiving execution context.
 
 @param block block implementation of the helper
 @param name name of the helper 
 @since v1.0.0
 */
- (void) registerHelperBlock:(HBHelperBlock)block forName:(NSString*)name;

/** 
 Register several helpers at once in the execution context
 
 Use this method registers several helpers at once in the receiving execution context.
 @param helperBlocks a dictionary whose keys are helper names and value are helper blocks
 @since v1.0.0
 */
- (void) registerHelperBlocks:(NSDictionary *)helperBlocks;

/** 
 Unregister a helper form the execution context
 
 Use this method to unregister a previously registered helper. Unregistering a helper which has not been registered will have no effect.
 @param name name of the helper to unregister
 @since v1.0.0
 */
- (void) unregisterHelperForName:(NSString*)name;

/** 
 Unregister all helpers from the execution context
 
 Use this method to unregister all the helpers you have registered in the receiving execution context. 
 @since v1.0.0
 */
- (void) unregisterAllHelpers;

/**
 Get a helper by name
 
 This method tries to find a helper matching a name. 
 @param name name of the helper to look up
 @return the helper if found, nil otherwise. 
 @since v1.1.0
 */
- (HBHelper*) helperForName:(NSString*)name;

/** @name managing partials */

/** 
 Register a partial in the execution context
 
 @param partialString the partial itself
 @param name name of the partial 
 @since v1.0.0
 */
- (void) registerPartialString:(NSString*)partialString forName:(NSString*)name;

/**
 Register several partials at once in the execution context. 
 
 @param partials an NSDictionary whose keys are partial names and values are partial strings
 @since v1.0.0
 */
- (void) registerPartialStrings:(NSDictionary* /* NSString -> NSString */)partials;

/** 
 Unregister a partial from execution context
 
 Use this method to unregister a partial you have previously registered in the receiving execution context. Unregistering a partial which has not yet been registered will have no effect.
 
 @param name name of the partial to unregister
 @since v1.0.0
 */
- (void) unregisterPartialForName:(NSString*)name;

/**
 Unregister all partials from the execution context 
 
 Use this method to unregister all the partials you have registered in the receiving execution context. 
 @since v1.0.0
 */
- (void) unregisterAllPartials;

/** 
 Get a partial by name
 
 This method tries to find a partial in the receiving execution context. 
 @param name name of the partial 
 @return the partial if found, nil otherwise. 
 @since v1.1.0
 */
- (HBPartial*) partialForName:(NSString*)name;



 
 

@end





