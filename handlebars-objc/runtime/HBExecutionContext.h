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

@class HBHelperRegistry;
@class HBPartialRegistry;
@class HBTemplate;

@interface HBExecutionContext : NSObject

@property (retain, nonatomic) HBHelperRegistry* helpers;
@property (retain, nonatomic) HBPartialRegistry* partials;

/**
 Access the global execution context. 
 
 Helpers and partials registered in the global execution context are available to all templates.
 */
+ (instancetype) globalExecutionContext;

/**
 Creates a template that has access to the helpers and partials from receiver.
 */
- (HBTemplate*) templateWithString:(NSString*)string;

/** @name managing helpers */

- (void) registerHelperBlock:(HBHelperBlock)block forName:(NSString*)name;
- (void) registerHelperBlocks:(NSDictionary *)helperBlocks;
- (void) unregisterHelperForName:(NSString*)name;
- (void) unregisterAllHelpers;

/** @name managing partials */

- (void) registerPartialString:(NSString*)partialString forName:(NSString*)name;
- (void) registerPartialStrings:(NSDictionary* /* NSString -> NSString */)partials;
- (void) unregisterParialForName:(NSString*)name;
- (void) unregisterAllPartials;

@end
