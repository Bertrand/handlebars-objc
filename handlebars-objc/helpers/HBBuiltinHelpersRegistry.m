//
//  HBBuiltinHelpersRegistry.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/5/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//

#import "HBBuiltinHelpersRegistry.h"
#import "HBHandlebars.h"

static HBBuiltinHelpersRegistry* _builtinHelpersRegistry = nil;

@interface HBBuiltinHelpersRegistry()

+ (void) registerIfBlock;
+ (void) registerUnlessBlock;
+ (void) registerEachHelper;
+ (void) registerWithBlock;
+ (void) registerLogBlock;

@end

@implementation HBBuiltinHelpersRegistry

+ (instancetype) builtinRegistry
{
    return _builtinHelpersRegistry;
}

+ (void) initialize
{
    _builtinHelpersRegistry = [[HBBuiltinHelpersRegistry alloc] init];
    
    [self registerIfBlock];
    [self registerUnlessBlock];
    [self registerEachHelper];
    [self registerWithBlock];
    [self registerLogBlock];
}

+ (void) registerIfBlock
{
    HBHelperBlock ifBlock = ^(HBHelperCallingInfo* callingInfo) {
        BOOL boolarg = [HBHelperUtils evaluateObjectAsBool:callingInfo[0]];
        if (boolarg) {
            return callingInfo.statements(callingInfo.context, callingInfo.data);
        } else {
            return callingInfo.inverseStatements(callingInfo.context, callingInfo.data);
        }
    };
    [_builtinHelpersRegistry registerHelperBlock:ifBlock forName:@"if"];
}

+ (void) registerUnlessBlock
{
    HBHelperBlock unlessBlock = ^(HBHelperCallingInfo* callingInfo) {
        BOOL boolarg = [HBHelperUtils evaluateObjectAsBool:callingInfo[0]];
        if (!boolarg) {
            return callingInfo.statements(callingInfo.context, callingInfo.data);
        } else {
            return callingInfo.inverseStatements(callingInfo.context, callingInfo.data);
        }
    };
    [_builtinHelpersRegistry registerHelperBlock:unlessBlock forName:@"unless"];
}

+ (void) registerEachHelper
{
    HBHelperBlock eachBlock = ^(HBHelperCallingInfo* callingInfo) {

        id expression = callingInfo[0];
        HBDataContext* currentData = callingInfo.data;
        
        if (expression && [expression respondsToSelector:@selector(objectAtIndexedSubscript:)]) {
            // Array-like context
            if (![expression conformsToProtocol:@protocol(NSFastEnumeration)]) return (NSString*)nil;
            id<NSFastEnumeration> arrayLike = expression;
            
            NSInteger index = 0;
            HBDataContext* arrayData = currentData ? [currentData copy] : [HBDataContext new];
            NSMutableString* result = [NSMutableString string];
            for (id arrayElement in arrayLike) {
                arrayData[@"index"] = @(index);
                id statementEvaluation = callingInfo.statements(arrayElement, arrayData);
                if (statementEvaluation) [result appendString:statementEvaluation];
                index++;
            }
            [arrayData release];
            
            // special case for empty array-like contexts. Evaluate inverse section if they're empty (as per .js implementation).
            if (index == 0) {
                return callingInfo.inverseStatements(expression, currentData);
            } else {
                return (NSString*)result;
            }
            
        } else if (expression && [expression respondsToSelector:@selector(objectForKeyedSubscript:)]) {
            // Dictionary-like context
            if (![expression conformsToProtocol:@protocol(NSFastEnumeration)]) return (NSString*)nil;
            id<NSFastEnumeration> dictionaryLike = expression;

            HBDataContext* dictionaryData = currentData ? [currentData copy] : [HBDataContext new];
            NSMutableString* result = [NSMutableString string];
            for (id key in dictionaryLike) {
                dictionaryData[@"key"] = key;
                id statementEvaluation = callingInfo.statements(dictionaryLike[key], dictionaryData);
                if (statementEvaluation) [result appendString:statementEvaluation];
            }
            [dictionaryData release];
            
            return (NSString*)result;
        }
        
        return (NSString*)nil;
    };
    
    [_builtinHelpersRegistry registerHelperBlock:eachBlock forName:@"each"];
}

+ (void) registerWithBlock
{
    HBHelperBlock withBlock = ^(HBHelperCallingInfo* callingInfo) {
            return callingInfo.statements(callingInfo[0], callingInfo.data);
    };
    [_builtinHelpersRegistry registerHelperBlock:withBlock forName:@"with"];

}

+ (void) registerLogBlock
{
    HBHelperBlock logBlock = ^(HBHelperCallingInfo* callingInfo) {
        NSInteger level = 1;
        if (callingInfo.data[@"level"]) {
            level = [callingInfo.data[@"level"] integerValue];
        }
        [HBHandlebars log:level object:callingInfo[0]];
        return (NSString*)nil;
    };
    [_builtinHelpersRegistry registerHelperBlock:logBlock forName:@"log"];
}

@end
