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
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}yes{{/a}}" withContext:@{ @"a" : @"a simple value" }],
                          @"yes");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}no{{/a}}yes" withContext:@{ @"b" : @"a simple value" }],
                          @"yes");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}yes{{/a}}" withContext:@{ @"a" : @true }],
                          @"yes");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}no{{/a}}yes" withContext:@{ @"a" : @false }],
                          @"yes");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}yes{{/a}}" withContext:@{ @"a" : @{ @"b" : @""} }],
                          @"yes");
    
}

- (void)testSimpleDeepBlocks
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}{{b}}{{/a}}" withContext:@{ @"a" : @{ @"b" : @"yes" } }],
                          @"yes");
}

- (void)testArrayBlocks {
    id context = @{ @"a" : @[
                            @{ @"value" : @"1" },
                            @{ @"value" : @"2" },
                            @{ @"value" : @"3" }
                            ]
                    };
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#a}}-{{value}}-{{/a}}" withContext:context ],
                          @"-1--2--3-");
}


#pragma mark -
#pragma mark Tests from Handlebars.js

// array
- (void)testArray
{
    NSString* string = @"{{#goodbyes}}{{text}}! {{/goodbyes}}cruel {{world}}!";
    id hash = @{@"goodbyes": @[@{@"text": @"goodbye"}, @{@"text": @"Goodbye"}, @{@"text": @"GOODBYE"}], @"world": @"world"};
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash],
                          @"goodbye! Goodbye! GOODBYE! cruel world!");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:(@{@"goodbyes": @[], @"world": @"world"})],
                          @"cruel world!");
    
}
// array with @index
- (void)testArrayWithAtIndex
{
    NSString* string = @"{{#goodbyes}}{{@index}}. {{text}}! {{/goodbyes}}cruel {{world}}!";
    id hash = @{@"goodbyes": @[@{@"text": @"goodbye"}, @{@"text": @"Goodbye"}, @{@"text": @"GOODBYE"}], @"world": @"world"};
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash],
                          @"0. goodbye! 1. Goodbye! 2. GOODBYE! cruel world!");
}

// empty block
- (void)testEmptyBlock
{
    NSString* string = @"{{#goodbyes}}{{/goodbyes}}cruel {{world}}!";
    id hash = @{@"goodbyes": @[@{@"text": @"goodbye"}, @{@"text": @"Goodbye"}, @{@"text": @"GOODBYE"}], @"world": @"world"};
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash],
                          @"cruel world!");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:(@{@"goodbyes": @[], @"world": @"world"})],
                          @"cruel world!");
}

// block with complex lookup
- (void)testBlockWithComplexLookup
{
    NSString* string = @"{{#goodbyes}}{{text}} cruel {{../name}}! {{/goodbyes}}";
    id hash = @{@"name": @"Alan", @"goodbyes": @[@{@"text": @"goodbye"}, @{@"text": @"Goodbye"}, @{@"text": @"GOODBYE"}]};
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash],
                          @"goodbye cruel Alan! Goodbye cruel Alan! GOODBYE cruel Alan! ");
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
    NSString* string = @"{{#outer}}Goodbye {{#inner}}cruel {{../../omg}}{{/inner}}{{/outer}}";
    id hash = @{@"omg": @"OMG!", @"outer": @[@{ @"inner": @[@{ @"text": @"goodbye" }] }] };
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash],
                          @"Goodbye cruel OMG!");
}

// inverted sections with unset value
- (void)testInvertedSectionsWithUnsetValue
{
    NSString* string = @"{{#goodbyes}}{{this}}{{/goodbyes}}{{^goodbyes}}Right On!{{/goodbyes}}";
    id hash = @{};
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash],
                          @"Right On!");
}

// inverted section with false value
- (void)testInvertedSectionWithFalseValue
{
    NSString* string = @"{{#goodbyes}}{{this}}{{/goodbyes}}{{^goodbyes}}Right On!{{/goodbyes}}";
    id hash = @{@"goodbyes": @false};
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash],
                          @"Right On!");}

//inverted section with empty set
- (void)testInvertedSectionWithEmptySet
{
    NSString* string = @"{{#goodbyes}}{{this}}{{/goodbyes}}{{^goodbyes}}Right On!{{/goodbyes}}";
    id hash = @{@"goodbyes": @[]};
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash],
                          @"Right On!");}

// block inverted sections
- (void)testBlockInvertedSection
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#people}}{{name}}{{^}}{{none}}{{/people}}" withContext:@{@"none": @"No people"}],
                          @"No people");
}

// block inverted sections with empty arrays
- (void)testBlockInvertedSectionsWithEmptyArrays
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#people}}{{name}}{{^}}{{none}}{{/people}}" withContext:(@{@"none": @"No people", @"people": @[]})],
                          @"No people");
}



@end
