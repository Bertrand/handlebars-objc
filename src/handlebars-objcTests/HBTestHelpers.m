//
//  HBTestHelpers.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/2/13.
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


@interface HBTestHelpers : XCTestCase

@end

NSString* renderWithHelpersReturningError(NSString* string, id context, NSDictionary* blocks, NSError** error)
{
    HBTemplate* template = [[HBTemplate alloc] initWithString:string];
    [template.helpers registerHelperBlocks:blocks];
    
    NSString* result = [template renderWithContext:context error:error];
    [template release];
    return result;
}

NSString* renderWithHelpers(NSString* string, id context, NSDictionary* blocks)
{
    return renderWithHelpersReturningError(string, context, blocks, nil);
}



@implementation HBTestHelpers
    
- (HBHelperBlock) worldStringHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        return @"world";
    };
}

- (HBHelperBlock) helpersStringHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        return @"helpers";
    };
}

- (HBHelperBlock) linkHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        return [NSString stringWithFormat:@"<a href='%@/%@'>%@</a>", callingInfo[0], callingInfo.context[@"url"], callingInfo.context[@"text"]];
    };
}

- (HBHelperBlock) helloHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        return [NSString stringWithFormat:@"Hello %@", callingInfo[0]];
    };
}

- (HBHelperBlock) formHelperUsingContext
{
    return ^(HBHelperCallingInfo* callingInfo) {
        return [NSString stringWithFormat:@"<form>%@</form>", callingInfo.statements(callingInfo.context, callingInfo.data)];
    };
}

- (HBHelperBlock) formHelperUsingParamAsContext
{
    return ^(HBHelperCallingInfo* callingInfo) {
        id paramValue = callingInfo[0];
        return [NSString stringWithFormat:@"<form>%@</form>", callingInfo.statements(paramValue, callingInfo.data)];
    };
}

- (HBHelperBlock) rawHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        NSString* result = callingInfo.statements(callingInfo.context, callingInfo.data);
        for (NSString* param in callingInfo.positionalParameters) {
            result = [result stringByAppendingFormat:@" %@", param];
        }
        return result;
    };
}

- (void) testBasicValueHelper
{
    
    NSString* result = renderWithHelpers(@"{{returnFoo}}", nil, @{ @"returnFoo" : ^(HBHelperCallingInfo* callingInfo) {
        return @"foo";
    }});
    
    XCTAssertEqualObjects(result, @"foo");
}

- (void) testBasicValueConcatenatingParamHelper
{
    HBHelperBlock block = ^(HBHelperCallingInfo* callingInfo) {
        NSString* positionalParamsString = [callingInfo.positionalParameters componentsJoinedByString:@" "];
        if (positionalParamsString == nil) positionalParamsString = @"";
        NSMutableString* result = [positionalParamsString mutableCopy];
        
        if (callingInfo.namedParameters && callingInfo.namedParameters.count > 0) {
            NSArray* orderedNames = [[callingInfo.namedParameters allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            for (NSString* name in orderedNames) {
                [result appendFormat:@" %@:%@", name, callingInfo[name]];
            }
        }
        return result;
    };
    
    NSString* result = renderWithHelpers(@"{{concatParams p1 p2 k1=v1 k2=\"v2\"}}", @{ @"p1": @"param1", @"p2": @"param2", @"v1": @"value1" }, @{ @"concatParams": block});
    
    XCTAssertEqualObjects(result, @"param1 param2 k1:value1 k2:v2");
}

#pragma mark -
#pragma mark Tests from Handlebars.js

// helper with complex lookup
- (void) testHelperWithComplexLookup
{
    id string = @"{{#goodbyes}}{{{link ../prefix}}}{{/goodbyes}}";
    id hash = @{ @"prefix": @"/root", @"goodbyes": @[ @{ @"text": @"Goodbye", @"url": @"goodbye" } ] };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"link" : [self linkHelper]});
    XCTAssertEqualObjects(result, @"<a href='/root/goodbye'>Goodbye</a>");
}


// helper with complex lookup
- (void) testHelperForRawBlockGetsRawContent
{
    id string = @"{{{{raw}}}} {{test}} {{{{/raw}}}}";
    id hash = @{ @"test" : @"hello" };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"raw" : [self rawHelper]});
    XCTAssertEqualObjects(result, @" {{test}} ");
}

