//
//  HBDataContext.h
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

/**
 Handlebars.js supports private variables set by block helpers and available to 
 descendant scopes (See [block helpers](http://handlebarsjs.com/block_helpers.html)
 on Handlebars.js).
 
 Support for private data is provided by data context. In addition to context, 
 helpers receive an HBDataContext in their calling info (see <[HBHelperCallingInfo data]>)
 holding all currently set private variables. 
 
 Variables can be accessed using the dataForKey/setData:forKey accessors or directly 
 using objective-C keyed subscripting operators. 
 
 ## Setting variables in helpers ##
 
 When setting variables in a helper, you *MUST NEVER* modify passed context directly.
 You *MUST* copy the data context your received, copy it (using <copy>), modify it
 and then pass it to children statements (See <-[HBHelperCallingInfo statements]> for more
 information about statements)
 
 */
@interface HBDataContext : NSObject

/** @name accessing variables */

/**
 get the value of a private variable
 
 @param key name of the private variable to retrieve
 @return the value of private variable. Can be any objective-C value.
*/
- (id) dataForKey:(NSString*)key;

/**
 set the value of a private variable
 
 @param data value of private variable 
 @param key the name of the private variable
 */
- (void) setData:(id)data forKey:(NSString*)key;

/** @name Copying data contexts */

/**
 copy receiver
 
 Using this method is the roper way to copy data context in helpers implementation. 
 This is generally done only when setting a new private variable passed to 
 children scopes. 
 
 @return a copy of the receiver
*/
- (id) copy; 

/** @name objc litteral compatibility */

/** 
 keyed subscripting read accessor 
 
 You generally do not call this method directly. Instead, use objective-C subscripting operators.
 This method calls <setData:forKey>. 
 
 @param key name of the private variable to retrieve
 @return the value of private variable. Can be any objective-C value.
*/
- (id)objectForKeyedSubscript:(id)key;

/**
 keyed subscripting write accessor
 
 You generally do not call this method directly. Instead, use objective-C subscripting operators.
 This method calls <setData:forKey>.
 
 @param object value of private variable
 @param aKey name of the private variable to retrieve
 */
- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey;

@end
