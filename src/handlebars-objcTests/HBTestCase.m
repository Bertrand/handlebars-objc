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

- (NSString*) renderTemplate:(NSString*)string withContext:(id)context withHelpers:(NSDictionary*)blocks error:(NSError**)error
{
    HBTemplate* template = [[HBTemplate alloc] initWithString:string];
    [template.helpers registerHelperBlocks:blocks];
    
    NSString* result = [template renderWithContext:context error:error];
    [template release];
    
    return result;
}

- (NSString*) renderTemplate:(NSString*)template withContext:(id)context withHelpers:(NSDictionary*)blocks
{
    return [self renderTemplate:template withContext:context withHelpers:blocks error:nil];
}

@end
