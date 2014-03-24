//
//  HBAstParametersHash.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 3/24/14.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "HBAstNode.h"
#import "HBAstValue.h"

@interface HBAstParametersHash : HBAstNode

@property (readonly, nonatomic) NSUInteger count;
@property (retain, nonatomic) NSMutableDictionary* /* (NSString -> HBAstValue) */namedParameters;
@property (retain, nonatomic) NSMutableArray* /* (NSString) */ orderedNamedParameterNames;

- (void) appendParameter:(HBAstValue*)parameter forKey:(NSString*)key;
- (void) appendNamedParameters:(NSDictionary*)namedParameters;

// objc subscripting
- (id)objectForKeyedSubscript:(id)key;
// fast enumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

@end
