//
//  HBHelperRegistry.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/2/13.
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

/**
 HBHelperRegistry instances are objects holding a set of helpers available to templates.
 They are the actual objects used by [HBExecutionContext] instances to store helpers.
 
 You generally do not use a registry directly but use the corresponding shorcut methods on [HBExecutionContext]
 
 Helper registries implement the objective-C keyed subscripting API though, meaning that you can read and write helpers using subscripting operators. For instance : 
 
 HBExecutionContext* e = [[HBExecutionContext] new] autorelease]; 
 HBHelper* h = ...;
 e.helpers[@"my_helper"] = h; 
 
 */
@interface HBHelperRegistry : NSObject

/** 
 Create a new registry
 
 Actually, you should not use this method :)
 Will be moved soon to a private header
 */
+ (instancetype) registry;

/* @name Registering helper blocks */

/**
 Register a helper in the registry
 
 Use this method registers a helper in the receiving registry.
 
 @param block block implementation of the helper
 @param name name of the helper
 @see [HBExecutionContext registerHelperBlock:forName:]
 @since v1.0.0
 */
- (void) registerHelperBlock:(HBHelperBlock)block forName:(NSString*)name;

/**
 Register several helpers at once in the registry
 
 Use this method registers several helpers at once in the receiving registry.
 @param helperBlocks a dictionary whose keys are helper names and value are helper blocks
 @since v1.0.0
 */
- (void) registerHelperBlocks:(NSDictionary *)helperBlocks;


/** @name Managing raw helpers */

/**
 Retrieve a helper by name
 
 @param name name of the helper to retrieve
 @since v1.0.0
 */
- (HBHelper*) helperForName:(NSString*)name;

/**
 Adding a helper object 
 
 Use this method it you want to register a helper object directly (instead of a helper block). This method is of very limited usefulness in this version of the API since HBHelper objects are merely wrappers around blocks
 @param helper the helper object
 @param name the name of the helper
 @since v1.0.0
 */
- (void) setHelper:(HBHelper*)helper forName:(NSString*)name;

/** 
 Adding several helper objects at once
 
 Use this method if you want to add multiple helpers at once. See the discussion in <setHelper:forName:> regarding the usefulness of using this method.
 @param helpers an NSDictionary containing the helpers to add where keys are the name of the helpers and values are HBHelper objects.
 */
- (void) addHelpers:(NSDictionary*)helpers;

/**
 remove a helper 
 
 @param name name of the helper to remove 
 @since v1.0.0
 */
- (void) removeHelperForName:(NSString*)name;

/** 
 remove all helpers at once 
 */
- (void) removeAllHelpers;


/** 
 Retrieve a helper by name using the objective-C keyed subscripting API
 
 This method lets you access a helper by its name using objective-C subscripting operators. 
 For instance: 
 
    HBHelper* h = registry[@"my_helper"]; 
 
 @param key name of the helper
 @return the helper object 
 @since v1.0.0
*/
- (id)objectForKeyedSubscript:(id)key;

/**
 Add a helper using the objective-C keyed subscripting API 
 
 This method lets you set a helper using objective-C subscripting operators. 
 For instance 
 
     HBHelper* h = ...;
     registry[@"my_helper"] = h; 
 
 @param object the helper to set (an [HBHelper] instance)
 @param key name of the helper
 @since v1.0.0
 */
- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)key;

@end