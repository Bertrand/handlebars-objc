//
//  HBHandlebars.m
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


#import "HBHandlebars.h"

#import "HBAst.h"
#import "HBAstEvaluationVisitor.h"
#import "HBParser.h"
#import "HBTemplate.h"
#import "HBHelper.h"


static HBLoggerBlock _loggerBlock = nil;

@implementation HBHandlebars

+ (NSString*)renderTemplateString:(NSString*)template withContext:(id)context error:(NSError**)error
{
    return [self renderTemplateString:template withContext:context withHelperBlocks:nil withPartialStrings:nil error:error];
}

+ (NSString*)renderTemplateString:(NSString*)template withContext:(id)context withHelperBlocks:(NSDictionary*)helperBlocks error:(NSError**)error;
{
    return [self renderTemplateString:template withContext:context withHelperBlocks:helperBlocks withPartialStrings:nil error:error];
}

+ (NSString*)renderTemplateString:(NSString*)template withContext:(id)context withHelperBlocks:(NSDictionary*)helperBlocks withPartialStrings:(NSDictionary*)partials error:(NSError**)error
{
    HBTemplate* hbTemplate = [[HBTemplate alloc] initWithString:template];
    if (helperBlocks) [hbTemplate.helpers registerHelperBlocks:helperBlocks];
    if (partials) [hbTemplate.partials registerPartialStrings:partials];
    
    NSString* renderedString = [hbTemplate renderWithContext:context error:error];
    
    [hbTemplate release];
    return renderedString;
}

#pragma mark -
#pragma mark Partials

+ (void) registerHelperBlock:(HBHelperBlock)block forName:(NSString*)helperName
{
    [[HBExecutionContext globalExecutionContext].helpers registerHelperBlock:block forName:helperName];
}

+ (void) unregisterHelperForName:(NSString*)helperName
{
    [[HBExecutionContext globalExecutionContext].helpers removeHelperForName:helperName];
}

+ (void) unregisterAllHelpers
{
    [[HBExecutionContext globalExecutionContext].helpers removeAllHelpers];
}

#pragma mark -
#pragma mark Partials

+ (void) registerPartialString:(NSString*)partialString forName:(NSString*)partialName
{
    [[HBExecutionContext globalExecutionContext].partials registerPartialString:partialString forName:partialName];
}

+ (void) unregisterPartialForName:(NSString*)partialName
{
    [[HBExecutionContext globalExecutionContext].partials unregisterPartialForName:partialName];
}

+ (void) unregisterAllPartials
{
    [[HBExecutionContext globalExecutionContext].partials unregisterAllPartials];
}

#pragma mark -
#pragma mark Logger

+ (void) setLoggerBlock:(HBLoggerBlock)loggerBlock
{
    if (_loggerBlock != loggerBlock) {
        [_loggerBlock release];
        _loggerBlock = [loggerBlock retain];
    }
}

+ (void) log:(NSInteger)level object:(id)object
{
    if (_loggerBlock) {
        _loggerBlock(level, object);
    } else {
        NSLog(@"%@", [object description]);
    }
}

@end
