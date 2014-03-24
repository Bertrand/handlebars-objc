//
//  HBTestSubexpressions.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 3/17/14.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "HBTestCase.h"
#import "HBHandlebars.h"
#import "HBContextRendering.h"


@interface HBTestSubexpressions : HBTestCase

@end


@implementation HBTestSubexpressions

- (HBHelperBlock) lolStringHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        return @"LOL";
    };
}

- (HBHelperBlock) duplicateHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        return [NSString stringWithFormat:@"%@%@", callingInfo[0], callingInfo[0]];
    };
}

- (HBHelperBlock) blogHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        return [NSString stringWithFormat:@"val is %@", callingInfo[0]];
    };
}

- (HBHelperBlock) blogWithNamedParamHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        return [NSString stringWithFormat:@"val is %@", callingInfo[@"fun"]];
    };
}

- (HBHelperBlock) blogWith3ParamsHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        return [NSString stringWithFormat:@"val is %@, %@ and %@", callingInfo[0], callingInfo[1], callingInfo[2]];
    };
}

- (HBHelperBlock) equalHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        id a = callingInfo[0];
        id b = callingInfo[1];
        return ((a==b) || [a isEqual:b] || [renderForHandlebars(a) isEqualToString:renderForHandlebars(b)]) ? @"true" : @"false";
    };
}

- (HBHelperBlock) tHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        id defaultString = callingInfo[0];
        return defaultString;
    };
}

- (HBHelperBlock) inputHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        id ariaLabel = callingInfo[@"aria-label"];
        id placeholder = callingInfo[@"placeholder"];
        return [NSString stringWithFormat:@"<input aria-label=\"%@\" placeholder=\"%@\" />", ariaLabel, placeholder];
    };
}


#pragma mark -
#pragma mark Tests from Handlebars.js

- (void) testArgLessHelper
{
    NSError* error = nil;
    id string = @"{{foo (bar)}}!";
    id hash = @{ };
    NSDictionary* helpers = @{ @"foo" : [self duplicateHelper], @"bar" : [self lolStringHelper]};
    
    NSString* result = [self renderTemplate:string withContext:hash withHelpers:helpers error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"LOLLOL!");
}

- (void) testHelperWArgs
{
    NSError* error = nil;
    id string = @"{{blog (equal a b)}}";
    id hash = @{ @"bar" : @"LOL" };
    NSDictionary* helpers = @{ @"blog" : [self blogHelper], @"equal" : [self equalHelper]};
    
    NSString* result = [self renderTemplate:string withContext:hash withHelpers:helpers error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"val is true");
}

- (void) testMixedPathsAndHelpers
{
    NSError* error = nil;
    id string = @"{{blog baz.bat (equal a b) baz.bar}}";
    id hash = @{ @"bar" : @"LOL", @"baz": @{ @"bat": @"foo!", @"bar": @"bar!"} };
    NSDictionary* helpers = @{ @"blog": [self blogWith3ParamsHelper], @"equal" : [self equalHelper]};
    
    NSString* result = [self renderTemplate:string withContext:hash withHelpers:helpers error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"val is foo!, true and bar!");
}

- (void) testSupportsMuchNesting
{
    NSError* error = nil;
    id string = @"{{blog (equal (equal true true) 'true')}}";
    id hash = @{ @"bar" : @"LOL" };
    NSDictionary* helpers = @{ @"blog" : [self blogHelper], @"equal" : [self equalHelper]};
    
    NSString* result = [self renderTemplate:string withContext:hash withHelpers:helpers error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"val is true");
}

- (void) testWithHashes
{
    NSError* error = nil;
    id string = @"{{blog (equal (equal true true) 'true' fun='yes')}}";
    id hash = @{ @"bar" : @"LOL" };
    NSDictionary* helpers = @{ @"blog" : [self blogHelper], @"equal" : [self equalHelper]};
    
    NSString* result = [self renderTemplate:string withContext:hash withHelpers:helpers error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"val is true");
}

- (void) testAsHashes
{
    NSError* error = nil;
    id string = @"{{blog fun=(equal (blog 2 fun=1 gli='meuh') 'val is 1')}}";
    id hash = @{ @"bar" : @"LOL" };
    NSDictionary* helpers = @{ @"blog" : [self blogWithNamedParamHelper], @"equal" : [self equalHelper]};
    
    NSString* result = [self renderTemplate:string withContext:hash withHelpers:helpers error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"val is true");
}

- (void) testMultipleSubexpressionsInAHash
{
    NSError* error = nil;
    id string = @"{{{input aria-label=(t \"Name\") placeholder=(t \"Example User\")}}}";
    id hash = @{};
    NSDictionary* helpers = @{ @"t" : [self tHelper], @"input" : [self inputHelper]};
    
    NSString* result = [self renderTemplate:string withContext:hash withHelpers:helpers error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"<input aria-label=\"Name\" placeholder=\"Example User\" />");
}

@end
