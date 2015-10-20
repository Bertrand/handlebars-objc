//
//  HBTestAccessToObjectProperties.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/15/13.
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
#import "HBObjectPropertyAccess.h"
#import <CoreData/CoreData.h>


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

- (void) testAccessToCoreDataProperties
{
	NSManagedObjectModel *model = [[NSManagedObjectModel alloc] init];
    
	// create the entity
	NSEntityDescription *entity = [[NSEntityDescription alloc] init];
	[entity setName:@"Person"];
	[entity setManagedObjectClassName:@"Person"];
    
	// create the attributes
	NSMutableArray *properties = [NSMutableArray array];
    
	NSAttributeDescription *nameAttribute = [[NSAttributeDescription alloc] init];
	[nameAttribute setName:@"name"];
	[nameAttribute setAttributeType:NSStringAttributeType];
	[nameAttribute setOptional:NO];
	[properties addObject:nameAttribute];
    
    // add attributes to entity
	[entity setProperties:properties];
    
	// add entity to model
	[model setEntities:[NSArray arrayWithObject:entity]];
    
 
    // setup persistent store coordinator
	NSURL *storeURL = [NSURL fileURLWithPath:[@"/tmp/" stringByAppendingPathComponent:@"handlebars-objc-teststore"]];
    
	NSError *error = nil;
	NSPersistentStoreCoordinator* persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
	{
		// inconsistent model/store
		[[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
        
		// retry once
		if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
    
	// create MOC
    NSManagedObjectContext* managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    NSManagedObject* person = [[NSManagedObject alloc]
                      initWithEntity:entity
                      insertIntoManagedObjectContext:managedObjectContext];
    
    [person setValue:@"paulo" forKey:@"name"];
    
    NSError* renderError = nil;
    XCTAssertEqualObjects([HBHandlebars renderTemplateString:@"Hello {{name}}" withContext:person error:&renderError],
                          @"Hello paulo");
    XCTAssert(!renderError, @"evaluation should not generate an error");
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