// helper for raw block gets parameters
- (void) testHelperForRawBlockGetsParameters
{
    id string = @"{{{{ raw 1 2 3 }}}} {{test}} {{{{/raw}}}}";
    id hash = @{ @"test" : @"hello" };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"raw" : [self rawHelper]});
    XCTAssertEqualObjects(result, @" {{test}}  1 2 3");
}

// helper block with complex lookup expression
- (void) testHelperBlockWithComplexLookupExpression
{
    id string = @"{{#goodbyes}}{{../name}}{{/goodbyes}}";
    id hash = @{ @"name": @"Alan" };
    
    HBHelperBlock block = ^(HBHelperCallingInfo* callingInfo) {
        NSMutableString* result = [NSMutableString string];
        NSString* blockContent = callingInfo.statements(callingInfo.context, callingInfo.data);
        for (NSString* bye in @[ @"Goodbye" ,@"goodbye" ,@"GOODBYE" ]) {
            [result appendFormat:@"%@ %@! ", bye, blockContent];
        }
        
        return result;
    };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"goodbyes" : block});
    XCTAssertEqualObjects(result, @"Goodbye Alan! goodbye Alan! GOODBYE Alan! ");
}

// helper with complex lookup and nested template
- (void) testHelperWithComplexLookupAndNestedTemplate
{
    id string = @"{{#goodbyes}}{{#link ../prefix}}{{text}}{{/link}}{{/goodbyes}}";
    id hash = @{ @"prefix": @"/root", @"goodbyes": @[ @{ @"text": @"Goodbye", @"url": @"goodbye" } ] };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"link" : [self linkHelper]});
    XCTAssertEqualObjects(result, @"<a href='/root/goodbye'>Goodbye</a>");
}

// block helper
- (void) testBlockHelper
{
    id string = @"{{#goodbyes}}{{text}}! {{/goodbyes}}cruel {{world}}!";
    id hash = @{ @"world": @"world"};
    
    HBHelperBlock blockHelper = ^(HBHelperCallingInfo* callingInfo) {
        return callingInfo.statements(@{ @"text": @"GOODBYE" }, callingInfo.data);
    };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"goodbyes" : blockHelper});
    XCTAssertEqualObjects(result, @"GOODBYE! cruel world!");
}

// block helper staying in the same context
- (void) testBlockHelperStayingInTheSameContext
{
    id string = @"{{#form}}<p>{{name}}</p>{{/form}}";
    id hash = @{ @"name": @"Yehuda"};
    
    NSString* result = renderWithHelpers(string, hash, @{ @"form" : [self formHelperUsingContext]});
    XCTAssertEqualObjects(result, @"<form><p>Yehuda</p></form>");
}

// --> Kept name so we know from which test in .js it comes, but 'this' makes no sense objective-C
// Kept test because it's a quite complete use of helpers
- (void) testBlockHelperShouldHaveContextInThis
{
    id string = @"<ul>{{#people}}<li>{{#link}}{{name}}{{/link}}</li>{{/people}}</ul>";
    id hash = @{ @"people": @[
                         @{ @"name": @"Alan", @"id": @1 },
                         @{ @"name": @"Yehuda", @"id": @2 }
                         ]};
    HBHelperBlock blockHelper = ^(HBHelperCallingInfo* callingInfo) {
        return [NSString stringWithFormat:@"<a href=\"/people/%@\">%@</a>", callingInfo.context[@"id"], callingInfo.statements(callingInfo.context, callingInfo.data)];
    };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"link" : blockHelper});
    XCTAssertEqualObjects(result, @"<ul><li><a href=\"/people/1\">Alan</a></li><li><a href=\"/people/2\">Yehuda</a></li></ul>");
}

// block helper for undefined value
- (void) testBlockHelperForUndefinedValue
{
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#empty}}shouldn't render{{/empty}}" withContext:@{} error:nil], @"");
}

