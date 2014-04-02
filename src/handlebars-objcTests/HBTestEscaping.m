//
//  HBTestEscaping.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 11/2/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HBHandlebars.h"
@interface HBTestEscaping : XCTestCase

@end

@interface HBTestEscapingDelegate : NSObject<HBExecutionContextDelegate>
- (NSString*) escapeString:(NSString*)rawString forTargetFormat:(NSString*)formatName forExecutionContext:(HBExecutionContext*)executionContext;
@end

@implementation HBTestEscaping

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSString*)renderWithDelegate:(NSString*)string withContext:(id)context error:(NSError**)error
{
    HBTestEscapingDelegate* delegate = [[HBTestEscapingDelegate new] autorelease];
    HBExecutionContext* executionContext = [[HBExecutionContext new] autorelease];
    executionContext.delegate = delegate;
    HBTemplate* template = [executionContext templateWithString:string];

    return [template renderWithContext:context error:error];
}

- (void) testSimpleHTMLEscaping
{
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#setEscaping 'text/html'}}{{{awesome}}}{{/setEscaping}}" withContext:@{ @"awesome": @"&\"\\<>" } error:&error],
                          @"&\"\\<>");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#setEscaping 'text/html'}}{{&awesome}}{{/setEscaping}}" withContext:@{ @"awesome": @"&\"\\<>" } error:&error],
                          @"&\"\\<>");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#setEscaping 'text/html'}}{{awesome}}{{/setEscaping}}" withContext:@{ @"awesome": @"&\"'`\\<>"} error:&error],
                          @"&amp;&quot;&apos;`\\&lt;&gt;");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testSimpleCustomEscaping
{
    NSError* error = nil;
    XCTAssertEqualObjects([self renderWithDelegate:@"{{#setEscaping 'text/format1'}}{{{awesome}}}{{/setEscaping}}" withContext:@{ @"awesome": @"&\"\\<>" } error:&error],
                          @"&\"\\<>");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self renderWithDelegate:@"{{#setEscaping 'text/format1'}}{{&awesome}}{{/setEscaping}}" withContext:@{ @"awesome": @"&\"\\<>" } error:&error],
                          @"&\"\\<>");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self renderWithDelegate:@"{{#setEscaping 'text/format1'}}{{awesome}}{{/setEscaping}}" withContext:@{ @"awesome": @"&\"'`\\<>"} error:&error],
                          @"format1");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testNestedCustomDefaultEscaping
{
    NSError* error = nil;

    XCTAssertEqualObjects([self renderWithDelegate:@"{{#setEscaping 'text/format1'}}{{awesome}} - {{#setEscaping 'text/html'}}{{awesome}}{{/setEscaping}} - {{awesome}}{{/setEscaping}}" withContext:@{ @"awesome": @"&\"'`\\<>"} error:&error],
                          @"format1 - &amp;&quot;&apos;`\\&lt;&gt; - format1");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testNestedCustomCustomEscaping
{
    NSError* error = nil;
    
    XCTAssertEqualObjects([self renderWithDelegate:@"{{#setEscaping 'text/format1'}}{{awesome}} - {{#setEscaping 'text/format2'}}{{awesome}}{{/setEscaping}} - {{awesome}}{{/setEscaping}}" withContext:@{ @"awesome": @"&\"'`\\<>"} error:&error],
                          @"format1 - format2 - format1");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testExpressionEscaping
{
    NSError* error = nil;

    XCTAssertEqualObjects([self renderWithDelegate:@"{{escape 'text/format1' awesome}}" withContext:@{ @"awesome": @"&\"'`\\<>"} error:&error],
                          @"format1");
    XCTAssert(!error, @"evaluation should not generate an error");
}
    
- (void) testQueryParamEscaping
{
    NSError* error = nil;
    
    XCTAssertEqualObjects([self renderWithDelegate:@"http://google.com/?q={{escape 'text/x-query-parameter' word}}" withContext:@{ @"word": @"R&D"} error:&error],
                          @"http://google.com/?q=R%26D");
    XCTAssert(!error, @"evaluation should not generate an error");
}
@end

@implementation HBTestEscapingDelegate

- (NSString*) escapeString:(NSString*)rawString forTargetFormat:(NSString*)formatName forExecutionContext:(HBExecutionContext*)executionContext
{
    if ([formatName isEqual:@"text/format1"]) {
        return @"format1";
    }
    if ([formatName isEqual:@"text/format2"]) {
        return @"format2";
    }
    return nil;
}

@end