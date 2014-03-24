//
//  HBTestCase.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 3/18/14.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "HBTestCase.h"
#import "HBHandlebars.h"

@implementation HBTestCase

- (NSString*) renderTemplate:(NSString*)template withContext:(id)context withHelpers:(NSDictionary*)helpers withPartials:(NSDictionary*)partials error:(NSError**)error
{
    return [HBHandlebars renderTemplateString:template withContext:context withHelperBlocks:helpers withPartialStrings:partials error:error];
}

- (NSString*) renderTemplate:(NSString*)template withContext:(id)context withHelpers:(NSDictionary*)helpers withPartials:(NSDictionary*)partials
{
    return [self renderTemplate:template withContext:context withHelpers:helpers withPartials:partials error:nil];
}

- (NSString*) renderTemplate:(NSString*)template withContext:(id)context withPartials:(NSDictionary*)partials error:(NSError**)error
{
    return [self renderTemplate:template withContext:context withHelpers:nil withPartials:partials error:error];
}

- (NSString*) renderTemplate:(NSString*)template withContext:(id)context withPartials:(NSDictionary*)partials
{
    return [self renderTemplate:template withContext:context withHelpers:nil withPartials:partials error:nil];
}

- (NSString*) renderTemplate:(NSString*)template withContext:(id)context withHelpers:(NSDictionary*)helpers error:(NSError**)error
{
    return [self renderTemplate:template withContext:context withHelpers:helpers withPartials:nil error:error];
}

- (NSString*) renderTemplate:(NSString*)template withContext:(id)context withHelpers:(NSDictionary*)helpers
{
    return [self renderTemplate:template withContext:context withHelpers:helpers withPartials:nil error:nil];
}

- (NSString*) renderTemplate:(NSString*)template withContext:(id)context error:(NSError**)error
{
    return [self renderTemplate:template withContext:context withHelpers:nil withPartials:nil error:error];
}

- (NSString*) renderTemplate:(NSString*)template withContext:(id)context
{
    return [self renderTemplate:template withContext:context withHelpers:nil withPartials:nil error:nil];
}

@end