// block helper passing a new context
- (void) testBlockHelperPassingANewContext
{
    id string = @"{{#form yehuda}}<p>{{name}}</p>{{/form}}";
    id hash = @{ @"yehuda": @{ @"name": @"Yehuda" } };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"form" : [self formHelperUsingParamAsContext]});
    XCTAssertEqualObjects(result, @"<form><p>Yehuda</p></form>");
}

// block helper passing a complex path context
- (void) testBlockHelperPassingAComplexPathContext
{
    id string = @"{{#form yehuda/cat}}<p>{{name}}</p>{{/form}}";
    id hash = @{ @"yehuda": @{@"name": @"Yehuda", @"cat": @{@"name": @"Harold"}}};
    
    NSString* result = renderWithHelpers(string, hash, @{ @"form" : [self formHelperUsingParamAsContext]});
    XCTAssertEqualObjects(result, @"<form><p>Harold</p></form>");
}

// nested block helpers
- (void) testNestedBlockHelpers
{
    id string = @"{{#form yehuda}}<p>{{name}}</p>{{#link}}Hello{{/link}}{{/form}}";
    id hash = @{ @"yehuda": @{ @"name": @"Yehuda" } };
    
    HBHelperBlock linkHelper = ^(HBHelperCallingInfo* callingInfo) {
        return [NSString stringWithFormat:@"<a href='%@'>%@</a>", callingInfo.context[@"name"], callingInfo.statements(callingInfo.context, callingInfo.data)];
    };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"form" : [self formHelperUsingParamAsContext], @"link": linkHelper});
    XCTAssertEqualObjects(result, @"<form><p>Yehuda</p><a href='Yehuda'>Hello</a></form>");
}

// block helper inverted sections
- (void) testBlockHelperInvertedSections
{
    HBHelperBlock listHelper = ^(HBHelperCallingInfo* callingInfo) {
        NSArray* array = callingInfo[0];
        
        if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
            NSMutableString* result = [NSMutableString string];
            [result appendString:@"<ul>"];
            for (id arrayElement in array) {
                NSString* blockContent = callingInfo.statements(arrayElement, callingInfo.data);
                [result appendFormat:@"<li>%@</li>", blockContent];
            }
            [result appendString:@"</ul>"];
            return (NSString*)result;
        } else {
            return (NSString*)[NSString stringWithFormat:@"<p>%@</p>", callingInfo.inverseStatements(callingInfo.context, callingInfo.data)];
        }
        
        return (NSString*)nil;
    };
    
    id string = @"{{#list people}}{{name}}{{^}}<em>Nobody's here</em>{{/list}}";
    
    id hash = @{ @"people": @[ @{ @"name": @"Alan" } ,@{ @"name": @"Yehuda" } ] };
    id empty = @{@"people": @[]};
    id rootMessage = @{
                       @"people": @[],
                       @"message": @"Nobody's here"
                       };
    
    id messageString = @"{{#list people}}Hello{{^}}{{message}}{{/list}}";
    
    NSString* result = renderWithHelpers(string, hash, @{ @"list": listHelper});
    XCTAssertEqualObjects(result, @"<ul><li>Alan</li><li>Yehuda</li></ul>");
    
    result = renderWithHelpers(string, empty, @{ @"list": listHelper});
    XCTAssertEqualObjects(result, @"<p><em>Nobody's here</em></p>");
    
    result = renderWithHelpers(messageString, rootMessage, @{ @"list": listHelper});
    XCTAssertEqualObjects(result, @"<p>Nobody&apos;s here</p>");
}

// providing a helpers hash
- (void) testProvidingAHelpersHash
{
    NSString* result = renderWithHelpers(@"Goodbye {{cruel}} {{world}}!", @{@"cruel": @"cruel"}, @{ @"world" : [self worldStringHelper]});
    XCTAssertEqualObjects(result, @"Goodbye cruel world!");
    
    result = renderWithHelpers(@"Goodbye {{#iter}}{{cruel}} {{world}}{{/iter}}!", @{@"iter": @[@{@"cruel": @"cruel"}]}, @{ @"world" : [self worldStringHelper]});
    XCTAssertEqualObjects(result, @"Goodbye cruel world!");
}

