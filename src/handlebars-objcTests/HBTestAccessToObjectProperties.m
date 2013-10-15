//
//  HBTestAccessToObjectProperties.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/15/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HBHandlebars.h"
#import "HBObjectPropertyAccess.h"



@interface AClass : NSObject

@property (strong) NSString* prop1;

- (NSString*) nonPropAccessor1;

@end


@interface BClass : AClass

@property (strong) NSString* prop2;

@end

@interface CClass : BClass

@property (strong) NSString* prop3;

+ (NSArray*) validKeysForHandlebars;

- (NSString*) nonPropAccessor2;
- (NSString*) nonPropAccessor3;

@end

@interface DClass : CClass
@end

@interface EClass : DClass
+ (NSArray*) validKeysForHandlebars;
@end


@interface HBTestAccessToObjectProperties : XCTestCase

@end

@implementation HBTestAccessToObjectProperties

- (void)testSimpleDictionaryAccessWhenPresent
{
    XCTAssert([[HBObjectPropertyAccess valueForKey:@"name" onObject:@{@"name" : @"allan"}] isEqual:@"allan"], @"should be able to access simple properties in dictionaries");
}

- (void)testSimpleDictionaryAccessFailWhenNotPresent
{
    XCTAssert([HBObjectPropertyAccess valueForKey:@"name" onObject:@{@"last_name" : @"allan"}] == nil, @"should return nil when accessing non existing properties in dictionaries");
}

- (void)testPropertyAccessOnSimpleObject
{
    AClass* object = [[AClass new] autorelease];
    object.prop1 = @"david";
    
    XCTAssert([[HBObjectPropertyAccess valueForKey:@"prop1" onObject:object] isEqual:@"david"], @"should be able to access objective C properties on objects");
    XCTAssert([HBObjectPropertyAccess valueForKey:@"prop2" onObject:object] == nil, @"should be able to access non-existing objective C properties on objects");
   XCTAssert([HBObjectPropertyAccess valueForKey:@"nonPropAccessor1" onObject:object] == nil, @"accessors with no objective-C properties should not be accessible");
}

- (void)testPropertyAccessOnObjectWithInheritedClass
{
    BClass* object = [[BClass new] autorelease];
    object.prop1 = @"david";
    object.prop2 = @"hilbert";
    
    XCTAssert([[HBObjectPropertyAccess valueForKey:@"prop1" onObject:object] isEqual:@"david"], @"should be able to access objective C properties on objects");
    XCTAssert([[HBObjectPropertyAccess valueForKey:@"prop2" onObject:object] isEqual:@"hilbert"], @"should be able to access objective C properties on objects with inherited properties");
    XCTAssert([HBObjectPropertyAccess valueForKey:@"nonPropAccessor1" onObject:object] == nil, @"accessors with no objective-C properties should not be accessible");
}

- (void) testPropertyAccessOnObjectWithExplicitAccessKeys
{
    CClass* object = [[CClass new] autorelease];
    object.prop1 = @"david";
    object.prop2 = @"hilbert";
    object.prop3 = @"junior";
    
    XCTAssert([[HBObjectPropertyAccess valueForKey:@"prop1" onObject:object] isEqual:@"david"], @"should be able to access authorized properties");
    XCTAssert([HBObjectPropertyAccess valueForKey:@"prop2" onObject:object] == nil, @"should not be able to access non authorized keys");
    XCTAssert([[HBObjectPropertyAccess valueForKey:@"prop3" onObject:object] isEqual:@"junior"], @"should be able to access authorized properties");

    XCTAssert([[HBObjectPropertyAccess valueForKey:@"nonPropAccessor1" onObject:object] isEqual:@"pouet"], @"should be able to access authorized accessor");
    XCTAssert([HBObjectPropertyAccess valueForKey:@"nonPropAccessor2" onObject:object] == nil, @"should not be able to access non authorized keys [non-property accessors]");
    XCTAssert([[HBObjectPropertyAccess valueForKey:@"nonPropAccessor3" onObject:object] isEqual:@"bla"], @"should be able to access authorized accessor");
}

