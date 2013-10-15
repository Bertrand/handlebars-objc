//
//  HBObjectPropertyAccessor.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/15/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import <Foundation/Foundation.h>

// Utility that checks access to values on contexts. 
@interface HBObjectPropertyAccess : NSObject

+ (id) valueForKey:(NSString *)key onObject:(id)object;

@end
