//
//  HBHelperRegistry.m
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

#import "HBHelperRegistry.h"

@interface HBHelperRegistry()
@property (retain, nonatomic) NSMutableDictionary* helpers;
@end

@implementation HBHelperRegistry

+ (instancetype) registry
{
    return [[[self alloc] init] autorelease];
}

- (NSMutableDictionary*) helpers
{
    @synchronized(self) {
        if (!_helpers) {
            _helpers = [NSMutableDictionary new];
        }
    }
    return _helpers;
}

- (HBHelper*) helperForName:(NSString*)name;
{
    if (nil == self.helpers) return nil;
    HBHelper* result;
    @synchronized(self.helpers) {
        result = self.helpers[name];
    }
    return result;
}

- (void) setHelper:(HBHelper*)helper forName:(NSString*)name;
{
    @synchronized(self.helpers) {
        self.helpers[name] = helper;
    }
}

- (void) addHelpers:(NSDictionary*)helpers
{
    for (NSString* name in helpers) {
        [self setHelper:helpers[name] forName:name];
    }
}

- (void) removeHelperForName:(NSString*)name
{
    @synchronized(self.helpers) {
        [self.helpers removeObjectForKey:name];
    }
}

- (void) removeAllHelpers
{
    @synchronized(self.helpers) {
        [self.helpers removeAllObjects];
    }
}

// objc litteral compatibility

- (id) objectForKeyedSubscript:(id)key
{
    return [self helperForName:key];
}

- (void) setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey
{
    NSAssert([(NSObject*)aKey isKindOfClass:[NSString class]], @"helper names must be strings");
    NSAssert([(NSObject*)object isKindOfClass:[HBHelper class]], @"helper objects must be substrings of HBHelper class");

    [self setHelper:object forName:(NSString*)aKey];
}

#pragma mark -
#pragma mark ObjC block API

- (void) registerHelperBlock:(HBHelperBlock)block forName:(NSString*)name
{
    HBHelper* helper = [HBHelper new];
    helper.block = block;
    self[name] = helper;
    [helper release];
}

- (void) registerHelperBlocks:(NSDictionary *)helperBlocks
{
    for (NSString* name in helperBlocks) {
        [self registerHelperBlock:helperBlocks[name] forName:name];
    }
}

#pragma mark -

- (void) dealloc
{
    self.helpers = nil;
    [super dealloc];
}

@end
