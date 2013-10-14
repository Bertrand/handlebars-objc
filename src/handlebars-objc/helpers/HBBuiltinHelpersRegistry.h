//
//  HBBuiltinHelpersRegistry.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/5/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HBHelperRegistry.h"

@interface HBBuiltinHelpersRegistry : HBHelperRegistry

+ (void) initialize;
+ (instancetype) builtinRegistry;

@end
