//
//  HBBuiltinHelpersRegistry.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/5/13.
//
//  The MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import "HBBuiltinHelpersRegistry.h"
#import "HBHandlebars.h"
#import "HBHelperCallingInfo_Private.h"
#import "HBAstEvaluationVisitor.h"
#import "HBTemplate_Private.h"
#import "HBEscapedString.h"

static HBBuiltinHelpersRegistry* _builtinHelpersRegistry = nil;

@interface HBBuiltinHelpersRegistry()

+ (void) registerIfBlock;
+ (void) registerUnlessBlock;
+ (void) registerEachHelper;
+ (void) registerWithBlock;
+ (void) registerLogBlock;
+ (void) registerLocalizeBlock;
+ (void) registerIsBlock;
+ (void) registerGtBlock;
+ (void) registerGteBlock;
+ (void) registerLtBlock;
+ (void) registerLteBlock;
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
    [self registerLocalizeBlock];
    [self registerIsBlock];
    [self registerGtBlock];
    [self registerGteBlock];
    [self registerLtBlock];
    [self registerLteBlock];
    [self registerSetEscapingBlock];
    [self registerEscapeBlock];
}

+ (BOOL) _firstParamEvaluatesToTrue:(HBHelperCallingInfo*) callingInfo
{
    id value = callingInfo[0];
    
    BOOL includeZero = [HBHelperUtils evaluateObjectAsBool:callingInfo[@"includeZero"]];
    BOOL zeroAndIncludeZero = includeZero && value && [value isKindOfClass:[NSNumber class]] && ([value integerValue] == 0);
    
    return [HBHelperUtils evaluateObjectAsBool:value] || zeroAndIncludeZero;
}

