//
//  HBTemplate_Private.h
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

#import "HBTemplate.h"
#import "HBEscapingFunctions.h"

@class HBAstProgram;
@class HBExecutionContext;
@class HBPartial;

@interface HBTemplate()

@property (readwrite) BOOL compiled;
@property (retain, nonatomic) HBAstProgram* program;
@property (retain, nonatomic) HBExecutionContext* templateLocalExecutionContext;
@property (retain, nonatomic) HBExecutionContext* sharedExecutionContext;

- (HBHelper*) helperForName:(NSString*)name;
- (HBPartial*) partialForName:(NSString*)name;

- (NSString*) escapeString:(NSString*)rawString forTargetFormat:(NSString*)formatName;

@end
