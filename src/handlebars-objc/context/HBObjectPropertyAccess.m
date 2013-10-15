//
//  HBObjectPropertyAccessor.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/15/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import "HBObjectPropertyAccess.h"
#import "HBHandlebars.h"
#import <objc/runtime.h>

@implementation HBObjectPropertyAccess

+ (id /* NSSet or nil */) objectiveCPropertyNamesForClass:(Class)class
{
    NSMutableSet* propertySet = [NSMutableSet new];
    
    while (class) {
        
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(class, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            [propertySet addObject:@(property_getName(property))];
        }
        
        class = class_getSuperclass(class);
    }
    
    return propertySet.count > 0 ? propertySet : [NSNull null];
}

+ (NSSet*) validKeysForClass:(Class)class
{
    static NSMutableDictionary* _perClassValidKeys = nil;
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _perClassValidKeys = [[NSMutableDictionary alloc] init];
    });
    
    NSString* className = NSStringFromClass(class);
    @synchronized(_perClassValidKeys) {
        if (!_perClassValidKeys[className]) {
            // result not cached, let's compute it.
            NSSet* computedValidKeys = nil;
            
            if ([class respondsToSelector:@selector(validKeysForHandlebars)]) {
                // if class implements the HBHandlebarsKVCValidation protocol, then what's returned
                // by +[class validKeysForHandlebars] is authoritative.
                NSArray* validKeysAsArray = [class validKeysForHandlebars];
                computedValidKeys = validKeysAsArray ? [NSSet setWithArray:validKeysAsArray] : [NSNull null];
                
            } else {
                // class doesn't explicitely tell what keys are valid, let's fallback on objectiveC properties.
                computedValidKeys = [self objectiveCPropertyNamesForClass:class];
            }
            
            _perClassValidKeys[className] = computedValidKeys;
        }
        
        id validKeys = _perClassValidKeys[className];
        return validKeys == [NSNull null] ? nil : validKeys;
    }
    
    return nil;
}

+ (BOOL) isKey:(NSString*)key validForKVCOnObject:(id)object
{
    return [[self validKeysForClass:[object class]] containsObject:key];
}

+ (id) valueForKey:(NSString *)key onObject:(id)object
{
    // first, try keyed subscripting operator.
    if ([object respondsToSelector:@selector(objectForKeyedSubscript:)]) return object[key];
    
    // then try KVC if allowed for this key.
    if ([self isKey:key validForKVCOnObject:object]) {
        return [object valueForKey:key];
    }
    
    return nil;
}

@end
