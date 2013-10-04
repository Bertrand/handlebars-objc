//
//  HBTestSimpleTags.m
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


@interface HBTestSimpleTags : XCTestCase

@end

@implementation HBTestSimpleTags



- (void)testRawTextOnly
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"some raw text" withContext:nil],
                          @"some raw text");
}

- (void)testTagWithSimpleKey
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{a}}" withContext:@{ @"a" : @"a simple value"}],
                          @"a simple value");
}

#pragma mark -
#pragma mark Tests from Handlebars.js

// escaping
- (void) testEscaping
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"\\{{foo}}" withContext:@{ @"foo" : @"food" }],
                          @"{{foo}}");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"\\\\{{foo}}" withContext:@{ @"foo" : @"food" }],
                          @"\\food");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"\\\\ {{foo}}" withContext:@{ @"foo" : @"food" }],
                          @"\\\\ food");
}

// compiling with a basic context
- (void) testCompilingWithABasicContext
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Goodbye\n{{cruel}}\n{{world}}!" withContext:(@{ @"cruel": @"cruel", @"world": @"world" })],
                          @"Goodbye\ncruel\nworld!");
}

// comments
- (void) testComments
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{! Goodbye}}Goodbye\n{{cruel}}\n{{world}}!" withContext:(@{ @"cruel": @"cruel", @"world": @"world"})],
                          @"Goodbye\ncruel\nworld!");
}

// boolean
- (void) testBoolean
{
    NSString* string   = @"{{#goodbye}}GOODBYE {{/goodbye}}cruel {{world}}!";
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:(@{@"goodbye": @true, @"world": @"world"})],
                          @"GOODBYE cruel world!");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:(@{@"goodbye": @false, @"world": @"world"})],
                          @"cruel world!");
}

// zeros
- (void) testZeros
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"num1: {{num1}}, num2: {{num2}}" withContext:(@{@"num1": @(42), @"num2": @(0)})],
                          @"num1: 42, num2: 0");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"num: {{.}}" withContext:@0],
                          @"num: 0");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"num: {{num1/num2}}" withContext:(@{ @"num1": @{ @"num2": @0}})],
                          @"num: 0");
}

// newlines
- (void) testNewlines
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Alan's\nTest" withContext:nil],
                          @"Alan's\nTest");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Alan's\rTest" withContext:nil],
                          @"Alan's\rTest");
}

// escaping text
- (void) testEscapingText
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Awesome's" withContext:nil],
                          @"Awesome's");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Awesome\\" withContext:nil],
                          @"Awesome\\");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Awesome\\\\ foo" withContext:nil],
                          @"Awesome\\\\ foo");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Awesome {{foo}}" withContext:@{@"foo": @"\\"}],
                          @"Awesome \\");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@" \" \" " withContext:nil],
                          @" \" \" ");
}

// escaping expressions
- (void) testEscapingExpressions
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{{awesome}}}" withContext:@{ @"awesome": @"&\"\\<>" }],
                          @"&\"\\<>");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{&awesome}}" withContext:@{ @"awesome": @"&\"\\<>" }],
                          @"&\"\\<>");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{awesome}}" withContext:@{ @"awesome": @"&\"'`\\<>"}],
                          @"&amp;&quot;&apos;`\\&lt;&gt;");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{awesome}}" withContext:@{ @"awesome": @"Escaped, <b> looks like: &lt;b&gt;"}],
                          @"Escaped, &lt;b&gt; looks like: &amp;lt;b&amp;gt;");
}

// paths with hyphens
- (void) testPathsWithHyphens
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{foo-bar}}" withContext:@{@"foo-bar": @"baz"}],
                          @"baz");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{foo.foo-bar}}" withContext:(@{ @"foo": @{@"foo-bar": @"baz"}})],
                          @"baz");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{foo/foo-bar}}" withContext:(@{ @"foo": @{ @"foo-bar": @"baz"}})],
                          @"baz");
    
}

// nested paths
- (void) testNestedPaths
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Goodbye {{alan/expression}} world!" withContext:@{@"alan": @{@"expression": @"beautiful"}}],
                          @"Goodbye beautiful world!");
}

// nested paths with empty string value
- (void) testNestedPathsWithEmptyStringValue
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Goodbye {{alan/expression}} world!" withContext:(@{@"alan": @{@"expression": @""}})],
                          @"Goodbye  world!");
}

// literal paths
- (void) testLiteralPaths
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Goodbye {{[@alan]/expression}} world!" withContext:(@{@"@alan": @{@"expression": @"beautiful"}})],
                          @"Goodbye beautiful world!");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Goodbye {{[foo bar]/expression}} world!" withContext:(@{@"foo bar": @{@"expression": @"beautiful"}})],
                          @"Goodbye beautiful world!");
}

// literal references
- (void) testLiteralReferences
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Goodbye {{[foo bar]}} world!" withContext:(@{@"foo bar": @"beautiful"})],
                          @"Goodbye beautiful world!");
}

// that current context path ({{.}}) doesn't hit helpers
//- (void) testThatCurrentContextPathDoesntHitHelpers
//{
//    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"test: {{.}}" withContext:[null],
//                           @{helper: "awesome"}]);
//}

// complex but empty paths
- (void) testComplexButEmptyPaths
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{person/name}}" withContext:(@{@"person": @{@"name": @{}}})],
                          @"");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{person/name}}" withContext:(@{@"person": @{}})],
                          @"");
}

// this keyword in paths
- (void) testThisKeywordInPaths
{
    NSString* string = @"{{#goodbyes}}{{this}}{{/goodbyes}}";
    id hash = @{@"goodbyes": @[@"goodbye", @"Goodbye", @"GOODBYE"]};
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash],
                          @"goodbyeGoodbyeGOODBYE");
    
    string = @"{{#hellos}}{{this/text}}{{/hellos}}";
    hash = @{@"hellos": @[@{@"text": @"hello"}, @{@"text": @"Hello"}, @{@"text": @"HELLO"}]};
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash],
                          @"helloHelloHELLO");
}


@end


#if 0
// this keyword in helpers
- (void) testThisKeywordInHelpers
{
    var helpers = {foo: function(value) {
        return 'bar ' + value;
    }};
    NSString* string = @"{{#goodbyes}}{{foo this}}{{/goodbyes}}";
    var hash = {goodbyes: ["goodbye", "Goodbye", "GOODBYE"]};
    shouldCompileTo(string, [hash, helpers], "bar goodbyebar Goodbyebar GOODBYE",
                    "This keyword in paths evaluates to current context");
    
    string = "{{#hellos}}{{foo this/text}}{{/hellos}}";
    hash = {hellos: [{text: "hello"}, {text: "Hello"}, {text: "HELLO"}]};
    shouldCompileTo(string, [hash, helpers], "bar hellobar Hellobar HELLO", "This keyword evaluates in more complex paths");
}

// this keyword nested inside helpers param
- (void) testThisKeywordNestedInsideHelpersParam
{
    NSString* string = @"{{#hellos}}{{foo text/this/foo}}{{/hellos}}";
    (function() {
        CompilerContext.compile(string);
    }).should.throw(Error);
}
}
#endif
