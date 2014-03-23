//
//  HBTestWhitespaceControl.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 3/23/14.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "HBTestCase.h"
#import "HBHandlebars.h"


@interface HBTestWhitespaceControl : HBTestCase

@end

@implementation HBTestWhitespaceControl


- (void)testShouldStripWhitespaceAroundMustacheCalls
{
    NSError* error = nil;
    id hash = @{ @"foo" : @"bar<" };
    
    NSString* result = [self renderTemplate:@" {{~foo~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar&lt;");
    
    result = [self renderTemplate:@" {{~foo}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar&lt; ");
 
    result = [self renderTemplate:@" {{foo~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar&lt;");
    
    result = [self renderTemplate:@" {{~&foo~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar<");
    
    result = [self renderTemplate:@" {{~{foo}~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar<");

}

- (void)testShouldStripWhitespaceAroundSimpleBlockCalls
{
    NSError* error = nil;
    id hash = @{ @"foo" : @"bar<" };
    
    NSString* result = [self renderTemplate:@" {{~#if foo~}} bar {{~/if~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar");
    
    result = [self renderTemplate:@" {{#if foo~}} bar {{/if~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar ");
    
    result = [self renderTemplate:@" {{~#if foo}} bar {{~/if}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar ");
    
    result = [self renderTemplate:@" {{#if foo}} bar {{/if}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"  bar  ");
}

- (void)testShouldStripWhitespaceAroundInverseBlockCalls
{
    NSError* error = nil;
    id hash = @{};
    
    NSString* result = [self renderTemplate:@" {{~^if foo~}} bar {{~/if~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar");
    
    result = [self renderTemplate:@" {{^if foo~}} bar {{/if~}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar ");
    
    result = [self renderTemplate:@" {{~^if foo}} bar {{~/if}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar ");
    
    result = [self renderTemplate:@" {{^if foo}} bar {{/if}} " withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"  bar  ");
}

- (void)testShouldStripWhitespaceAroundComplexBlockCalls
{
    NSError* error = nil;
    id hash = @{ @"foo" : @"bar<" };
    
    NSString* result = [self renderTemplate:@"{{#if foo~}} bar {{~^~}} baz {{~/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar");
    
    result = [self renderTemplate:@"{{#if foo~}} bar {{^~}} baz {{/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar ");
    
    result = [self renderTemplate:@"{{#if foo}} bar {{~^~}} baz {{~/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar");
    
    result = [self renderTemplate:@"{{#if foo}} bar {{^~}} baz {{/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" bar ");
    
    result = [self renderTemplate:@"{{#if foo~}} bar {{~else~}} baz {{~/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"bar");
    
    hash = @{};
    
    result = [self renderTemplate:@"{{#if foo~}} bar {{~^~}} baz {{~/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"baz");
    
    result = [self renderTemplate:@"{{#if foo}} bar {{~^~}} baz {{/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"baz ");
    
    result = [self renderTemplate:@"{{#if foo~}} bar {{~^}} baz {{~/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" baz");
    
    result = [self renderTemplate:@"{{#if foo~}} bar {{~^}} baz {{/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" baz ");
    
    result = [self renderTemplate:@"{{#if foo~}} bar {{~else~}} baz {{~/if}}" withContext:hash error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"baz");
}

@end
