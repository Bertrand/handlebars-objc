//
//  HBTestCase.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 3/18/14.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface HBTestCase : XCTestCase

- (NSString*) renderTemplate:(NSString*)template withContext:(id)context withHelpers:(NSDictionary*)blocks withPartials:(NSDictionary*)partials error:(NSError**)error;
- (NSString*) renderTemplate:(NSString*)template withContext:(id)context withHelpers:(NSDictionary*)blocks withPartials:(NSDictionary*)partials;

- (NSString*) renderTemplate:(NSString*)template withContext:(id)context withPartials:(NSDictionary*)partials error:(NSError**)error;
- (NSString*) renderTemplate:(NSString*)template withContext:(id)context withPartials:(NSDictionary*)partials;

- (NSString*) renderTemplate:(NSString*)template withContext:(id)context withHelpers:(NSDictionary*)blocks error:(NSError**)error;
- (NSString*) renderTemplate:(NSString*)template withContext:(id)context withHelpers:(NSDictionary*)blocks;

- (NSString*) renderTemplate:(NSString*)template withContext:(id)context error:(NSError**)error;
- (NSString*) renderTemplate:(NSString*)template withContext:(id)context;

@end