// in cases of conflict, helpers win
- (void) testInCasesOfConflictHelpersWin
{
    NSString* result = renderWithHelpers(@"{{{lookup}}}", @{@"lookup": @"Explicit"}, @{ @"lookup" : [self helpersStringHelper]});
    XCTAssertEqualObjects(result, @"helpers");
    
    result = renderWithHelpers(@"{{lookup}}", @{@"lookup": @"Explicit"}, @{ @"lookup" : [self helpersStringHelper]});
    XCTAssertEqualObjects(result, @"helpers");
}

// in cases of conflict, scoped context values win
- (void) testInCasesOfConflictScopedContextValueWin
{
    NSString* result = renderWithHelpers(@"{{{this.lookup}}}", @{@"lookup": @"Explicit"}, @{ @"lookup" : [self helpersStringHelper]});
    XCTAssertEqualObjects(result, @"Explicit");
    
    result = renderWithHelpers(@"{{this.lookup}}", @{@"lookup": @"Explicit"}, @{ @"lookup" : [self helpersStringHelper]});
    XCTAssertEqualObjects(result, @"Explicit");
}

// the helpers hash is available is nested contexts
- (void) testTheHelpersHashIsAvailableIsNestedContexts
{
    NSString* result = renderWithHelpers(@"{{#outer}}{{#inner}}{{helpers}}{{/inner}}{{/outer}}", @{@"outer": @{@"inner": @{@"unused":@[]}}}, @{ @"helpers" : [self helpersStringHelper]});
    XCTAssertEqualObjects(result, @"helpers");
}


- (void) testDecimalNumberLiteralsWork
{
    HBHelperBlock helloHelper = ^(HBHelperCallingInfo* callingInfo) {
        id times = callingInfo[0];
        return [times isKindOfClass:[NSNumber class]] ? [NSString stringWithFormat:@"Hello %@ times", times] : @"Nan";
    };
    
    id string = @"Message: {{hello -12.24}}";
    id hash = @{  };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"hello" : helloHelper});
    XCTAssertEqualObjects(result, @"Message: Hello -12.24 times");
}

// negative number literals work
- (void) testNegativeNumberLiteralsWork
{
    HBHelperBlock helloHelper = ^(HBHelperCallingInfo* callingInfo) {
        id times = callingInfo[0];
        return [times isKindOfClass:[NSNumber class]] ? [NSString stringWithFormat:@"Hello %@ times", times] : @"Nan";
    };
    
    id string = @"Message: {{hello -12}}";
    id hash = @{  };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"hello" : helloHelper});
    XCTAssertEqualObjects(result, @"Message: Hello -12 times");
}



// simple literals work
- (void) testSimpleLiteralsWork
{
    HBHelperBlock helloHelper = ^(HBHelperCallingInfo* callingInfo) {
        id param = callingInfo[0];
        id times = callingInfo[1];
        id bool1 = callingInfo[2];
        id bool2 = callingInfo[3];
        
        if (![times isKindOfClass:[NSNumber class]]) times = @"NaN";
        if (![bool1 isKindOfClass:[NSNumber class]]) times = @"NaN";
        if (![bool2 isKindOfClass:[NSNumber class]]) times = @"NaN";
        
        return [NSString stringWithFormat:@"Hello %@ %@ times: %@ %@", param, times, bool1, bool2];
    };
    
    id string = @"Message: {{hello \"world\" 12 true false}}";
    id hash = @{  };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"hello" : helloHelper});
    XCTAssertEqualObjects(result, @"Message: Hello world 12 times: 1 0");
}

// using a quote in the middle of a parameter raises an error
- (void) testUsingAQuoteInTheMiddleOfAParameterRaisesAnError
{
    id string = @"Message: {{hello wo\"rld\"}}";
    HBTemplate* template = [[HBTemplate alloc] initWithString:string];
    NSError* error = nil;
    [template compile:&error];
    XCTAssert(error != nil, @"erroneus template should generate a parse error");
    [template release];
}


// escaping a String is possible
- (void) testEscapingAStringIsPossible
{
    id string = @"Message: {{{hello \"\\\"world\\\"\"}}}";
    id hash = @{  };
    NSString* result = renderWithHelpers(string, hash, @{ @"hello" : [self helloHelper]});
    XCTAssertEqualObjects(result, @"Message: Hello \"world\"");
}

