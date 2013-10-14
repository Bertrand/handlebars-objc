//
//  HBTestSimpleBlocks.m
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

#import <XCTest/XCTest.h>
#import "HBHandlebars.h"

@interface HBTestSimpleBlocks : XCTestCase

@end

@implementation HBTestSimpleBlocks


- (void)testSimpleBooleanBlock
{
    NSError* error = nil;
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}yes{{/a}}" withContext:@{ @"a" : @"a simple value" } error:&error],
                          @"yes");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}no{{/a}}yes" withContext:@{ @"b" : @"a simple value" } error:&error],
                          @"yes");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}yes{{/a}}" withContext:@{ @"a" : @true } error:&error],
                          @"yes");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}no{{/a}}yes" withContext:@{ @"a" : @false } error:&error],
                          @"yes");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}yes{{/a}}" withContext:@{ @"a" : @{ @"b" : @""} } error:&error],
                          @"yes");
    XCTAssert(!error, @"evaluation should not generate an error");

}

- (void)testSimpleDeepBlocks
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}{{b}}{{/a}}" withContext:@{ @"a" : @{ @"b" : @"yes" } } error:&error],
                          @"yes");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void)testArrayBlocks {
    NSError* error = nil;
    id context = @{ @"a" : @[
                            @{ @"value" : @"1" },
                            @{ @"value" : @"2" },
                            @{ @"value" : @"3" }
                            ]
                    };
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}-{{value}}-{{/a}}" withContext:context  error:&error],
                          @"-1--2--3-");
    XCTAssert(!error, @"evaluation should not generate an error");
}


#pragma mark -
#pragma mark Tests from Handlebars.js

// array
- (void)testArray
{
    NSError* error = nil;
    NSString* string = @"{{#goodbyes}}{{text}}! {{/goodbyes}}cruel {{world}}!";
    id hash = @{@"goodbyes": @[@{@"text": @"goodbye"}, @{@"text": @"Goodbye"}, @{@"text": @"GOODBYE"}], @"world": @"world"};
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"goodbye! Goodbye! GOODBYE! cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:(@{@"goodbyes": @[], @"world": @"world"}) error:&error],
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    
}
// array with @index
- (void)testArrayWithAtIndex
{
    NSError* error = nil;
    NSString* string = @"{{#goodbyes}}{{@index}}. {{text}}! {{/goodbyes}}cruel {{world}}!";
    id hash = @{@"goodbyes": @[@{@"text": @"goodbye"}, @{@"text": @"Goodbye"}, @{@"text": @"GOODBYE"}], @"world": @"world"};
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"0. goodbye! 1. Goodbye! 2. GOODBYE! cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// empty block
- (void)testEmptyBlock
{
    NSError* error = nil;
    NSString* string = @"{{#goodbyes}}{{/goodbyes}}cruel {{world}}!";
    id hash = @{@"goodbyes": @[@{@"text": @"goodbye"}, @{@"text": @"Goodbye"}, @{@"text": @"GOODBYE"}], @"world": @"world"};
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:(@{@"goodbyes": @[], @"world": @"world"}) error:&error],
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// block with complex lookup
- (void)testBlockWithComplexLookup
{
    NSError* error = nil;
    NSString* string = @"{{#goodbyes}}{{text}} cruel {{../name}}! {{/goodbyes}}";
    id hash = @{@"name": @"Alan", @"goodbyes": @[@{@"text": @"goodbye"}, @{@"text": @"Goodbye"}, @{@"text": @"GOODBYE"}]};
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"goodbye cruel Alan! Goodbye cruel Alan! GOODBYE cruel Alan! ");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// block with complex lookup using nested context
//- (void)testBlockWithComplexLookupUsingNestedContext
//{
//    NSString* string = @"{{#goodbyes}}{{text}} cruel {{foo/../name}}! {{/goodbyes}}";
//
//    (function() {
//        CompilerContext.compile(string);
//    }).should.throw(Error);
//}

// block with deep nested complex lookup
- (void)testBlockWithDeepNestedComplexLookup
{
    NSError* error = nil;
    NSString* string = @"{{#outer}}Goodbye {{#inner}}cruel {{../../omg}}{{/inner}}{{/outer}}";
    id hash = @{@"omg": @"OMG!", @"outer": @[@{ @"inner": @[@{ @"text": @"goodbye" }] }] };
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"Goodbye cruel OMG!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// inverted sections with unset value
- (void)testInvertedSectionsWithUnsetValue
{
    NSError* error = nil;
    NSString* string = @"{{#goodbyes}}{{this}}{{/goodbyes}}{{^goodbyes}}Right On!{{/goodbyes}}";
    id hash = @{};
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"Right On!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// inverted section with false value
- (void)testInvertedSectionWithFalseValue
{
    NSError* error = nil;
    NSString* string = @"{{#goodbyes}}{{this}}{{/goodbyes}}{{^goodbyes}}Right On!{{/goodbyes}}";
    id hash = @{@"goodbyes": @false};
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"Right On!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

//inverted section with empty set
- (void)testInvertedSectionWithEmptySet
{
    NSError* error = nil;
    NSString* string = @"{{#goodbyes}}{{this}}{{/goodbyes}}{{^goodbyes}}Right On!{{/goodbyes}}";
    id hash = @{@"goodbyes": @[]};
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"Right On!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// block inverted sections
- (void)testBlockInvertedSection
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#people}}{{name}}{{^}}{{none}}{{/people}}" withContext:@{@"none": @"No people"} error:&error],
                          @"No people");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// block inverted sections with empty arrays
- (void)testBlockInvertedSectionsWithEmptyArrays
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#people}}{{name}}{{^}}{{none}}{{/people}}" withContext:(@{@"none": @"No people", @"people": @[]}) error:&error],
                          @"No people");
    XCTAssert(!error, @"evaluation should not generate an error");
}



@end
