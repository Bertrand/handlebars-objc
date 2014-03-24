//
//  HBTestWhitespaceControl.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 3/23/14.
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

#import "HBTestCase.h"
#import "HBHandlebars.h"


@interface HBTestWhitespaceControl : HBTestCase

@end

@implementation HBTestWhitespaceControl

- (void)testShouldStripWhitespaceAroundMustacheCalls
{
    NSError* error = nil;
    id hash = @{ @"foo" : @"bar<" };
    
    NSString* result = [self renderTemplate:@" {{~foo~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar&lt;");
    
    result = [self renderTemplate:@" {{~foo}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar&lt; ");
 
    result = [self renderTemplate:@" {{foo~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar&lt;");
    
    result = [self renderTemplate:@" {{~&foo~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar<");
    
    result = [self renderTemplate:@" {{~{foo}~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar<");

}

- (void)testShouldStripWhitespaceAroundSimpleBlockCalls
{
    NSError* error = nil;
    id hash = @{ @"foo" : @"bar<" };
    
    NSString* result = [self renderTemplate:@" {{~#if foo~}} bar {{~/if~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar");
    
    result = [self renderTemplate:@" {{#if foo~}} bar {{/if~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar ");
    
    result = [self renderTemplate:@" {{~#if foo}} bar {{~/if}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar ");
    
    result = [self renderTemplate:@" {{#if foo}} bar {{/if}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"  bar  ");
}

- (void)testShouldStripWhitespaceAroundInverseBlockCalls
{
    NSError* error = nil;
    id hash = @{};
    
    NSString* result = [self renderTemplate:@" {{~^if foo~}} bar {{~/if~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar");
    
    result = [self renderTemplate:@" {{^if foo~}} bar {{/if~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar ");
    
    result = [self renderTemplate:@" {{~^if foo}} bar {{~/if}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar ");
    
    result = [self renderTemplate:@" {{^if foo}} bar {{/if}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"  bar  ");
}

- (void)testShouldStripWhitespaceAroundComplexBlockCalls
{
    NSError* error = nil;
    id hash = @{ @"foo" : @"bar<" };
    
    NSString* result = [self renderTemplate:@"{{#if foo~}} bar {{~^~}} baz {{~/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar");
    
    result = [self renderTemplate:@"{{#if foo~}} bar {{^~}} baz {{/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar ");
    
    result = [self renderTemplate:@"{{#if foo}} bar {{~^~}} baz {{~/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar");
    
    result = [self renderTemplate:@"{{#if foo}} bar {{^~}} baz {{/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar ");
    
    result = [self renderTemplate:@"{{#if foo~}} bar {{~else~}} baz {{~/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar");
    
    hash = @{};
    
    result = [self renderTemplate:@"{{#if foo~}} bar {{~^~}} baz {{~/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"baz");
    
    result = [self renderTemplate:@"{{#if foo}} bar {{~^~}} baz {{/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"baz ");
    
    result = [self renderTemplate:@"{{#if foo~}} bar {{~^}} baz {{~/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" baz");
    
    result = [self renderTemplate:@"{{#if foo~}} bar {{~^}} baz {{/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" baz ");
    
    result = [self renderTemplate:@"{{#if foo~}} bar {{~else~}} baz {{~/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"baz");
}

- (void)testShouldStripWhitespaceAroundPartials
{
    NSError* error = nil;
    id hash = @{};
    id partials = @{ @"dude" : @"bar" };
    
    NSString* result = [self renderTemplate:@"foo {{~> dude~}} " withContext:hash withPartials:partials error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"foobar");
    
    result = [self renderTemplate:@"foo {{> dude~}} " withContext:hash withPartials:partials error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"foo bar");
    
    result = [self renderTemplate:@"foo {{> dude}} " withContext:hash withPartials:partials error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"foo bar ");
}

- (void)testShouldOnlyStripWhitespaceOnce
{
    NSError* error = nil;
    id hash = @{ @"foo" : @"bar" };
    
    NSString* result = [self renderTemplate:@" {{~foo~}} {{foo}} {{foo}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"barbar bar ");
}

@end