// it works with ' marks
- (void) testItWorksWithSingleQuoteMarks
{
    id string = @"Message: {{{hello \"Alan's world\"}}}";
    id hash = @{  };
    NSString* result = renderWithHelpers(string, hash, @{ @"hello" : [self helloHelper]});
    XCTAssertEqualObjects(result, @"Message: Hello Alan's world");
}

// simple multi-params work
- (void) testSimpleMultiparamsWork
{
    HBHelperBlock goodbyeHelper = ^(HBHelperCallingInfo* callingInfo) {
        id param1 = callingInfo[0];
        id param2 = callingInfo[1];
        
        return [NSString stringWithFormat:@"Goodbye %@ %@", param1, param2];
    };
    
    id string = @"Message: {{goodbye cruel world}}";
    id hash = @{ @"cruel": @"cruel-", @"world": @"world-" };
    NSString* result = renderWithHelpers(string, hash, @{ @"goodbye" : goodbyeHelper});
    XCTAssertEqualObjects(result, @"Message: Goodbye cruel- world-");
}

// block multi-params work
- (void) testBlockMultiparamsWork
{
    id string = @"Message: {{#goodbye cruel world}}{{greeting}} {{adj}} {{noun}}{{/goodbye}}";
    id hash = @{ @"cruel": @"cruel", @"world": @"world" };
    HBHelperBlock greetingHelper = ^(HBHelperCallingInfo* callingInfo) {
        id param1 = callingInfo[0];
        id param2 = callingInfo[1];
        
        return callingInfo.statements(@{ @"greeting": @"Goodbye", @"adj" : param1, @"noun" : param2}, callingInfo.data);
    };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"goodbye" : greetingHelper});
    XCTAssertEqualObjects(result, @"Message: Goodbye cruel world");
}

// helpers can take an optional hash
- (void) testHelpersCanTakeAnOptionalHash
{
    HBHelperBlock goodbyeHelper = ^(HBHelperCallingInfo* callingInfo) {
        return [NSString stringWithFormat:@"GOODBYE %@ %@ %@ TIMES", callingInfo[@"cruel"], callingInfo[@"world"], callingInfo[@"times"]];
    };
    
    id string = @"{{goodbye cruel='CRUEL' world='WORLD' times=12}}";
    id hash = @{};
    
    NSString* result = renderWithHelpers(string, hash, @{ @"goodbye" : goodbyeHelper});
    XCTAssertEqualObjects(result, @"GOODBYE CRUEL WORLD 12 TIMES");
}

- (void) testHelpersCanTakeAnOptionalHashWithBooleans
{
    HBHelperBlock goodbyeHelper = ^(HBHelperCallingInfo* callingInfo) {
        if ([callingInfo[@"print"] boolValue]) {
            return (NSString*)[NSString stringWithFormat:@"GOODBYE %@ %@", callingInfo[@"cruel"], callingInfo[@"world"]];
        } else {
            return (NSString*)@"NOT PRINTING";
        }
    };
    
    id string = @"{{goodbye cruel='CRUEL' world='WORLD' print=true}}";
    id hash = @{};
    
    NSString* result = renderWithHelpers(string, hash, @{ @"goodbye" : goodbyeHelper});
    XCTAssertEqualObjects(result, @"GOODBYE CRUEL WORLD");
    
    string = @"{{goodbye cruel='CRUEL' world='WORLD' print=false}}";
    result = renderWithHelpers(string, hash, @{ @"goodbye" : goodbyeHelper});
    XCTAssertEqualObjects(result, @"NOT PRINTING");
}

