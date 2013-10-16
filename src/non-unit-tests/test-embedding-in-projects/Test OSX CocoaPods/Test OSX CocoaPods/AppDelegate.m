//
//  AppDelegate.m
//  Test OSX CocoaPods
//
//  Created by Bertrand Guiheneuf on 10/14/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import "AppDelegate.h"
#import <HBHandlebars/HBHandlebars.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString* evaluatedTemplate = [HBHandlebars renderTemplateString:@"Hello from {{value}}" withContext:@{ @"value" : @"Handlebars" } error:nil];
    NSLog(@"%@", evaluatedTemplate);
}

@end
