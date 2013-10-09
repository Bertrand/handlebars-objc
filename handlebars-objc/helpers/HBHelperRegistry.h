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

@interface HBHelperRegistry : NSObject

+ (instancetype) registry;

// user-friendly api, using blocks

- (void) registerHelperBlock:(HBHelperBlock)block forName:(NSString*)name;
- (void) registerHelperBlocks:(NSDictionary *)helperBlocks;


// accessing raw helpers

- (HBHelper*) helperForName:(NSString*)name;

// adding raw helpers

- (void) setHelper:(HBHelper*)helper forName:(NSString*)name;
- (void) addHelpers:(NSDictionary*)helpers;

// removing raw helpers

- (void) removeHelperForName:(NSString*)name;
- (void) removeAllHelpers;

// objc litteral compatibility

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey;

@end