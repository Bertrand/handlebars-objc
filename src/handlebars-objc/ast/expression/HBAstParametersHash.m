//
//  HBAstParametersHash.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 3/24/14.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "HBAstParametersHash.h"
#import "HBAstVisitor.h"

@implementation HBAstParametersHash

- (NSUInteger) count
{
    return self.orderedNamedParameterNames.count;
}

- (void) appendParameter:(HBAstValue*)parameter forKey:(NSString*)key
{
    if (self.namedParameters == nil) self.namedParameters = [NSMutableDictionary dictionary];
    if (self.orderedNamedParameterNames == nil) self.orderedNamedParameterNames = [NSMutableArray array];
    self.namedParameters[key] = parameter;
    [self.orderedNamedParameterNames addObject:key];
}

- (void) appendNamedParameters:(NSDictionary*)namedParameters
{
    for (NSString* name in namedParameters) {
        [self appendParameter:namedParameters[name] forKey:name];
    }
}

// objc litteral compatibility

- (id) objectForKeyedSubscript:(id)key
{
    return [self.namedParameters objectForKey:key];
}

// fast enumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
    return [self.orderedNamedParameterNames countByEnumeratingWithState:state objects:stackbuf count:len];
}

// visitor protocol

- (id) accept:(HBAstVisitor*)visitor
{
    return [visitor visitParametersHash:self];
}

- (void) dealloc
{
    self.namedParameters = nil;
    self.orderedNamedParameterNames = nil;
    
    [super dealloc];
}

@end
