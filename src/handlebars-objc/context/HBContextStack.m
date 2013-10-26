//
//  HBContextStack.m
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

#import "HBContextStack.h"
#import "HBContextState.h" 

@interface HBContextStack()
@property (readwrite, retain, nonatomic) HBContextState* current;
@end

@implementation HBContextStack


- (void) push:(HBContextState*)state
{
    state.parent = self.current;
    self.current = state;
    
    // Line below implements one part of the
    //   "Private variables provided via the data option are available in all descendent scopes."
    // from http://handlebarsjs.com/block_helpers.html
    // by always copying current data context to new pushed contexts if they don't
    // already have one.
    //
    // The other part is up to block helpers that make sure they always copy their inherited
    // data context when creating a new one.
    //
    // This is a bit fragile and inelegant. We might want to replace this with a bottom-up
    // traveral of stacked data context at evaluation time.
    // This would be less fragile, more element, but probably less efficient in some cases.
    if ((state.dataContext == nil) && state.parent) state.dataContext = state.parent.dataContext;
}

- (void) pop
{
    HBContextState* state = self.current;
    if (state) {
        self.current = state.parent;
    }
}

#pragma mark -

- (void) dealloc
{
    self.current = nil;
    [super dealloc];
}
@end
