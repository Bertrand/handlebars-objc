//
//  AppDelegate.m
//  Test OSX Embedding
//
//  Created by Bertrand Guiheneuf on 10/14/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import "AppDelegate.h"
#import <HBHandlebars/HBHandlebars.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSError* error = nil;
    NSString* evaluatedTemplate = [HBHandlebars renderTemplateString:@"Hello from {{value}}" withContext:@{ @"value" : @"Handlebars"} error:&error];
    NSLog(@"%@", evaluatedTemplate);
}

@end
