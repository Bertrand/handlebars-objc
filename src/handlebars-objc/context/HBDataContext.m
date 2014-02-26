//
//  HBDataContext.m
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

#import "HBDataContext.h"

@interface HBDataContext()
@property (retain, nonatomic) NSMutableDictionary* data;
@end


@implementation HBDataContext

- (id)copy
{
    HBDataContext* other = [[[self class] alloc] init];
    other.data = [[self.data mutableCopy] autorelease];
    return other;
}

- (id) dataForKey:(NSString*)key
{
    if (nil == self.data) return nil;
    return self.data[key];
}

- (void) setData:(id)data forKey:(NSString*)key
{
    if (nil == self.data) {
        self.data = [[NSMutableDictionary new] autorelease];
    }
    
    self.data[key] = data;
}

// objc litteral compatibility

- (id)objectForKeyedSubscript:(id)key
{
    return [self dataForKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey
{
    NSAssert([(NSObject*)aKey isKindOfClass:[NSString class]], @"data keys must be strings");
    [self setData:object forKey:(NSString*)aKey];
}

#pragma mark -

- (void) dealloc
{
    self.data = nil;
    [super dealloc];
}
@end
