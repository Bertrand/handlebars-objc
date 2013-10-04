//
//  HBHandlebars.h
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

#import "HBDataContext.h"
#import "HBExecutionContext.h"
#import "HBHelper.h"
#import "HBHelperRegistry.h"
#import "HBPartial.h"
#import "HBPartialRegistry.h"
#import "HBTemplate.h"

@class HBHelperRegistry;

@interface HBHandlebars : NSObject

// rendering templates, simple API

+ (NSString*)renderTemplateString:(NSString*)template withContext:(id)context;
+ (NSString*)renderTemplateString:(NSString*)template withContext:(id)context withHelperBlocks:(NSDictionary*)helperBlocks;
+ (NSString*)renderTemplateString:(NSString*)template withContext:(id)context withHelperBlocks:(NSDictionary*)helperBlocks withPartialStrings:(NSDictionary*)partialStrings;

// registering global helpers

+ (void) registerHelperBlock:(HBHelperBlock)block withName:(NSString*)helperName;
+ (void) unregisterHelperWithName:(NSString*)helperName;
+ (void) unregisterAllHelpers;

// registering global partials

+ (void) registerPartialString:(NSString*)partialString withName:(NSString*)partialName;
+ (void) unregisterPartialWithName:(NSString*)partialName;
+ (void) unregisterAllPartials;


// utils

+ (NSString *)escapeHTML:(NSString *)string;

@end
