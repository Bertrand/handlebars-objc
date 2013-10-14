//
//  HBErrorHandling.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/14/13.
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

#import "HBErrorHandling.h"


NSString* HBErrorDomain = @"com.fotonauts.handlebars-objc.ErrorDomain";

// HBParseError constants

NSString* HBLineNumberKey = @"HBLineNumberKey";
NSString* HBPositionInBufferKey = @"HBPositionInBufferKey";
NSString* HBContextInBufferKey = @"HBContextInBufferKey";
NSString* HBParserLowLevelDescriptionKey = @"HBParserLowLevelDescriptionKey";

// HBHelperMissingError constants

NSString* HBHelperNameKey = @"HBHelperNameKey";

// HBPartialMissingError constants

NSString* HBPartialNameKey = @"HBPartialNameKey";


@implementation HBParseError


+ (instancetype) parseErrorWithLineNumber:(NSInteger)lineNumber positionInBuffer:(NSInteger)positionInBuffer contextInBuffer:(NSString*)context lowLevelParserDescription:(NSString*)parserError
{
    NSDictionary* userInfo = @{
                               HBLineNumberKey: @(lineNumber),
                               HBPositionInBufferKey: @(positionInBuffer),
                               HBContextInBufferKey: context,
                               HBParserLowLevelDescriptionKey: parserError
                            };
    return [HBParseError errorWithDomain:HBErrorDomain code:HBErrorCodeGenericParseError userInfo:userInfo];
}

- (NSInteger) lineNumber
{
    NSNumber* lineNumberObject = [self.userInfo objectForKey:HBLineNumberKey];
    if (!lineNumberObject || ![lineNumberObject isKindOfClass:[NSNumber class]]) return -1;
    return [lineNumberObject integerValue];
}

- (NSInteger) positionInBuffer
{
    NSNumber* positionInBufferObject = [self.userInfo objectForKey:HBPositionInBufferKey];
    if (!positionInBufferObject || ![positionInBufferObject isKindOfClass:[NSNumber class]]) return -1;
    return [positionInBufferObject integerValue];
}

- (NSString*) contextInBuffer
{
    return [self.userInfo objectForKey:HBContextInBufferKey];
}

- (NSString*) lowLevelParserDescription
{
    return [self.userInfo objectForKey:HBParserLowLevelDescriptionKey];
}


@end

@implementation HBHelperMissingError

+ (instancetype) HBHelperMissingErrorWithHelperName:(NSString*)helperName
{
    NSDictionary* userInfo = @{ HBHelperNameKey: helperName };
    return [HBHelperMissingError errorWithDomain:HBErrorDomain code:HBErrorCodeHelperMissingError userInfo:userInfo];
}

- (NSString*) helperName
{
    return [self.userInfo objectForKey:HBHelperNameKey];
}

@end

@implementation HBPartialMissingError

+ (instancetype) HBPartialMissingErrorWithPartialName:(NSString*)partialName
{
    NSDictionary* userInfo = @{ HBPartialNameKey: partialName };
    return [HBPartialMissingError errorWithDomain:HBErrorDomain code:HBErrorCodePartialMissingError userInfo:userInfo];

}

- (NSString*) partialName
{
    return [self.userInfo objectForKey:HBPartialNameKey];
}

@end