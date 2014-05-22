//
//  HBTestExecutionContext.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/19/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HBHandlebars.h"
#import "HBExecutionContext_Private.h"

@interface HBTestExecutionContext : XCTestCase

@end


@interface SimpleExecutionContextDelegate : NSObject<HBExecutionContextDelegate>
@property (nonatomic, retain) NSMutableDictionary* helperBlocks;
@property (nonatomic, retain) NSMutableDictionary* partialStrings;
@property (nonatomic, retain) NSMutableDictionary* partials;
@property (nonatomic, retain) NSMutableDictionary* localizedStrings;

@end

@interface SimpleLocalizationDelegate : NSObject<HBExecutionContextDelegate>

- (NSString*) localizedString:(NSString*)string forExecutionContext:(HBExecutionContext*)executionContext;

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

- (void)testPartialsDelegationOnExecutionContext
{
    SimpleExecutionContextDelegate* delegate = [[SimpleExecutionContextDelegate new] autorelease];
    HBExecutionContext* executionContext = [[HBExecutionContext new] autorelease];
    executionContext.delegate = delegate;
    HBTemplate* template = [executionContext templateWithString:@"{{>partial1}}-{{>partial2}}"];
    
    NSString* s1 = @"p1";
    NSString* s2 = @"p2";
    
    HBPartial* p1 = [[HBPartial new] autorelease];
    p1.string = s1;
    
    HBPartial* p2 = [[HBPartial new] autorelease];
    p2.string = s2;
    
    delegate.partials[@"partial1"] = p1;
    delegate.partials[@"partial2"] = p2;
    
    XCTAssertEqual(s1, [executionContext partialForName:@"partial1"].string);
    XCTAssertEqual(s2, [executionContext partialForName:@"partial2"].string);
    
    NSError* error = nil;
    NSString* evaluation = [template renderWithContext:nil error:&error];
    XCTAssertNil(error);
    
    XCTAssertEqualObjects(evaluation, @"p1-p2");
}


- (void)testLocalizationDelegationOnExecutionContext
{
    SimpleExecutionContextDelegate* delegate = [[SimpleExecutionContextDelegate new] autorelease];
    HBExecutionContext* executionContext = [[HBExecutionContext new] autorelease];
    executionContext.delegate = delegate;
    HBTemplate* template = [executionContext templateWithString:@"{{localize 'hello'}} {{localize 'handlebars'}}!"];
    
    NSString* s1 = @"bonjour";
    NSString* s2 = @"guidon";

    
    delegate.localizedStrings[@"hello"] = s1;
    delegate.localizedStrings[@"handlebars"] = s2;
    
    XCTAssertEqual(s1, [executionContext localizedString:@"hello"]);
    XCTAssertEqual(s2, [executionContext localizedString:@"handlebars"]);
    
    NSError* error = nil;
    NSString* evaluation = [template renderWithContext:nil error:&error];
    XCTAssertNil(error);
    
    XCTAssertEqualObjects(evaluation, @"bonjour guidon!");
}

- (void)testSimpleLocalizationDelegationOnExecutionContext
{
    // create a new execution context
    HBExecutionContext* executionContext = [[HBExecutionContext new] autorelease];
    
    // set its delegate (will provide localization of "handlebars" string)
    executionContext.delegate = [[SimpleLocalizationDelegate new] autorelease];
    
    // render template
    HBTemplate* template = [executionContext templateWithString:@"hello {{localize 'handlebars'}}!"];
    
    NSError* error = nil;
    NSString* evaluation = [template renderWithContext:nil error:&error];
    XCTAssertNil(error);
    
    XCTAssertEqualObjects(evaluation, @"hello guidon!");
}

- (void)testEscapingDelegationOnExecutionContext
{
    SimpleExecutionContextDelegate* delegate = [[SimpleExecutionContextDelegate new] autorelease];
    HBExecutionContext* executionContext = [[HBExecutionContext new] autorelease];
    executionContext.delegate = delegate;
    HBTemplate* template = [executionContext templateWithString:@"{{escape 'application/x-json-string' 'hel\"lo'}}"];
    
    NSError* error = nil;
    NSString* evaluation = [template renderWithContext:nil error:&error];
    XCTAssertNil(error);
    
    XCTAssertEqualObjects(evaluation, @"hel\\\"lo");
}
    
@end


@implementation SimpleExecutionContextDelegate

- (id) init
{
    self = [super init];
    if (self) {
        _helperBlocks = [[NSMutableDictionary alloc] init];
        _partialStrings = [[NSMutableDictionary alloc] init];
        _partials = [[NSMutableDictionary alloc] init];
        _localizedStrings = [[NSMutableDictionary alloc] init];
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

    
- (HBPartial*) partialWithName:(NSString*)name forExecutionContext:(HBExecutionContext*)executionContext
{
    return self.partials[name];
}

- (NSString*) localizedString:(NSString*)string forExecutionContext:(HBExecutionContext*)executionContext
{
    return self.localizedStrings[string];
}
    
- (void) replaceString:(NSString*)source withString:(NSString*)target inMutableString:(NSMutableString*)string
{
    [string replaceOccurrencesOfString:source withString:target options:NSCaseInsensitiveSearch range:NSMakeRange(0, [string length])];
}

- (NSString*) escapeString:(NSString*)rawString forTargetFormat:(NSString*)formatName forExecutionContext:(HBExecutionContext*)executionContext
{
    NSString* result = nil;
    
    if ([formatName isEqual:@"application/x-json-string"]) {
        // mostly copied from http://www.codza.com/converting-nsstring-to-json-string
        NSMutableString *s = [NSMutableString stringWithString:rawString];
        [self replaceString:@"\"" withString:@"\\\"" inMutableString:s];
        [self replaceString:@"/"  withString:@"\\/"  inMutableString:s];
        [self replaceString:@"\n" withString:@"\\n"  inMutableString:s];
        [self replaceString:@"\b" withString:@"\\b"  inMutableString:s];
        [self replaceString:@"\f" withString:@"\\f"  inMutableString:s];
        [self replaceString:@"\r" withString:@"\\r"  inMutableString:s];
        [self replaceString:@"\t" withString:@"\\t"  inMutableString:s];
        result = [NSString stringWithString:s];
    }
    
    return result;
}


@end


@implementation SimpleLocalizationDelegate

- (NSString*) localizedString:(NSString*)string forExecutionContext:(HBExecutionContext*)executionContext
{
    // if string to translate is "handlebars", return french translation
    if ([string isEqual:@"handlebars"]) return @"guidon";
    // otherwise, provide no translation at all. Handlebars-objc will then fallback to other mechanisms
    else return nil;
}

@end