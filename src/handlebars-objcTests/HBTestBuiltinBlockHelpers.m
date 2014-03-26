//
//  HBTestBuiltinBlockHelpers.m
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

@interface HBTestBuiltinBlockHelpers : XCTestCase

@end

@implementation HBTestBuiltinBlockHelpers


// if
- (void) testIf
{
    id string = @"{{#if goodbye}}GOODBYE {{/if}}cruel {{world}}!";
    NSError* error = nil;
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{ @"world": @"world", @"goodbye" : @"true"} error:&error]),
                          @"GOODBYE cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @"dummy", @"world": @"world"} error:&error]),
                          @"GOODBYE cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");

    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @false, @"world": @"world"} error:&error]),
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");

    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"world": @"world"} error:&error]),
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");

    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @[@"foo"], @"world": @"world"} error:&error]),
                          @"GOODBYE cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");

    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @[], @"world": @"world"} error:&error]),
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @0, @"world": @"world"} error:&error]),
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");

    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:@"{{#if goodbye includeZero=true}}GOODBYE {{/if}}cruel {{world}}!" withContext:@{@"goodbye": @0, @"world": @"world"} error:&error]),
                          @"GOODBYE cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// unless
- (void) testUnless
{
    id string = @"{{#unless goodbye}}GOODBYE {{/unless}}cruel {{world}}!";
    NSError* error = nil;
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{ @"world": @"world", @"goodbye" : @"true"} error:&error]),
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @"dummy", @"world": @"world"} error:&error]),
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @false, @"world": @"world"} error:&error]),
                          @"GOODBYE cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"world": @"world"} error:&error]),
                          @"GOODBYE cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @[@"foo"], @"world": @"world"} error:&error]),
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @[], @"world": @"world"} error:&error]),
                          @"GOODBYE cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @0, @"world": @"world"} error:&error]),
                          @"GOODBYE cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:@"{{#unless goodbye includeZero=true}}GOODBYE {{/unless}}cruel {{world}}!" withContext:@{@"goodbye": @0, @"world": @"world"} error:&error]),
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// with
- (void) testWith
{
    NSError* error = nil;
    id string = @"{{#with person}}{{first}} {{last}}{{/with}}";
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"person": @{@"first": @"Alan", @"last": @"Johnson"}} error:&error]), @"Alan Johnson");
    XCTAssert(!error, @"evaluation should not generate an error");
}


