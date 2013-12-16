//
//  HBTestExtraHelpersLibrary.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 12/16/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <HBHandlebars/HBHandlebars.h>

@interface HBTestExtraHelpersLibrary : XCTestCase

@end

@implementation HBTestExtraHelpersLibrary

- (void) testIsBlockHelper
{
    NSError* error = nil;
    
    // test string equality
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#is value 'a'}}true{{else}}false{{/is}}" withContext:@{ @"value" : @"a"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#is value 'b'}}true{{else}}false{{/is}}" withContext:@{ @"value" : @"a"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test boolean equality
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#is value true}}true{{else}}false{{/is}}" withContext:@{ @"value" : @true} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#is value false}}true{{else}}false{{/is}}" withContext:@{ @"value" : @true} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test number equality
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#is value 1}}true{{else}}false{{/is}}" withContext:@{ @"value" : @1} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#is value 1}}true{{else}}false{{/is}}" withContext:@{ @"value" : @2} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // compare strings with integers littlerals
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#is value '1'}}true{{else}}false{{/is}}" withContext:@{ @"value" : @"1"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#is value '1'}}true{{else}}false{{/is}}" withContext:@{ @"value" : @"2"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // compare integers with string litterals
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#is value '1'}}true{{else}}false{{/is}}" withContext:@{ @"value" : @1} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#is value '1'}}true{{else}}false{{/is}}" withContext:@{ @"value" : @2} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // compare floats with string litterals
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#is value '1.1'}}true{{else}}false{{/is}}" withContext:@{ @"value" : @1.1} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#is value '1.1'}}true{{else}}false{{/is}}" withContext:@{ @"value" : @1.2} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testGtBlockHelper
{
    NSError* error = nil;
    
    // test string comparison
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gt value 'b'}}true{{else}}false{{/gt}}" withContext:@{ @"value" : @"c"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gt value 'b'}}true{{else}}false{{/gt}}" withContext:@{ @"value" : @"b"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gt value 'b'}}true{{else}}false{{/gt}}" withContext:@{ @"value" : @"a"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test numbers comparison
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gt value 2}}true{{else}}false{{/gt}}" withContext:@{ @"value" : @3} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gt value 2}}true{{else}}false{{/gt}}" withContext:@{ @"value" : @2} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gt value 2}}true{{else}}false{{/gt}}" withContext:@{ @"value" : @1} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test string / numbers comparison
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gt value 2}}true{{else}}false{{/gt}}" withContext:@{ @"value" : @"3"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gt value 2}}true{{else}}false{{/gt}}" withContext:@{ @"value" : @"2"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gt value 2}}true{{else}}false{{/gt}}" withContext:@{ @"value" : @"1"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test number / string comparison
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gt value '2'}}true{{else}}false{{/gt}}" withContext:@{ @"value" : @3} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gt value '2'}}true{{else}}false{{/gt}}" withContext:@{ @"value" : @2} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gt value '2'}}true{{else}}false{{/gt}}" withContext:@{ @"value" : @1} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testGteBlockHelper
{
    NSError* error = nil;
    
    // test string comparison
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gte value 'b'}}true{{else}}false{{/gte}}" withContext:@{ @"value" : @"c"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gte value 'b'}}true{{else}}false{{/gte}}" withContext:@{ @"value" : @"b"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gte value 'b'}}true{{else}}false{{/gte}}" withContext:@{ @"value" : @"a"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test numbers comparison
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gte value 2}}true{{else}}false{{/gte}}" withContext:@{ @"value" : @3} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gte value 2}}true{{else}}false{{/gte}}" withContext:@{ @"value" : @2} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gte value 2}}true{{else}}false{{/gte}}" withContext:@{ @"value" : @1} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test string / numbers comparison
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gte value 2}}true{{else}}false{{/gte}}" withContext:@{ @"value" : @"3"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gte value 2}}true{{else}}false{{/gte}}" withContext:@{ @"value" : @"2"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gte value 2}}true{{else}}false{{/gte}}" withContext:@{ @"value" : @"1"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test number / string comparison
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gte value '2'}}true{{else}}false{{/gte}}" withContext:@{ @"value" : @3} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gte value '2'}}true{{else}}false{{/gte}}" withContext:@{ @"value" : @2} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#gte value '2'}}true{{else}}false{{/gte}}" withContext:@{ @"value" : @1} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testLtBlockHelper
{
    NSError* error = nil;
    
    // test string comparison
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lt value 'b'}}true{{else}}false{{/lt}}" withContext:@{ @"value" : @"a"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lt value 'b'}}true{{else}}false{{/lt}}" withContext:@{ @"value" : @"b"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lt value 'b'}}true{{else}}false{{/lt}}" withContext:@{ @"value" : @"c"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test numbers comparison
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lt value 2}}true{{else}}false{{/lt}}" withContext:@{ @"value" : @1} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lt value 2}}true{{else}}false{{/lt}}" withContext:@{ @"value" : @2} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lt value 2}}true{{else}}false{{/lt}}" withContext:@{ @"value" : @3} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test string / numbers comparison
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lt value 2}}true{{else}}false{{/lt}}" withContext:@{ @"value" : @"1"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lt value 2}}true{{else}}false{{/lt}}" withContext:@{ @"value" : @"2"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lt value 2}}true{{else}}false{{/lt}}" withContext:@{ @"value" : @"3"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test number / string comparison
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lt value '2'}}true{{else}}false{{/lt}}" withContext:@{ @"value" : @1} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lt value '2'}}true{{else}}false{{/lt}}" withContext:@{ @"value" : @2} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lt value '2'}}true{{else}}false{{/lt}}" withContext:@{ @"value" : @3} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testLteBlockHelper
{
    NSError* error = nil;
    
    // test string comparison
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lte value 'b'}}true{{else}}false{{/lte}}" withContext:@{ @"value" : @"a"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lte value 'b'}}true{{else}}false{{/lte}}" withContext:@{ @"value" : @"b"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lte value 'b'}}true{{else}}false{{/lte}}" withContext:@{ @"value" : @"c"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test numbers comparison
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lte value 2}}true{{else}}false{{/lte}}" withContext:@{ @"value" : @1} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lte value 2}}true{{else}}false{{/lte}}" withContext:@{ @"value" : @2} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lte value 2}}true{{else}}false{{/lte}}" withContext:@{ @"value" : @3} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test string / numbers comparison
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lte value 2}}true{{else}}false{{/lte}}" withContext:@{ @"value" : @"1"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lte value 2}}true{{else}}false{{/lte}}" withContext:@{ @"value" : @"2"} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lte value 2}}true{{else}}false{{/lte}}" withContext:@{ @"value" : @"3"} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    // test number / string comparison
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lte value '2'}}true{{else}}false{{/lte}}" withContext:@{ @"value" : @1} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lte value '2'}}true{{else}}false{{/lte}}" withContext:@{ @"value" : @2} error:&error], @"true");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"{{#lte value '2'}}true{{else}}false{{/lte}}" withContext:@{ @"value" : @3} error:&error], @"false");
    XCTAssert(!error, @"evaluation should not generate an error");
}

@end
