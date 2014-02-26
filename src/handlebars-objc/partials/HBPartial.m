//
//  HBPartial.m
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

#import "HBPartial.h"
#import "HBPartial_Private.h"
#import "HBParser.h"

@implementation HBPartial

- (BOOL) compile:(NSError**)error
{
    @synchronized(self) {
        if (!self._program) {
            self._program = [HBParser astFromString:self.string error:error];
        }
    }
    return (nil != self._program);
}

- (NSArray*) astStatements
{
    return self._program.statements;
}

#pragma mark -

- (void) dealloc
{
    self.string = nil;
    self._program = nil;
    [super dealloc];
}

@end
