//
//  HBContextRendering.m
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

#import "HBContextRendering.h"

// We used to use categories on NSNumber, NSString ... but on ios, we generate
// a static library and using categories with categories requires adding -ObjC
// to the linker, and this is not something we want.
//
// Instead we now use isKindOfClass (and this sucks).
//

NSString* renderForHandlebars(id object)
{
    if (nil == object) return nil;
    NSString* renderedValue = nil;
    if ([object respondsToSelector:@selector(renderValueForHandlebars)]) {
        renderedValue = [object renderValueForHandlebars];
    } else {
        // see remark about objc categories and static libraries above
        if ([object isKindOfClass:[NSString class]]) {
            renderedValue = object;
        } else if ([object isKindOfClass:[NSNumber class]]) {
            renderedValue = [object description];
        } else {
            // last resort, return nil. If wanted, another behaviour for individual classes can be provided via the implementation of HBContextRendering Protocol
            renderedValue = nil;
        }
    }
    return renderedValue;
}