+ (void) registerIfBlock
{
    HBHelperBlock ifBlock = ^(HBHelperCallingInfo* callingInfo) {
        
        if ([HBBuiltinHelpersRegistry _firstParamEvaluatesToTrue:callingInfo]) {
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
        if (![HBBuiltinHelpersRegistry _firstParamEvaluatesToTrue:callingInfo]) {
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

        id expression = nil;
        if ([callingInfo.positionalParameters count] > 0) {
            expression = callingInfo[0];
        } else {
            expression = callingInfo.context;
        }
        
        HBDataContext* currentData = callingInfo.data;
        
        if (expression && [HBHelperUtils isEnumerableByIndex:expression]) {
            // Array-like context
            id<NSFastEnumeration> arrayLike = expression;
            
            NSInteger index = 0;
            HBDataContext* arrayData = currentData ? [currentData copy] : [HBDataContext new];
            NSMutableString* result = [NSMutableString string];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
            NSInteger objectCount = 0;
            for (id arrayElement in arrayLike) { objectCount++; } // compute element counts. Should be in helper utils and optimized in trivial cases.
#pragma clang diagnostic pop

            for (id arrayElement in arrayLike) {
                arrayData[@"index"] = @(index);
                arrayData[@"first"] = @(index == 0);
                arrayData[@"last"] = @(index == (objectCount-1));
                
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
            
        } else if (expression && [HBHelperUtils isEnumerableByKey:expression]) {
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

+ (void) registerLocalizeBlock
{
    HBHelperBlock localizeBlock = ^(HBHelperCallingInfo* callingInfo) {
        NSString* result = nil;
        if (callingInfo.positionalParameters.count > 0) {
            NSString* key = callingInfo[0];
            NSString* localizedVersion = [callingInfo.template localizedString:key];
            return localizedVersion;
        }
        return result;
    };
    [_builtinHelpersRegistry registerHelperBlock:localizeBlock forName:@"localize"];
    [_builtinHelpersRegistry registerHelperBlock:localizeBlock forName:@"i18n"];
}


+ (NSComparisonResult) compare2FirstPositionalParameters:(HBHelperCallingInfo*)callingInfo validity:(BOOL*)comparisonValid
{
    BOOL valid = true;
    id obj0 = nil;
    id obj1 = nil;
    
    if (2 != [[callingInfo positionalParameters] count]) {
        *comparisonValid = false;
        return NSOrderedAscending;
    }
    
    if ([callingInfo[1] isKindOfClass:[NSString class]]) {
        obj1 = callingInfo[1];
        
        if ([callingInfo[0] isKindOfClass:[NSString class]]) {
            obj0 = callingInfo[0];
        } else if ([callingInfo[0] isKindOfClass:[NSNumber class]]) {
            obj0 = [callingInfo[0] stringValue];
        } else {
            valid = NO;
        }
    } else if ([callingInfo[1] isKindOfClass:[NSNumber class]]) {
        obj1 = callingInfo[1];
        
        if ([callingInfo[0] isKindOfClass:[NSNumber class]]) {
            obj0 = callingInfo[0];
        } else if ([callingInfo[0] isKindOfClass:[NSString class]]) {
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            
            obj0 = [f numberFromString:callingInfo[0]];
            
            [f release];
        } else {
            valid = NO;
        }
    }
    
    *comparisonValid = valid;
    if (!valid) {
        return NSOrderedAscending;
    }
    
    return [obj0 compare:obj1];
}


+ (void) registerIsBlock
{
    HBHelperBlock isBlock = ^(HBHelperCallingInfo* callingInfo) {
        BOOL comparisonIsValid;
        NSComparisonResult comparisonResult = [[self class] compare2FirstPositionalParameters:callingInfo validity:&comparisonIsValid];
        
        if (comparisonIsValid && comparisonResult == NSOrderedSame) {
            return callingInfo.statements(callingInfo.context, callingInfo.data);
        } else {
            return callingInfo.inverseStatements(callingInfo.context, callingInfo.data);
        }
    };
    
    [_builtinHelpersRegistry registerHelperBlock:isBlock forName:@"is"];
}

+ (void) registerGtBlock
{
    HBHelperBlock gtBlock = ^(HBHelperCallingInfo* callingInfo) {
        BOOL comparisonIsValid;
        NSComparisonResult comparisonResult = [[self class] compare2FirstPositionalParameters:callingInfo validity:&comparisonIsValid];
        
        if (comparisonIsValid && comparisonResult == NSOrderedDescending) {
            return callingInfo.statements(callingInfo.context, callingInfo.data);
        } else {
            return callingInfo.inverseStatements(callingInfo.context, callingInfo.data);
        }
    };
    
    [_builtinHelpersRegistry registerHelperBlock:gtBlock forName:@"gt"];
}

+ (void) registerGteBlock
{
    HBHelperBlock gtBlock = ^(HBHelperCallingInfo* callingInfo) {
        BOOL comparisonIsValid;
        NSComparisonResult comparisonResult = [[self class] compare2FirstPositionalParameters:callingInfo validity:&comparisonIsValid];
        
        if (comparisonIsValid && (comparisonResult == NSOrderedDescending || comparisonResult == NSOrderedSame)) {
            return callingInfo.statements(callingInfo.context, callingInfo.data);
        } else {
            return callingInfo.inverseStatements(callingInfo.context, callingInfo.data);
        }
    };
    
    [_builtinHelpersRegistry registerHelperBlock:gtBlock forName:@"gte"];
}

+ (void) registerLtBlock
{
    HBHelperBlock gtBlock = ^(HBHelperCallingInfo* callingInfo) {
        BOOL comparisonIsValid;
        NSComparisonResult comparisonResult = [[self class] compare2FirstPositionalParameters:callingInfo validity:&comparisonIsValid];
        
        if (comparisonIsValid && comparisonResult == NSOrderedAscending) {
            return callingInfo.statements(callingInfo.context, callingInfo.data);
        } else {
            return callingInfo.inverseStatements(callingInfo.context, callingInfo.data);
        }
    };
    
    [_builtinHelpersRegistry registerHelperBlock:gtBlock forName:@"lt"];
}

+ (void) registerLteBlock
{
    HBHelperBlock gtBlock = ^(HBHelperCallingInfo* callingInfo) {
        BOOL comparisonIsValid;
        NSComparisonResult comparisonResult = [[self class] compare2FirstPositionalParameters:callingInfo validity:&comparisonIsValid];
        
        if (comparisonIsValid && (comparisonResult == NSOrderedAscending || comparisonResult == NSOrderedSame)) {
            return callingInfo.statements(callingInfo.context, callingInfo.data);
        } else {
            return callingInfo.inverseStatements(callingInfo.context, callingInfo.data);
        }
    };
    
    [_builtinHelpersRegistry registerHelperBlock:gtBlock forName:@"lte"];
}

+ (void) registerSetEscapingBlock
{
    HBHelperBlock setEscapingBlock = ^(HBHelperCallingInfo* callingInfo) {
        NSString* result = nil;
        NSString* mode = nil;
        if (callingInfo.positionalParameters.count > 0) {
            NSString* param = callingInfo.positionalParameters[0];
            if ([param isKindOfClass:[NSString class]]) mode = param;
        }
        
        if (mode) {
            [callingInfo.evaluationVisitor pushEscapingMode:mode];
        }
        
        result = callingInfo.statements(callingInfo.context, callingInfo.data);
        
        if (mode) {
            [callingInfo.evaluationVisitor popEscapingMode];
        }
        return result;
    };
    [_builtinHelpersRegistry registerHelperBlock:setEscapingBlock forName:@"setEscaping"];
}

+ (void) registerEscapeBlock
{
    HBHelperBlock escapeBlock = ^(HBHelperCallingInfo* callingInfo) {
        NSString* mode = nil;
        if (callingInfo.positionalParameters.count > 0) {
            NSString* param = callingInfo.positionalParameters[0];
            if ([param isKindOfClass:[NSString class]]) mode = param;
        }
        
        if (!mode) {
            return @"";
        }
        
        NSString* value = callingInfo.positionalParameters[1];
        NSString* result = [callingInfo.template escapeString:value forTargetFormat:mode];
        return (NSString*)[[[HBEscapedString alloc] initWithString:result] autorelease];
    };
    [_builtinHelpersRegistry registerHelperBlock:escapeBlock forName:@"escape"];
}

@end