- (void) testPropertyAccessOnObjectWithExplicitAccessKeysWithSimpleInheritance
{
    DClass* object = [[DClass new] autorelease];
    object.prop1 = @"david";
    object.prop2 = @"hilbert";
    object.prop3 = @"junior";
    
    XCTAssert([[HBObjectPropertyAccess valueForKey:@"prop1" onObject:object] isEqual:@"david"], @"should be able to access authorized properties");
    XCTAssert([HBObjectPropertyAccess valueForKey:@"prop2" onObject:object] == nil, @"should not be able to access non authorized keys");
    XCTAssert([[HBObjectPropertyAccess valueForKey:@"prop3" onObject:object] isEqual:@"junior"], @"should be able to access authorized properties");
    
    XCTAssert([[HBObjectPropertyAccess valueForKey:@"nonPropAccessor1" onObject:object] isEqual:@"pouet"], @"should be able to access authorized accessor");
    XCTAssert([HBObjectPropertyAccess valueForKey:@"nonPropAccessor2" onObject:object] == nil, @"should not be able to access non authorized keys [non-property accessors]");
    XCTAssert([[HBObjectPropertyAccess valueForKey:@"nonPropAccessor3" onObject:object] isEqual:@"bla"], @"should be able to access authorized accessor");
}

- (void) testPropertyAccessOnObjectWithExplicitAccessKeysWithInheritanceChangingAuthorizedKeys
{
    EClass* object = [[EClass new] autorelease];
    object.prop1 = @"david";
    object.prop2 = @"hilbert";
    object.prop3 = @"junior";
    
    XCTAssert([HBObjectPropertyAccess valueForKey:@"prop1" onObject:object] == nil, @"should not be able to access non authorized keys");
    XCTAssert([[HBObjectPropertyAccess valueForKey:@"prop2" onObject:object] isEqual:@"hilbert"], @"should be able to access authorized properties");
    XCTAssert([HBObjectPropertyAccess valueForKey:@"prop3" onObject:object] == nil, @"should not be able to access non authorized keys");
    
    XCTAssert([HBObjectPropertyAccess valueForKey:@"nonPropAccessor1" onObject:object] == nil, @"should not be able to access non authorized keys [non-property accessors]");
    XCTAssert([[HBObjectPropertyAccess valueForKey:@"nonPropAccessor2" onObject:object] isEqual:@"glu"], @"should be able to access authorized accessor");
    XCTAssert([HBObjectPropertyAccess valueForKey:@"nonPropAccessor3" onObject:object] == nil, @"should not be able to access non authorized keys [non-property accessors]");
}

- (void) testTemplateWithImplicitAccessControlOnKeys
{
    BClass* object = [[BClass new] autorelease];
    object.prop1 = @"david";
    object.prop2 = @"hilbert";
    
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"prop1:{{prop1}} prop2:{{prop2}} nonPropAccessor1:{{nonPropAccessor1}}" withContext:object error:&error],
                          @"prop1:david prop2:hilbert nonPropAccessor1:");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testTemplateWithExplicitAccessControlOnKeys
{
    EClass* object = [[EClass new] autorelease];
    object.prop1 = @"david";
    object.prop2 = @"hilbert";
    object.prop3 = @"junior";
    
    NSError* error = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"prop1:{{prop1}} prop2:{{prop2}} prop3:{{prop3}} nonPropAccessor1:{{nonPropAccessor1}} nonPropAccessor2:{{nonPropAccessor2}} nonPropAccessor3:{{nonPropAccessor3}}" withContext:object error:&error],
                          @"prop1: prop2:hilbert prop3: nonPropAccessor1: nonPropAccessor2:glu nonPropAccessor3:");
    XCTAssert(!error, @"evaluation should not generate an error");
}

@end


@implementation AClass

- (NSString*) nonPropAccessor1
{
    return @"pouet";
}

@end


@implementation BClass
@end

@implementation CClass

+ (NSArray*) validKeysForHandlebars
{
    return @[ @"prop1", @"prop3", @"nonPropAccessor1", @"nonPropAccessor3" ];
}

- (NSString*) nonPropAccessor2
{
    return @"glu";
}
              
- (NSString*) nonPropAccessor3
{
    return @"bla";
}

@end

@implementation DClass
@end

@implementation EClass
+ (NSArray*) validKeysForHandlebars
{
    return @[ @"prop2", @"nonPropAccessor2" ];
}
@end