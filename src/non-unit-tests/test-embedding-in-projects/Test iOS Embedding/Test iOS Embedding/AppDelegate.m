//
//  AppDelegate.m
//  Test iOS Embedding
//
//  Created by Bertrand Guiheneuf on 10/14/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import "AppDelegate.h"
#import <HBHandlebars/HBHandlebars.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString* evaluatedTemplate = [HBHandlebars renderTemplateString:@"Hello from {{value}}" withContext:@{ @"value" : @"Handlebars" }];
    NSLog(@"%@", evaluatedTemplate);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}



@end
