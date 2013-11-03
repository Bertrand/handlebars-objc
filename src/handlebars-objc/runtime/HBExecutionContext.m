//
//  HBExecutionContext.m
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

#import "HBExecutionContext.h"
#import "HBExecutionContext_Private.h"
#import "HBHelperRegistry.h"
#import "HBPartialRegistry.h"
#import "HBTemplate.h"
#import "HBTemplate_Private.h"
#import "HBPartial.h"

@interface _HBGlobalExecutionContext : HBExecutionContext
- (NSString*) localizedString:(NSString*)string;
@end

@implementation _HBGlobalExecutionContext
- (NSString*) localizedString:(NSString*)string
{
    NSString* localizedVersion = [super localizedString:string];
    if (!localizedVersion) {
        localizedVersion = [[NSBundle mainBundle] localizedStringForKey:string value:nil table:nil];
    }
    return localizedVersion;
}
@end


@implementation HBExecutionContext

+ (instancetype) globalExecutionContext
{
    static dispatch_once_t pred;
    static _HBGlobalExecutionContext* _globalExecutionContext = nil;
    
    dispatch_once(&pred, ^{
        _globalExecutionContext = [[_HBGlobalExecutionContext alloc] init];
    });
    
    return _globalExecutionContext;
}


#pragma mark -
#pragma mark Helpers

- (HBHelperRegistry*) helpers
{
    @synchronized(self) {
        if (_helpers) return _helpers;
        _helpers = [HBHelperRegistry new];
    }
    return _helpers;
}

- (void) registerHelperBlock:(HBHelperBlock)block forName:(NSString*)name
{
    [self.helpers registerHelperBlock:block forName:name];
}

- (void) registerHelperBlocks:(NSDictionary *)helperBlocks
{
    [self.helpers registerHelperBlocks:helperBlocks];
}

- (void) unregisterHelperForName:(NSString*)name
{
    [self.helpers removeHelperForName:name];
}

- (void) unregisterAllHelpers
{
    [self.helpers removeAllHelpers];
}

- (HBHelper*) helperForName:(NSString*)name
{
    HBHelper* helper = nil;
    if ([self.delegate respondsToSelector:@selector(helperBlockWithName:forExecutionContext:)]) {
        HBHelperBlock helperBlock = [self.delegate helperBlockWithName:name forExecutionContext:self];
        if (helperBlock) {
            helper = [[HBHelper new] autorelease];
            helper.block = helperBlock;
        }
    }
    
    if (!helper) {
        helper = self.helpers[name];
    }
    
    return helper;
}



#pragma mark -
#pragma mark Partials

- (HBPartialRegistry*) partials
{
    @synchronized(self) {
        if (_partials) return _partials;
        _partials = [HBPartialRegistry new];
    }
    return _partials;
}

- (void) registerPartialString:(NSString*)partialString forName:(NSString*)name
{
    [self.partials registerPartialString:partialString forName:name];
}

- (void) registerPartialStrings:(NSDictionary* /* NSString -> NSString */)partials
{
    [self.partials registerPartialStrings:partials];
}

- (void) unregisterPartialForName:(NSString*)name
{
    [self.partials unregisterPartialForName:name];
}

- (void) unregisterAllPartials
{
    [self.partials unregisterAllPartials];
}

- (HBPartial*) partialForName:(NSString*)name
{
    HBPartial* partial = nil;

    if ([self.delegate respondsToSelector:@selector(partialWithName:forExecutionContext:)]) {
        partial = [self.delegate partialWithName:name forExecutionContext:self];
    }
    
    if (!partial && [self.delegate respondsToSelector:@selector(partialStringWithName:forExecutionContext:)]) {
        NSString* partialString = [self.delegate partialStringWithName:name forExecutionContext:self];
        if (partialString) {
            partial = [[HBPartial new] autorelease];
            partial.string = partialString;
        }
    }
    
    if (!partial) {
        partial = self.partials[name];
    }
    
    return partial;
}

#pragma mark -
#pragma mark Instanciating templates

- (HBTemplate*) templateWithString:(NSString*)string
{
    HBTemplate* template = [[HBTemplate alloc] initWithString:string];
    if ([[self class] globalExecutionContext] != self) {
        template.sharedExecutionContext = self;
    }
    return [template autorelease];
}

    
#pragma mark -
#pragma mark Localization

- (NSString*) localizedString:(NSString*)string
{
    if ([self.delegate respondsToSelector:@selector(localizedString:forExecutionContext:)]) {
        return [self.delegate localizedString:string forExecutionContext:self];
    }
    
    return nil;
}

#pragma mark -
#pragma mark Escaping

- (NSString*) escapeString:(NSString*)rawString forTargetFormat:(NSString*)formatName;
{
    if ([self.delegate respondsToSelector:@selector(escapeString:forTargetFormat:forExecutionContext:)]) {
        return [self.delegate escapeString:rawString forTargetFormat:formatName forExecutionContext:self];
    }
    
    return nil;
}

#pragma mark -

- (void) dealloc
{
    self.helpers = nil;
    self.partials = nil;
    self.delegate = nil;
    
    [super dealloc];
}

@end
