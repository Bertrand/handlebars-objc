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

@end
