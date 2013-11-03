//
//  HBExecutionContext_Private.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 11/2/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import <HBHandlebars/HBHandlebars.h>

@interface HBExecutionContext ()

- (NSString*) localizedString:(NSString*)string;
- (NSString*) escapeString:(NSString*)rawString forTargetFormat:(NSString*)formatName;

@end
