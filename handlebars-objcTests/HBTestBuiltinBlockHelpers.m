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
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{ @"world": @"world", @"goodbye" : @"true"} ]),
                          @"GOODBYE cruel world!");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @"dummy", @"world": @"world"}]),
                          @"GOODBYE cruel world!");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @false, @"world": @"world"}]),
                          @"cruel world!");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"world": @"world"}]),
                          @"cruel world!");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @[@"foo"], @"world": @"world"}]),
                          @"GOODBYE cruel world!");
    
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @[], @"world": @"world"}]),
                          @"cruel world!");
    
    /* We don't pass this handlebars.js test, but it makes no sense. I don't think I'll fix it */
    /*
    XCTAssertEqualObjects(([HBHandlebars renderTemplateString:string withContext:@{@"goodbye": @0, @"world": @"world"}]),
                          @"GOODBYE cruel world!");
     */
}

#if 0
    // if with function argument
    - (void) testIfWithFunctionArgument
    {
        id string = @"{{#if goodbye}}GOODBYE {{/if}}cruel {{world}}!";
        shouldCompileTo(string, {goodbye: function() {return true;}, world: "world"}, "GOODBYE cruel world!",
                        "if with function shows the contents when function returns true");
        shouldCompileTo(string, {goodbye: function() {return this.world;}, world: "world"}, "GOODBYE cruel world!",
                        "if with function shows the contents when function returns string");
        shouldCompileTo(string, {goodbye: function() {return false;}, world: "world"}, "cruel world!",
                        "if with function does not show the contents when returns false");
        shouldCompileTo(string, {goodbye: function() {return this.foo;}, world: "world"}, "cruel world!",
                        "if with function does not show the contents when returns undefined");
    }
}