- (void) testBlockHelpersCanTakeAnOptionalHash
{
    id string = @"{{#goodbye cruel=\"CRUEL\" times=12}}world{{/goodbye}}";
    id hash = @{};
    HBHelperBlock greetingHelper = ^(HBHelperCallingInfo* callingInfo) {
        if (callingInfo[@"noprint"] && [callingInfo[@"noprint"] boolValue] == true) {
            return (NSString*)@"NOT PRINTING";
        } else {
            return (NSString*)[NSString stringWithFormat:@"GOODBYE %@ %@ %@ TIMES", callingInfo[@"cruel"], callingInfo.statements(callingInfo.context, callingInfo.data), callingInfo[@"times"]];
        }
    };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"goodbye" : greetingHelper});
    XCTAssertEqualObjects(result, @"GOODBYE CRUEL world 12 TIMES");
    
    string = @"{{#goodbye cruel='CRUEL' times=12}}world{{/goodbye}}";
    result = renderWithHelpers(string, hash, @{ @"goodbye" : greetingHelper});
    XCTAssertEqualObjects(result, @"GOODBYE CRUEL world 12 TIMES");
    
    string = @"{{#goodbye cruel='CRUEL' times=12 noprint=false}}world{{/goodbye}}";
    result = renderWithHelpers(string, hash, @{ @"goodbye" : greetingHelper});
    XCTAssertEqualObjects(result, @"GOODBYE CRUEL world 12 TIMES");
    
    string = @"{{#goodbye cruel='CRUEL' times=12 noprint=true}}world{{/goodbye}}";
    result = renderWithHelpers(string, hash, @{ @"goodbye" : greetingHelper});
    XCTAssertEqualObjects(result, @"NOT PRINTING");
    
}

// if a context is not found, HelperNotFound is used
- (void) testIfAContextIsNotFound
{
    id string = @"{{hello}} {{link_to world}}";
    id hash = @{};
    
    NSError* error = nil;
    renderWithHelpersReturningError(string, hash, @{}, &error);
    
    XCTAssert(nil != error, @"using an undefined helper should return an error at render time");
}

// https://github.com/fotonauts/handlebars-objc/issues/5
- (void) testIssue5
{
    HBHelperBlock ifCondBlock = ^(HBHelperCallingInfo* callingInfo) {
        BOOL operatorResult = false;
        
        id operand1 = callingInfo[0];
        id operator = callingInfo[1];
        id operand2 = callingInfo[2];
        
        if ([operator isEqual:@"=="]) {
            operatorResult = (operand1 == operand2) || [operand1 isEqual:operand2];
        }
        
        if (operatorResult) {
            return callingInfo.statements(callingInfo.context, callingInfo.data);
        } else {
            return callingInfo.inverseStatements(callingInfo.context, callingInfo.data);
        }
    };
    
    id string = @"(a == b): {{#ifCond a '==' b}}true{{^}}false{{/ifCond}}, (a == c): {{#ifCond a '==' c}}true{{^}}false{{/ifCond}}";
    id hash = @{  @"a": @1, @"b" : @1, @"c" : @2 };
    
    NSString* result = renderWithHelpers(string, hash, @{ @"ifCond" : ifCondBlock});
    XCTAssertEqualObjects(result, @"(a == b): true, (a == c): false");
}



/// Unported tests from handlebars.js

#if 0

// if a context is not found, custom helperMissing is used
- (void) testIfAContextIsNotFound,CustomHelpermissingIsUsed
{
    id string = @"{{hello}} {{link_to world}}";
    var context = { hello: "Hello", world: "world" };
    
    var helpers = {
    helperMissing: function(helper, context) {
        if(helper === "link_to") {
            return new Handlebars.SafeString("<a>" + context + "</a>");
        }
    }
    };
    
    shouldCompileTo(string, [context, helpers], "Hello <a>world</a>");
}
}

// Known helper should render helper
- (void) testKnownHelperShouldRenderHelper
{
    var template = CompilerContext.compile("{{hello}}", @{@"knownHelpers": @{@"hello" : @true}});
    
    // var result = template({}, {helpers: {hello: function() { return "foo"; }}}
    equal(result, "foo", "'foo' should === '" + result);
}

