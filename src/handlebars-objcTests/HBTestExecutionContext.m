//
//  HBTestExecutionContext.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/19/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HBHandlebars.h"

@interface HBTestExecutionContext : XCTestCase

@end


@interface SimpleExecutionContextDelegate : NSObject<HBExecutionContextDelegate>
@property (nonatomic, retain) NSMutableDictionary* helperBlocks;
@property (nonatomic, retain) NSMutableDictionary* partialStrings;

@end

@implementation HBTestExecutionContext

- (void)testHelperBlocksDelegationOnExecutionContext
{
    SimpleExecutionContextDelegate* delegate = [[SimpleExecutionContextDelegate new] autorelease];
    HBExecutionContext* executionContext = [[HBExecutionContext new] autorelease];
    executionContext.delegate = delegate;
    HBTemplate* template = [executionContext templateWithString:@"{{helper1}}-{{helper2}}"];
    
    HBHelperBlock b1 = ^(HBHelperCallingInfo* callingInfo) { return @"h1"; };
    HBHelperBlock b2 = ^(HBHelperCallingInfo* callingInfo) { return @"h2"; };
    
    delegate.helperBlocks[@"helper1"] = b1;
    delegate.helperBlocks[@"helper2"] = b2;
    
    XCTAssertEqual(b1, [executionContext helperForName:@"helper1"].block);
    XCTAssertEqual(b2, [executionContext helperForName:@"helper2"].block);
    
    NSError* error = nil;
    NSString* evaluation = [template renderWithContext:nil error:&error];
    XCTAssertNil(error);
    
    XCTAssertEqualObjects(evaluation, @"h1-h2");
}


- (void)testPartialStringsDelegationOnExecutionContext
{
    SimpleExecutionContextDelegate* delegate = [[SimpleExecutionContextDelegate new] autorelease];
    HBExecutionContext* executionContext = [[HBExecutionContext new] autorelease];
    executionContext.delegate = delegate;
    HBTemplate* template = [executionContext templateWithString:@"{{>partial1}}-{{>partial2}}"];
    
    NSString* p1 = @"p1";
    NSString* p2 = @"p2";
    
    delegate.partialStrings[@"partial1"] = p1;
    delegate.partialStrings[@"partial2"] = p2;
    
    XCTAssertEqual(p1, [executionContext partialForName:@"partial1"].string);
    XCTAssertEqual(p2, [executionContext partialForName:@"partial2"].string);
    
    NSError* error = nil;
    NSString* evaluation = [template renderWithContext:nil error:&error];
    XCTAssertNil(error);
    
    XCTAssertEqualObjects(evaluation, @"p1-p2");
}
@end


@implementation SimpleExecutionContextDelegate

- (id) init
{
    self = [super init];
    if (self) {
        _helperBlocks = [[NSMutableDictionary alloc] init];
        _partialStrings = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (HBHelperBlock) helperBlockWithName:(NSString*)name forExecutionContext:(HBExecutionContext*)executionContext
{
    return self.helperBlocks[name];
}

- (NSString*) partialStringWithName:(NSString*)name forExecutionContext:(HBExecutionContext*)executionContext
{
    return self.partialStrings[name];
}

@end