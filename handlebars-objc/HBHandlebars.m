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

+ (NSString*)renderTemplateString:(NSString*)template withContext:(id)context
{
    return [self renderTemplateString:template withContext:context withHelperBlocks:nil withPartialStrings:nil];
}

+ (NSString*)renderTemplateString:(NSString*)template withContext:(id)context withHelperBlocks:(NSDictionary*)helperBlocks;
{
    return [self renderTemplateString:template withContext:context withHelperBlocks:helperBlocks withPartialStrings:nil];
}

+ (NSString*)renderTemplateString:(NSString*)template withContext:(id)context withHelperBlocks:(NSDictionary*)helperBlocks withPartialStrings:(NSDictionary*)partials
{
    HBTemplate* hbTemplate = [[HBTemplate alloc] initWithString:template];
    if (helperBlocks) [hbTemplate.helpers registerHelperBlocks:helperBlocks];
    if (partials) [hbTemplate.partials registerPartialStrings:partials];
    
    NSString* renderedString = [hbTemplate renderWithContext:context];
    
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

#pragma mark -
#pragma mark Utils

// Stolen from https://github.com/groue/GRMustache

+ (NSString *)escapeHTML:(NSString *)string
{
    NSUInteger length = [string length];
    if (length == 0) {
        return string;
    }
    
    static const NSString *escapeForCharacter[] = {
        ['&'] = @"&amp;",
        ['<'] = @"&lt;",
        ['>'] = @"&gt;",
        ['"'] = @"&quot;",
        ['\''] = @"&apos;",
    };
    static const int escapeForCharacterLength = sizeof(escapeForCharacter) / sizeof(NSString *);
    
    
    // Assume most strings don't need escaping, and help performances: avoid
    // creating a NSMutableData instance if escaping in uncessary.
    
    BOOL needsEscaping = NO;
    for (NSUInteger i=0; i<length; ++i) {
        unichar character = [string characterAtIndex:i];
        if (character < escapeForCharacterLength && escapeForCharacter[character]) {
            needsEscaping = YES;
            break;
        }
    }
    
    if (!needsEscaping) {
        return string;
    }
    
    
    // Escape
    
    const UniChar *characters = CFStringGetCharactersPtr((CFStringRef)string);
    if (!characters) {
        NSMutableData *data = [NSMutableData dataWithLength:length * sizeof(UniChar)];
        [string getCharacters:[data mutableBytes] range:(NSRange){ .location = 0, .length = length }];
        characters = [data bytes];
    }
    
    NSMutableString *buffer = [NSMutableString stringWithCapacity:length];
    const UniChar *unescapedStart = characters;
    CFIndex unescapedLength = 0;
    for (NSUInteger i=0; i<length; ++i, ++characters) {
        const NSString *escape = (*characters < escapeForCharacterLength) ? escapeForCharacter[*characters] : nil;
        if (escape) {
            CFStringAppendCharacters((CFMutableStringRef)buffer, unescapedStart, unescapedLength);
            CFStringAppend((CFMutableStringRef)buffer, (CFStringRef)escape);
            unescapedStart = characters+1;
            unescapedLength = 0;
        } else {
            ++unescapedLength;
        }
    }
    if (unescapedLength > 0) {
        CFStringAppendCharacters((CFMutableStringRef)buffer, unescapedStart, unescapedLength);
    }
    return buffer;
}

+ (BOOL)evaluateObjectAsBool:(id)object
{
    if (!object) return false;
    if ([object isKindOfClass:[NSNumber class]]) return [object boolValue];
    if ([object isKindOfClass:[NSString class]]) return [object length] > 0;
    if ([object isKindOfClass:[NSArray class]]) return [object count] > 0;
    return false;
}

@end
