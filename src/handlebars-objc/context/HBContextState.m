//
//  HBContextState.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 9/30/13.
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

#import "HBContextState.h"
#import "HBAstContextualValue.h" 
#import "HBDataContext.h" 
#import "HBObjectPropertyAccess.h"

@implementation HBContextState

+ (instancetype)stateWithContext:(id)context data:(HBDataContext*)data
{
    HBContextState* result = [[[[self class] alloc] init] autorelease];
    result.context = context;
    result.dataContext = data;
    return result;
}

- (id) valueForKey:(NSString*)key context:(id)context includeMergedAttributes:(BOOL)includeMergedAttributes
{
    if (!context) return nil;
    id result;
    if (includeMergedAttributes && self.mergedAttributes && self.mergedAttributes[key]) {
        return self.mergedAttributes[key];
    }
        
    @try {
        result = [HBObjectPropertyAccess valueForKey:key onObject:context];
    }
    @catch (NSException* e) {
        result = nil;
    }

    return result;
}

- (id) evaluateContextualValue:(HBAstContextualValue*)value
{
    NSUInteger index = 0;
    id current = nil;
    NSArray* pathComponents = value.keyPath;

    HBContextState* startState = self;

    // consume "." components if any
    if (pathComponents.count > 0 && ([[pathComponents[0] key] isEqualToString:@"this"] || [[pathComponents[0] key] isEqualToString:@"."])) index++;
    
    // consume ".." components if any
    while (index < pathComponents.count && [[pathComponents[index] key] isEqualToString:@".."] && startState) {
        index++;
        startState = startState.parent;
    }
    if (!startState) return nil;
    current = startState.context;
    
    // if node is a value, first component (after "." and ".." components) is a data value
    if (value.isDataValue) {
        NSAssert(pathComponents && pathComponents.count > index, @"no keypath in data value");
        NSString* key = [value.keyPath[index] key];
        current = startState.dataContext ? startState.dataContext[key] : nil;
        index++;
    }
    
    // consume remaining "normal" keypath
    BOOL atRootLevel = true;
    while (index < pathComponents.count && current) {
        NSString* key = [pathComponents[index] key];
        current = [self valueForKey:key context:current includeMergedAttributes:atRootLevel];
        atRootLevel = false;
        index++;
    }
    
    return current;
}

- (HBDataContext*) dataContextCopyOrNew 
{
    if (self.dataContext) return [self.dataContext copy];
    return [HBDataContext new];
}

#pragma mark -

- (void) dealloc
{
    self.context = nil;
    self.dataContext = nil;
    self.mergedAttributes = nil;
    self.parent = nil;
    [super dealloc];
}

@end
