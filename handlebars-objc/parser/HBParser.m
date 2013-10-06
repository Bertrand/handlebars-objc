//
//  HBParser.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 9/26/13.
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

#import "HBParser.h"
#import "HBAst.h"
#import "HBHandlebars.h"

extern id astFromString(NSString* text);

extern int hb_column;

@implementation HBParser

+ (HBAstProgram*)astFromString:(NSString*)text
{
    HBAstProgram* program = nil;
    
    hb_column = 1;

    @try {
        program = astFromString(text);
    }
    @catch (NSException* e) {
        NSDictionary* info = e.userInfo;
        if (info && [info isKindOfClass:[NSDictionary class]] && info[@"lineNumber"] && info[@"positionInBuffer"]) {
            NSInteger pos = [info[@"positionInBuffer"] integerValue];
            NSInteger posMin = MAX(0, pos - 30);
            NSInteger posMax = MIN(pos + 30, [text length] - 1);
            
            NSString* extractedText = [text substringWithRange:NSMakeRange(posMin, posMax - posMin)];
            NSString* error = [NSString stringWithFormat:@"%@\nline %ld\n'%@'", e.reason, (long int)[info[@"lineNumber"] integerValue], extractedText];
            [HBHandlebars log:1 object:error];
        }
        @throw;
    }
    
    return program;
}

@end