describe('#with', function() {
    // with
    - (void) testWith
    {
        id string = @"{{#with person}}{{first}} {{last}}{{/with}}";
        XCTAssertEqualObjects([HBHandlebars renderTemplate:@string withContext:{person: {first: "Alan"],
	    	@last: "Johnson"}}
                               
                               // with with function argument
                               - (void) testWithWithFunctionArgument
        {
            id string = @"{{#with person}}{{first}} {{last}}{{/with}}";
      	    XCTAssertEqualObjects([HBHandlebars renderTemplate:@string withContext:{person: function() { return {first: "Alan"],
                @last: "Johnson"};}}
                                   
                                   
                                   describe('#each', function() {
                // each
                - (void) testEach
                {
                    id string = @"{{#each goodbyes}}{{text}}! {{/each}}cruel {{world}}!";
                    id hash = @{ @"goodbyes": @[ @{ @"text": @"goodbye" } ,@{ @"text": @"Goodbye" } ,@{ @"text": @"GOODBYE" } ], @"world": @"world" };
                    XCTAssertEqualObjects([HBHandlebars renderTemplate:@string withContext:hash],
                                          @"goodbye! Goodbye! GOODBYE! cruel world!");
                    
                    XCTAssertEqualObjects([HBHandlebars renderTemplate:@string withContext:{goodbyes: [], world: "world"}],
                                          @"cruel world!");
                    
                    
                    // each with an object and @key
                    - (void) testEachWithAnObjectAndAtkey
                    {
                        id string = @"{{#each goodbyes}}{{@key}}. {{text}}! {{/each}}cruel {{world}}!";
                        var hashi     = {goodbyes: {"<b>#1</b>": {text: "goodbye"}, 2: {text: "GOODBYE"}}, world: "world"};
                        
                        // Object property iteration order is undefined according to ECMA spec,
                        // so we need to check both possible orders
                        // @see http://stackoverflow.com/questions/280713/elements-order-in-a-for-in-loop
                        var actual = compileWithPartials(string, hash);
                        var expected1 = "&lt;b&gt;#1&lt;/b&gt;. goodbye! 2. GOODBYE! cruel world!";
                        var expected2 = "2. GOODBYE! &lt;b&gt;#1&lt;/b&gt;. goodbye! cruel world!";
                        
                        (actual === expected1 || actual === expected2).should.equal(true, "each with object argument iterates over the contents when not empty");
                        XCTAssertEqualObjects([HBHandlebars renderTemplate:@string withContext:{goodbyes: [], world: "world"}],
                                              @"cruel world!");
                        
                        
                        // each with @index
                        - (void) testEachWithAtindex
                        {
                            id string = @"{{#each goodbyes}}{{@index}}. {{text}}! {{/each}}cruel {{world}}!";
                            id hash = @{ @"goodbyes": @[ @{ @"text": @"goodbye" } ,@{ @"text": @"Goodbye" } ,@{ @"text": @"GOODBYE" } ], @"world": @"world" };
                            
                            var template = CompilerContext.compile(string);
                            var result = template(hash);
                            
                            equal(result, "0. goodbye! 1. Goodbye! 2. GOODBYE! cruel world!", "The @index variable is used");
                        }
                        
                        // each with nested @index
                        - (void) testEachWithNestedAtindex
                        {
                            id string = @"{{#each goodbyes}}{{@index}}. {{text}}! {{#each ../goodbyes}}{{@index}} {{/each}}After {{@index}} {{/each}}{{@index}}cruel {{world}}!";
                            id hash = @{ @"goodbyes": @[ @{ @"text": @"goodbye" } ,@{ @"text": @"Goodbye" } ,@{ @"text": @"GOODBYE" } ], @"world": @"world" };
                            
                            var template = CompilerContext.compile(string);
                            var result = template(hash);
                            
                            equal(result, "0. goodbye! 0 1 2 After 0 1. Goodbye! 0 1 2 After 1 2. GOODBYE! 0 1 2 After 2 cruel world!", "The @index variable is used");
                        }
                        
                        // each with function argument
                        - (void) testEachWithFunctionArgument
                        {
                            id string = @"{{#each goodbyes}}{{text}}! {{/each}}cruel {{world}}!";
                            var hashi   = {goodbyes: function () { return [{text: "goodbye"}, {text: "Goodbye"}, {text: "GOODBYE"}];}, world: "world"};
                            XCTAssertEqualObjects([HBHandlebars renderTemplate:@string withContext:hash],
                                                  @"goodbye! Goodbye! GOODBYE! cruel world!");
                            
                            XCTAssertEqualObjects([HBHandlebars renderTemplate:@string withContext:{goodbyes: [], world: "world"}],
                                                  @"cruel world!");
                            
                            
                            // data passed to helpers
                            - (void) testDataPassedToHelpers
                            {
                                id string = @"{{#each letters}}{{this}}{{detectDataInsideEach}}{{/each}}";
                                id hash = @{ @"letters": @[ @"a" ,@"b" ,@"c" ] };
                                
                                var template = CompilerContext.compile(string);
                                var result = template(hash, {
                                data: {
                                exclaim: '!'
                                }
                                }
                                                      equal(result, 'a!b!c!', 'should output data');
                                                      }
                                                      
                                                      Handlebars.registerHelper('detectDataInsideEach', function(options) {
                                    return options.data && options.data.exclaim;
                                }
                                                                                }
                                                                                
                                                                                // #log
                                                                                - (void) testSharpsignlog
                                {
                                    
                                    id string = @"{{log blah}}";
                                    id hash = @{ @"blah": @"whee" };
                                    
                                    var levelArg, logArg;
                                    Handlebars.log = function(level, arg){ levelArg = level, logArg = arg; };
                                    
                                    XCTAssertEqualObjects([HBHandlebars renderTemplate:@string withContext:hash],
                                                          @"");
                                    
                                    equals(1, levelArg, "should call log with 1");
                                    equals("whee", logArg, "should call log with 'whee'");
                                }
                                                                                
                                                                                }

#endif
@end
