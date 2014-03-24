//
//  HBTestPartials.m
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

#import <XCTest/XCTest.h>
#import "HBHandlebars.h"

@interface HBTestPartials : XCTestCase

@end

NSString* renderWithPartialsReturningError(NSString* string, id context, NSDictionary* partials, NSError** error)
{
    return [HBHandlebars renderTemplateString:string withContext:context withHelperBlocks:nil withPartialStrings:partials error:error];
}


NSString* renderWithPartials(NSString* string, id context, NSDictionary* partials)
{
    return renderWithPartialsReturningError(string, context, partials, nil);
}


@implementation HBTestPartials


// basic partials
- (void) testBasicPartials
{
    id string = @"Dudes: {{#dudes}}{{> dude}}{{/dudes}}";
    id partial = @"{{name}} ({{url}}) ";
    id hash = @{ @"dudes": @[ @{ @"name": @"Yehuda", @"url": @"http://yehuda" } ,@{ @"name": @"Alan", @"url": @"http://alan" } ] };
    
    NSString* result = renderWithPartials(string, hash, @{@"dude": partial});
    XCTAssertEqualObjects(result, @"Dudes: Yehuda (http://yehuda) Alan (http://alan) ");
}

// partials with context
- (void) testPartialsWithContext
{
    id string = @"Dudes: {{>dude dudes}}";
    id partial = @"{{#this}}{{name}} ({{url}}) {{/this}}";
    id hash = @{ @"dudes": @[ @{ @"name": @"Yehuda", @"url": @"http://yehuda" } ,@{ @"name": @"Alan", @"url": @"http://alan" } ] };
    
    NSString* result = renderWithPartials(string, hash, @{@"dude": partial});
    XCTAssertEqualObjects(result, @"Dudes: Yehuda (http://yehuda) Alan (http://alan) ");
}

// partials with parameters
- (void) testPartialsWithParameters
{
    id string = @"Dudes: {{#dudes}}{{> dude others=..}}{{/dudes}}";
    id partial = @"{{others.foo}}{{name}} ({{url}}) ";
    id hash = @{ @"foo": @"bar", @"dudes": @[ @{ @"name": @"Yehuda", @"url": @"http://yehuda" } ,@{ @"name": @"Alan", @"url": @"http://alan" } ] };
    
    NSString* result = renderWithPartials(string, hash, @{@"dude": partial});
    XCTAssertEqualObjects(result, @"Dudes: barYehuda (http://yehuda) barAlan (http://alan) ");
}

// partial in a partial
- (void) testPartialInAPartial
{
    id string = @"Dudes: {{#dudes}}{{>dude}}{{/dudes}}";
    id dude = @"{{name}} {{> url}} ";
    id url = @"<a href='{{url}}'>{{url}}</a>";
    id hash = @{ @"dudes": @[ @{ @"name": @"Yehuda", @"url": @"http://yehuda" } ,@{ @"name": @"Alan", @"url": @"http://alan" } ] };
    
    NSString* result = renderWithPartials(string, hash, @{@"dude": dude, @"url" : url});
    XCTAssertEqualObjects(result, @"Dudes: Yehuda <a href='http://yehuda'>http://yehuda</a> Alan <a href='http://alan'>http://alan</a> ");
}

// rendering undefined partial throws an exception
- (void) testRenderingUndefinedPartialThrowsAnException
{
    id string = @"{{> whatever}}";
    id hash = @{};
    
    NSError* error = nil;
    renderWithPartialsReturningError(string, hash, @{}, &error);
    XCTAssert(nil != error, @"using an undefined partial should return an error at render time");
}

// GH-14: a partial preceding a selector
- (void) testAPartialPrecedingASelector
{
    id string = @"Dudes: {{>dude}} {{another_dude}}";
    id dude = @"{{name}}";
    id hash = @{ @"name": @"Jeepers", @"another_dude": @"Creepers" };
    
    NSString* result = renderWithPartials(string, hash, @{@"dude": dude});
    XCTAssertEqualObjects(result, @"Dudes: Jeepers Creepers");
}

// Partials with slash paths
- (void) testPartialsWithSlashPaths
{
    id string = @"Dudes: {{> shared/dude}}";
    id dude = @"{{name}}";
    id hash = @{ @"name": @"Jeepers", @"another_dude": @"Creepers" };
    
    NSString* result = renderWithPartials(string, hash, @{@"shared/dude": dude});
    XCTAssertEqualObjects(result, @"Dudes: Jeepers");
}

