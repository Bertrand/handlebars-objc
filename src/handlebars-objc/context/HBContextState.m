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

@implementation HBContextState

+ (instancetype)stateWithContext:(id)context data:(HBDataContext*)data
{
    HBContextState* result = [[[[self class] alloc] init] autorelease];
    result.context = context;
    result.dataContext = data;
    return result;
}

- (id) valueForKey:(NSString*)key context:(id)context
{
    if (!context) return nil;
    id result;
    if ([context respondsToSelector:@selector(objectForKeyedSubscript:)]) {
        @try {
            result = [context objectForKeyedSubscript:key];
        }
        @catch (NSException* e) {
            result = nil;
        }
    } else {
        result = nil;
    }
    return result;
}

- (id) evaluateContextualValue:(HBAstContextualValue*)value
{
    if (value.isDataValue) {
        NSAssert(value.keyPath && value.keyPath.count > 0, @"no keypath in data value");
        NSAssert(value.keyPath.count == 1, @"keypath in data value can not have multiple components");
        NSString* key = [value.keyPath[0] key];
        return self.dataContext ? self.dataContext[key] : nil;
    } else {
        NSArray* pathComponents = value.keyPath;
        
        HBContextState* startState = self;
        NSUInteger index = 0;
        
        if (pathComponents.count > 0 && ([[pathComponents[0] key] isEqualToString:@"this"] || [[pathComponents[0] key] isEqualToString:@"."])) index++;
        
        // consume all ".."
        while (index < pathComponents.count && [[pathComponents[index] key] isEqualToString:@".."] && startState) {
            index++;
            startState = startState.parent;
        }
        if (!startState) return nil;
        
        // consume remaining "normal" keypath
        id current = startState.context;
        while (index < pathComponents.count && current) {
            NSString* key = [pathComponents[index] key];
            current = [self valueForKey:key context:current];
            index++;
        }
        
        return current;
    }
    
    return nil; // please compiler
}

- (HBDataContext*) dataContextCopyOrNew
{
    if (self.dataContext) return [self.dataContext copy];
    return [HBDataContext new];
}

@end