// Unknown helper in knownHelpers only mode should be passed as undefined
- (void) testUnknownHelperInKnownhelpersOnlyModeShouldBePassedAsUndefined
{
    var template = CompilerContext.compile("{{typeof hello}}", {knownHelpers: {'typeof': true}, knownHelpersOnly: true})
    
    var result = template({}, {helpers: {'typeof': function(arg) { return typeof arg; }, hello: function() { return "foo"; }}});
    equal(result, "undefined", "'undefined' should === '" + result);
}
// Builtin helpers available in knownHelpers only mode
- (void) testBuiltinHelpersAvailableInKnownhelpersOnlyMode
{
    var template = CompilerContext.compile("{{#unless foo}}bar{{/unless}}", {knownHelpersOnly: true});
    
    var result = template({});
    equal(result, "bar", "'bar' should === '" + result);
}
// Field lookup works in knownHelpers only mode
- (void) testFieldLookupWorksInKnownhelpersOnlyMode
{
    var template = CompilerContext.compile("{{foo}}", {knownHelpersOnly: true});
    
    var result = template({foo: 'bar'});
    equal(result, "bar", "'bar' should === '" + result);
}
// Conditional blocks work in knownHelpers only mode
- (void) testConditionalBlocksWorkInKnownhelpersOnlyMode
{
    var template = CompilerContext.compile("{{#foo}}bar{{/foo}}", {knownHelpersOnly: true});
    
    var result = template({foo: 'baz'});
    equal(result, "bar", "'bar' should === '" + result);
}
// Invert blocks work in knownHelpers only mode
- (void) testInvertBlocksWorkInKnownhelpersOnlyMode
{
    var template = CompilerContext.compile("{{^foo}}bar{{/foo}}", {knownHelpersOnly: true});
    
    var result = template({foo: false});
    equal(result, "bar", "'bar' should === '" + result);
}

// Functions are bound to the context in knownHelpers only mode
- (void) testFunctionsAreBoundToTheContextInKnownhelpersOnlyMode
{
    var template = CompilerContext.compile("{{foo}}", {knownHelpersOnly: true});
    var result = template({foo: function() { return this.bar; }, bar: 'bar'});
    equal(result, "bar", "'bar' should === '" + result);
}

// Unknown helper call in knownHelpers only mode should throw
- (void) testUnknownHelperCallInKnownhelpersOnlyModeShouldThrow
{
    //                                                                                                                                                                                                                                                                                                                                                                                                                                                                                (function() {
    //                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    CompilerContext.compile("{{typeof hello}}", {knownHelpersOnly: true});
    //                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            }).should.throw(Error);
    //                                                                                                                                                                                                                                                                                                                                                                                                                                                                                }
}

// lambdas are resolved by blockHelperMissing, not handlebars proper
- (void) testLambdasAreResolvedByBlockhelpermissing,NotHandlebarsProper
{
    id string = @"{{#truthy}}yep{{/truthy}}";
    var data = { truthy: function() { return true; } };
    shouldCompileTo(string, data, "yep");
}

// lambdas resolved by blockHelperMissing are bound to the context
- (void) testLambdasResolvedByBlockhelpermissingAreBoundToTheContext
{
    id string = @"{{#truthy}}yep{{/truthy}}";
    var boundData = { truthy: function() { return this.truthiness(); }, truthiness: function() { return false; } };
    shouldCompileTo(string, boundData, "");
}


// the helper hash should augment the global hash
- (void) testTheHelperHashShouldAugmentTheGlobalHash
{
    Handlebars.registerHelper('test_helper', function() { return 'found it!'; });
    
    shouldCompileTo(
                    "{{test_helper}} {{#if cruel}}Goodbye {{cruel}} {{world}}!{{/if}}", [
                                                                                         {cruel: "cruel"},
                                                                                         {world: function() { return "world!"; }}
                                                                                         ],
                    "found it! Goodbye cruel world!!");
}


// Multiple global helper registration
- (void) testMultipleGlobalHelperRegistration
{
    var helpers = Handlebars.helpers;
    try {
        Handlebars.helpers = {};
        Handlebars.registerHelper({
            'if': helpers['if'],
        world: function() { return "world!"; },
        test_helper: function() { return 'found it!'; }
        }
                                  
                                  shouldCompileTo(
                                                  "{{test_helper}} {{#if cruel}}Goodbye {{cruel}} {{world}}!{{/if}}",
                                                  [{cruel: "cruel"}],
                                                  "found it! Goodbye cruel world!!");
                                  } finally {
                                      if (helpers) {
                                          Handlebars.helpers = helpers;
                                      }
                                  }
                                  }
                                  
#endif
@end