// Partials with slash and point paths
- (void) testPartialsWithSlashAndPointPaths
{
    id string = @"Dudes: {{> shared/dude.thing}}";
    id dude = @"{{name}}";
    id hash = @{ @"name": @"Jeepers", @"another_dude": @"Creepers" };
    
    NSString* result = renderWithPartials(string, hash, @{@"shared/dude.thing": dude});
    XCTAssertEqualObjects(result, @"Dudes: Jeepers");
}

// Global Partials
- (void) testGlobalPartials
{
    [[HBExecutionContext globalExecutionContext].partials registerPartialStrings:@{ @"global_test" : @"{{another_dude}}" }];
    
    id string = @"Dudes: {{> shared/dude}} {{> global_test}}";
    id dude = @"{{name}}";
    id hash = @{ @"name": @"Jeepers", @"another_dude": @"Creepers" };
    
    NSString* result = renderWithPartials(string, hash, @{@"shared/dude": dude});
    [[HBExecutionContext globalExecutionContext].partials unregisterAllPartials]; // cleanup global partials list
    XCTAssertEqualObjects(result, @"Dudes: Jeepers Creepers");
}

// Multiple partial registration
- (void) testMultiplePartialRegistration
{
    [[HBExecutionContext globalExecutionContext].partials registerPartialStrings:@{ @"global_test" : @"{{another_dude}}", @"shared/dude": @"{{name}}" }];
    
    id string = @"Dudes: {{> shared/dude}} {{> global_test}}";
    id hash = @{ @"name": @"Jeepers", @"another_dude": @"Creepers" };
    
    NSString* result = renderWithPartials(string, hash, @{});
    [[HBExecutionContext globalExecutionContext].partials unregisterAllPartials]; // cleanup global partials list
    XCTAssertEqualObjects(result, @"Dudes: Jeepers Creepers");
}

// Partials with integer path
- (void) testPartialsWithIntegerPath
{
    id string = @"Dudes: {{> 404}}";
    id dude = @"{{name}}";
    id hash = @{ @"name": @"Jeepers", @"another_dude": @"Creepers" };
    
    NSString* result = renderWithPartials(string, hash, @{@"404": dude});
    XCTAssertEqualObjects(result, @"Dudes: Jeepers");
}

// Partials with complex path
- (void) testPartialsWithComplexPath
{
    id string = @"Dudes: {{> 404/asdf?.bar}}";
    id dude = @"{{name}}";
    id hash = @{ @"name": @"Jeepers", @"another_dude": @"Creepers" };
    
    NSString* result = renderWithPartials(string, hash, @{@"404/asdf?.bar": dude});
    XCTAssertEqualObjects(result, @"Dudes: Jeepers");
}

// Partials with escaped
- (void) testPartialsWithEscaped
{
    id string = @"Dudes: {{> [+404/asdf?.bar]}}";
    id dude = @"{{name}}";
    id hash = @{ @"name": @"Jeepers", @"another_dude": @"Creepers" };
    
    NSString* result = renderWithPartials(string, hash, @{@"+404/asdf?.bar": dude});
    XCTAssertEqualObjects(result, @"Dudes: Jeepers");
}

// Partials with string
- (void) testPartialsWithString
{
    id string = @"Dudes: {{> \"+404/asdf?.bar\"}}";
    id dude = @"{{name}}";
    id hash = @{ @"name": @"Jeepers", @"another_dude": @"Creepers" };
    
    NSString* result = renderWithPartials(string, hash, @{@"+404/asdf?.bar": dude});
    XCTAssertEqualObjects(result, @"Dudes: Jeepers");
}

// Handle empty partial
- (void) testHandleEmptyPartial
{
    id string = @"Dudes: {{#dudes}}{{> dude}}{{/dudes}}";
    id partial = @"";
    id hash = @{ @"dudes": @[ @{ @"name": @"Yehuda", @"url": @"http://yehuda" } ,@{ @"name": @"Alan", @"url": @"http://alan" } ] };
    
    NSString* result = renderWithPartials(string, hash, @{@"dude": partial});
    XCTAssertEqualObjects(result, @"Dudes: ");
}

@end
