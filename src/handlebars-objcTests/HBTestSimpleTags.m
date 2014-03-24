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
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"some raw text" withContext:nil error:&error],
                          @"some raw text");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void)testTagWithSimpleKey
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{a}}" withContext:@{ @"a" : @"a simple value"} error:&error],
                          @"a simple value");
    XCTAssert(!error, @"evaluation should not generate an error");
}

#pragma mark -
#pragma mark Tests from Handlebars.js

// escaping
- (void) testEscaping
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"\\{{foo}}" withContext:@{ @"foo" : @"food" } error:&error],
                          @"{{foo}}");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"content \\{{foo}}" withContext:@{ @"foo" : @"food" } error:&error],
                          @"content {{foo}}");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"\\\\{{foo}}" withContext:@{ @"foo" : @"food" } error:&error],
                          @"\\food");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"content \\\\{{foo}}" withContext:@{ @"foo" : @"food" } error:&error],
                          @"content \\food");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"\\\\ {{foo}}" withContext:@{ @"foo" : @"food" } error:&error],
                          @"\\\\ food");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// compiling with a basic context
- (void) testCompilingWithABasicContext
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Goodbye\n{{cruel}}\n{{world}}!" withContext:(@{ @"cruel": @"cruel", @"world": @"world" }) error:&error],
                          @"Goodbye\ncruel\nworld!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// comments
- (void) testComments
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{! Goodbye}}Goodbye\n{{cruel}}\n{{world}}!" withContext:(@{ @"cruel": @"cruel", @"world": @"world"}) error:&error],
                          @"Goodbye\ncruel\nworld!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// boolean
- (void) testBoolean
{
    NSError* error = nil;
    NSString* string   = @"{{#goodbye}}GOODBYE {{/goodbye}}cruel {{world}}!";
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:(@{@"goodbye": @true, @"world": @"world"}) error:&error],
                          @"GOODBYE cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:(@{@"goodbye": @false, @"world": @"world"}) error:&error],
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// zeros
- (void) testZeros
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"num1: {{num1}}, num2: {{num2}}" withContext:(@{@"num1": @(42), @"num2": @(0)}) error:&error],
                          @"num1: 42, num2: 0");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"num: {{.}}" withContext:@0 error:&error],
                          @"num: 0");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"num: {{num1/num2}}" withContext:(@{ @"num1": @{ @"num2": @0}}) error:&error],
                          @"num: 0");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// newlines
- (void) testNewlines
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Alan's\nTest" withContext:nil error:&error],
                          @"Alan's\nTest");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Alan's\rTest" withContext:nil error:&error],
                          @"Alan's\rTest");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// escaping text
- (void) testEscapingText
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Awesome's" withContext:nil error:&error],
                          @"Awesome's");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Awesome\\" withContext:nil error:&error],
                          @"Awesome\\");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Awesome\\\\ foo" withContext:nil error:&error],
                          @"Awesome\\\\ foo");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Awesome {{foo}}" withContext:@{@"foo": @"\\"} error:&error],
                          @"Awesome \\");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@" \" \" " withContext:nil error:&error],
                          @" \" \" ");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// escaping expressions
- (void) testEscapingExpressions
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{{awesome}}}" withContext:@{ @"awesome": @"&\"\\<>" } error:&error],
                          @"&\"\\<>");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{&awesome}}" withContext:@{ @"awesome": @"&\"\\<>" } error:&error],
                          @"&\"\\<>");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{awesome}}" withContext:@{ @"awesome": @"&\"'`\\<>"} error:&error],
                          @"&amp;&quot;&apos;`\\&lt;&gt;");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{awesome}}" withContext:@{ @"awesome": @"Escaped, <b> looks like: &lt;b&gt;"} error:&error],
                          @"Escaped, &lt;b&gt; looks like: &amp;lt;b&amp;gt;");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// paths with hyphens
- (void) testPathsWithHyphens
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{foo-bar}}" withContext:@{@"foo-bar": @"baz"} error:&error],
                          @"baz");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{foo.foo-bar}}" withContext:(@{ @"foo": @{@"foo-bar": @"baz"}}) error:&error],
                          @"baz");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{foo/foo-bar}}" withContext:(@{ @"foo": @{ @"foo-bar": @"baz"}}) error:&error],
                          @"baz");
    XCTAssert(!error, @"evaluation should not generate an error");
    
}

// nested paths
- (void) testNestedPaths
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Goodbye {{alan/expression}} world!" withContext:@{@"alan": @{@"expression": @"beautiful"}} error:&error],
                          @"Goodbye beautiful world!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// nested paths with empty string value
- (void) testNestedPathsWithEmptyStringValue
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Goodbye {{alan/expression}} world!" withContext:(@{@"alan": @{@"expression": @""}}) error:&error],
                          @"Goodbye  world!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// literal paths
- (void) testLiteralPaths
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Goodbye {{[@alan]/expression}} world!" withContext:(@{@"@alan": @{@"expression": @"beautiful"}}) error:&error],
                          @"Goodbye beautiful world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Goodbye {{[foo bar]/expression}} world!" withContext:(@{@"foo bar": @{@"expression": @"beautiful"}}) error:&error],
                          @"Goodbye beautiful world!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// literal references
- (void) testLiteralReferences
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Goodbye {{[foo bar]}} world!" withContext:(@{@"foo bar": @"beautiful"}) error:&error],
                          @"Goodbye beautiful world!");
    XCTAssert(!error, @"evaluation should not generate an error");
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
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{person/name}}" withContext:(@{@"person": @{@"name": @{}}}) error:&error],
                          @"");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{person/name}}" withContext:(@{@"person": @{}}) error:&error],
                          @"");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// this keyword in paths
- (void) testThisKeywordInPaths
{
    NSError* error = nil;
    NSString* string = @"{{#goodbyes}}{{this}}{{/goodbyes}}";
    id hash = @{@"goodbyes": @[@"goodbye", @"Goodbye", @"GOODBYE"]};
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"goodbyeGoodbyeGOODBYE");
    
    XCTAssert(!error, @"evaluation should not generate an error");
    string = @"{{#hellos}}{{this/text}}{{/hellos}}";
    hash = @{@"hellos": @[@{@"text": @"hello"}, @{@"text": @"Hello"}, @{@"text": @"HELLO"}]};
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"helloHelloHELLO");
    XCTAssert(!error, @"evaluation should not generate an error");
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