// each
- (void) testEach
{
    NSError* error = nil;
    id string = @"{{#each goodbyes}}{{text}}! {{/each}}cruel {{world}}!";
    id hash = @{ @"goodbyes": @[ @{ @"text": @"goodbye" } ,@{ @"text": @"Goodbye" } ,@{ @"text": @"GOODBYE" } ], @"world": @"world" };
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"goodbye! Goodbye! GOODBYE! cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbyes": @[], @"world": @"world"} error:&error]),
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// each with an object and @key
- (void) testEachWithAnObjectAndAtkey
{
    NSError* error = nil;
    
    id string = @"{{#each goodbyes}}{{@key}}. {{text}}! {{/each}}cruel {{world}}!";
    id hash = @{@"goodbyes": @{@"<b>#1</b>": @{@"text": @"goodbye"}, @"2": @{@"text": @"GOODBYE"}}, @"world": @"world"};
    
    id actual = [HBHandlebars renderTemplateString:string withContext:hash error:&error];
    id expected1 = @"&lt;b&gt;#1&lt;/b&gt;. goodbye! 2. GOODBYE! cruel world!";
    id expected2 = @"2. GOODBYE! &lt;b&gt;#1&lt;/b&gt;. goodbye! cruel world!";
    
    XCTAssert([actual isEqual:expected1] || [actual isEqual:expected2], @"each with object argument iterates over the contents when not empty");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbyes": @[], @"world": @"world"} error:&error]),
                          @"cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// each with @index
- (void) testEachWithAtindex
{
    NSError* error = nil;
    id string = @"{{#each goodbyes}}{{@index}}. {{text}}! {{/each}}cruel {{world}}!";
    id hash = @{ @"goodbyes": @[ @{ @"text": @"goodbye" } ,@{ @"text": @"Goodbye" } ,@{ @"text": @"GOODBYE" } ], @"world": @"world" };
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"0. goodbye! 1. Goodbye! 2. GOODBYE! cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// each with nested @index
- (void) testEachWithNestedAtindex
{
    NSError* error = nil;
    id string = @"{{#each goodbyes}}{{@index}}. {{text}}! {{#each ../goodbyes}}{{@index}} {{/each}}After {{@index}} {{/each}}{{@index}}cruel {{world}}!";
    id hash = @{ @"goodbyes": @[ @{ @"text": @"goodbye" } ,@{ @"text": @"Goodbye" } ,@{ @"text": @"GOODBYE" } ], @"world": @"world" };
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"0. goodbye! 0 1 2 After 0 1. Goodbye! 0 1 2 After 1 2. GOODBYE! 0 1 2 After 2 cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// each with @first
- (void) testEachWithAtFirst
{
    NSError* error = nil;
    id string = @"{{#each goodbyes}}{{#if @first}}{{text}}! {{/if}}{{/each}}cruel {{world}}!";
    id hash = @{ @"goodbyes": @[ @{ @"text": @"goodbye" } ,@{ @"text": @"Goodbye" } ,@{ @"text": @"GOODBYE" } ], @"world": @"world" };
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"goodbye! cruel world!", @"The @first variable is used");
    XCTAssert(!error, @"evaluation should not generate an error");
}


// each with nested @first
- (void) testEachWithNestedAtFirst
{
    NSError* error = nil;
    id string = @"{{#each goodbyes}}({{#if @first}}{{text}}! {{/if}}{{#each ../goodbyes}}{{#if @first}}{{text}}!{{/if}}{{/each}}{{#if @first}} {{text}}!{{/if}}) {{/each}}cruel {{world}}!";
    id hash = @{ @"goodbyes": @[ @{ @"text": @"goodbye" } ,@{ @"text": @"Goodbye" } ,@{ @"text": @"GOODBYE" } ], @"world": @"world" };
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"(goodbye! goodbye! goodbye!) (goodbye!) (goodbye!) cruel world!", @"The @first variable is used");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// each with @last
- (void) testEachWithAtLast
{
    NSError* error = nil;
    id string = @"{{#each goodbyes}}{{#if @last}}{{text}}! {{/if}}{{/each}}cruel {{world}}!";
    id hash = @{ @"goodbyes": @[ @{ @"text": @"goodbye" } ,@{ @"text": @"Goodbye" } ,@{ @"text": @"GOODBYE" } ], @"world": @"world" };
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"GOODBYE! cruel world!", @"The @last variable is used");
    XCTAssert(!error, @"evaluation should not generate an error");
}


// each with nested @last
- (void) testEachWithNestedAtLast
{
    NSError* error = nil;
    id string = @"{{#each goodbyes}}({{#if @last}}{{text}}! {{/if}}{{#each ../goodbyes}}{{#if @last}}{{text}}!{{/if}}{{/each}}{{#if @last}} {{text}}!{{/if}}) {{/each}}cruel {{world}}!";
    id hash = @{ @"goodbyes": @[ @{ @"text": @"goodbye" } ,@{ @"text": @"Goodbye" } ,@{ @"text": @"GOODBYE" } ], @"world": @"world" };
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"(GOODBYE!) (GOODBYE!) (GOODBYE! GOODBYE! GOODBYE!) cruel world!", @"The @last variable is used");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// each on implicit context
- (void) testEachOnImplicitContext
{
    NSError* error = nil;
    id string = @"{{#each}}{{text}}! {{/each}}cruel world!";
    id hash = @[ @{ @"text": @"goodbye" } ,@{ @"text": @"Goodbye" } ,@{ @"text": @"GOODBYE" } ];
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"goodbye! Goodbye! GOODBYE! cruel world!");
    XCTAssert(!error, @"evaluation should not generate an error");
}

// #log
- (void) testLog
{
    NSError* error = nil;
    id string = @"{{log blah}}";
    id hash = @{ @"blah": @"whee" };

    __block NSInteger levelArg = -1;
    __block id objectArg = nil;

    [HBHandlebars setLoggerBlock:^(NSInteger level, id object) {
        levelArg = level;
        objectArg = [[object retain] autorelease];
        return (NSString*)nil;
    }];
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:string withContext:hash error:&error],
                          @"");
    XCTAssert(!error, @"evaluation should not generate an error");

    XCTAssert(1L == levelArg, @"should call log with 1");
    XCTAssertEqualObjects(@"whee", objectArg, @"should call log with 'whee'");
    [HBHandlebars setLoggerBlock:nil];
}


@end
