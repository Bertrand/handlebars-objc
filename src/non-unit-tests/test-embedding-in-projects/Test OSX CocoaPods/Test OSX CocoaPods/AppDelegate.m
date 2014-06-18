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

- (void) testIssue9
{
    HBHelperBlock sentenceCaseBlock = ^(HBHelperCallingInfo * callingInfo) {
        NSString * locale = callingInfo[@"locale"];
        NSString * src = callingInfo[0];
        return [src capitalizedStringWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:locale]];
    };
    [HBHandlebars registerHelperBlock:sentenceCaseBlock forName:@"sentenceCase"];
    
    NSError * error;
    NSString * result = [HBHandlebars renderTemplateString:@"hello {{sentenceCase value locale='en_US'}}!"
                               withContext:@{@"value" : @"mike this is your friend george"}
                                     error:&error];
    NSLog(@"result : %@", result);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self testIssue9];
    
    NSString* evaluatedTemplate = [HBHandlebars renderTemplateString:@"Hello from {{value}}" withContext:@{ @"value" : @"Handlebars" } error:nil];
    NSLog(@"%@", evaluatedTemplate);
}

@end
