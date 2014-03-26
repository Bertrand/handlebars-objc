//
//  HBTestData.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 3/25/14.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//


#import "HBTestCase.h"
#import "HBHandlebars.h"


@interface HBTestData : HBTestCase

@end

@implementation HBTestData

- (HBHelperBlock) letHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        
        HBDataContext* currentDataContext = callingInfo.data;
        HBDataContext* descendantDataContext = currentDataContext ? [currentDataContext copy] : [HBDataContext new];
        
        for (NSString* paramName in callingInfo.namedParameters) {
            descendantDataContext[paramName] = callingInfo.namedParameters[paramName];
        }
        
        return callingInfo.statements(callingInfo.context, descendantDataContext);
    };
}

- (HBHelperBlock) helloHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        return [NSString stringWithFormat:@"Hello %@", callingInfo[@"noun"]];
    };
}

- (void) testDeepAtFooTriggersAutomaticTopLevelData
{
    NSError* error = nil;
    id string = @"{{#let world='world'}}{{#if foo}}{{#if foo}}Hello {{@world}}{{/if}}{{/if}}{{/let}}";
    id hash = @{ @"foo" : @true };
    NSDictionary* helpers = @{ @"let" : [self letHelper]};
    
    NSString* result = [self renderTemplate:string withContext:hash withHelpers:helpers error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"Hello world");
}

- (void) testDataIsInheritedDownstream
{
    NSError* error = nil;
    id string = @"{{#let foo=1 bar=2}}{{#let foo=bar.baz}}{{@bar}}{{@foo}}{{/let}}{{@foo}}{{/let}}";
    id hash = @{ @"bar": @{ @"baz": @"hello world" } };
    NSDictionary* helpers = @{ @"let" : [self letHelper]};
    
    NSString* result = [self renderTemplate:string withContext:hash withHelpers:helpers error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"2hello world1");
}

- (void) testTheRootContextCanBeLookedUpViaAtRoot
{
    NSError* error = nil;
    id string = @"{{@root.foo}}";
    id hash = @{ @"foo" : @"hello" };
    NSDictionary* helpers = @{ @"let" : [self letHelper]};
    
    NSString* result = [self renderTemplate:string withContext:hash withHelpers:helpers error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @"hello");
}

- (void) testDataContextCanBeClimbedUp
{
    NSError* error = nil;
    id string = @"{{#let foo=1}}{{#let foo=2}}{{#let foo=3}} {{ @foo }} {{ @./foo }} {{ @../foo }} {{ @../../foo }} {{/let}}{{/let}}{{/let}}";
    id hash = @{};
    NSDictionary* helpers = @{ @"let" : [self letHelper]};
    
    NSString* result = [self renderTemplate:string withContext:hash withHelpers:helpers error:&error];
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects(result, @" 3 3 2 1 ");
}


@end
