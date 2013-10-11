//
//  HBPartialRegistry.h
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

@class HBPartial;

/**
 HBPartialRegistry instances are objects holding a set of partials available to templates.
 They are the actual objects used by [HBExecutionContext] instances to store partials.
 
 You generally do not use a registry directly but use the corresponding shorcut methods on [HBExecutionContext]
 
 Partial registries implement the objective-C keyed subscripting API though, meaning that you can read and write partials using subscripting operators. For instance :
 
 HBExecutionContext* e = [[HBExecutionContext] new] autorelease];
 HBPartial* p = ...;
 e.partials[@"my_partial"] = p;
 
 */
@interface HBPartialRegistry : NSObject

/**
 Retrieve a partial by name from the registry
 
 @param name name of the partial to retrieve
 @since v1.0.0
 */
- (HBPartial*) partialForName:(NSString*)name;

/**
 register a partial object  into the registry
 
 @param partial the partial to register 
 @param name name of the partial
 @since v1.0.0
 */
- (void) registerPartial:(HBPartial*)partial forName:(NSString*)name;

/**
 register a partial string  into the registry
 
 @param partialString the partial string to register 
 @param name the name of the partial 
 @since v1.0.0
 */
- (void) registerPartialString:(NSString*)partialString forName:(NSString*)name;

/**
 Register several partial objects at once into the registry
 
 @param partials an NSDictionary containing partials objects where keys are partial names and values are partial objects ([HBPartial] instances)
 @since v1.0.0
 */
- (void) registerPartials:(NSDictionary* /* NSString -> HBPartial */)partials;

/**
 Register several partial strings at once into the registry
 
 @param partials an NSDictionary containing partial strings where keys are partial names and values are partial strings.
 @since v1.0.0
 */
- (void) registerPartialStrings:(NSDictionary* /* NSString -> NSString */)partials;


/**
 Unregister a partial from the registry 
 
 @param name the name of the partial to unregister
 @since v1.0.0
 */
- (void) unregisterPartialForName:(NSString*)name;

/**
 Unregister all partials from the registry 
 
 @since v1.0.0
 */
- (void) unregisterAllPartials;

/**
 Retrieve a partial by name using the objective-C keyed subscripting API
 
 This method lets you access a partial by its name using objective-C subscripting operators.
 For instance:
 
 HBPartial* p = registry[@"my_partial"];
 
 @param key name of the partial
 @return the partial object (an HBPartial instance)
 @since v1.0.0
 */
- (id)objectForKeyedSubscript:(id)key;

/**
 Add a partial using the objective-C keyed subscripting API
 
 This method lets you set a partial using objective-C subscripting operators.
 For instance
 
 HBPartial* p = ...;
 registry[@"my_partial"] = p;
 
 @param object the partial to set (an [HBPartial] instance)
 @param key name of the partial
 @since v1.0.0
 */
- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)key;

@end
