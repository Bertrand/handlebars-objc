//
//  HBPartialRegistry.m
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

#import "HBPartialRegistry.h"
#import "HBPartial.h"

@interface HBPartialRegistry()
@property (retain, nonatomic) NSMutableDictionary* partials;
@end

@implementation HBPartialRegistry

- (NSMutableDictionary*) partials
{
    @synchronized(self) {
        if (!_partials) {
            _partials = [NSMutableDictionary new];
        }
    }
    return _partials;
}

- (HBPartial*) partialForName:(NSString*)key;
{
    if (nil == self.partials) return nil;
    HBPartial* result;
    @synchronized(self.partials) {
        result = self.partials[key];
    }
    return result;
}

- (void) registerPartial:(HBPartial*)partial forName:(NSString*)key;
{
    @synchronized(self.partials) {
        self.partials[key] = partial;
    }
}

- (void) registerPartialString:(NSString*)partialString forName:(NSString*)partialName
{
    HBPartial* partial = [[HBPartial alloc] init];
    partial.string = partialString;
    [self registerPartial:partial forName:partialName];
    [partial release];
}

- (void) registerPartials:(NSDictionary*)partials
{
    for (NSString* name in partials) {
        [self registerPartial:partials[name] forName:name];
    }
}

- (void) registerPartialStrings:(NSDictionary* /* NSString -> NSString */)partials
{
    for (NSString* partialName in partials) {
        NSString* partialString = partials[partialName];
        NSAssert([partialString isKindOfClass:[NSString class]], @"partial strings must be of class NSString");
        HBPartial* partial = [[HBPartial alloc] init];
        partial.string = partialString;
        [self registerPartial:partial forName:partialName];
        [partial release];
    }
}

- (void) unregisterPartialForName:(NSString*)name
{
    @synchronized(self.partials) {
        [self.partials removeObjectForKey:name];
    }
}

- (void) unregisterAllPartials;
{
    @synchronized(self.partials) {
        [self.partials removeAllObjects];
    }
}

// objc litteral compatibility

- (id) objectForKeyedSubscript:(id)key
{
    return [self partialForName:key];
}

- (void) setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey
{
    NSAssert([(NSObject*)aKey isKindOfClass:[NSString class]], @"partial names must be strings");
    NSAssert([(NSObject*)object isKindOfClass:[HBPartial class]], @"partial objects must be substrings of HBPartial class");
    
    [self registerPartial:object forName:(NSString*)aKey];
}


#pragma mark -

- (void) dealloc
{
    self.partials = nil;
    [super dealloc];
}

@end
