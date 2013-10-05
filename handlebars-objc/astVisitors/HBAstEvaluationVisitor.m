//
//  HBAstEvaluationVisitor.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 9/30/13.
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

#import "HBAstEvaluationVisitor.h"
#import "HBHandlebars.h"
#import "HBAst.h"
#import "HBContextStack.h"
#import "HBContextState.h"
#import "HBDataContext.h"
#import "HBContextRendering.h"
#import "HBHelper.h"
#import "HBHelperRegistry.h"
#import "HBHelperCallingInfo.h"
#import "HBHelperCallingInfo_Private.h"
#import "HBTemplate.h"
#import "HBTemplate_Private.h"
#import "HBPartial.h"
#import "HBPartial_Private.h"

@interface HBAstEvaluationVisitor()
@property (retain, nonatomic) HBContextStack* contextStack;
@end

@implementation HBAstEvaluationVisitor

#pragma mark -
#pragma mark 'public' API

- (id) initWithTemplate:(HBTemplate*)template
{
    self.template = template;
    [template compile];
    self = [self initWithRootAstNode:template.program];
    return self;
}

- (NSString*) evaluateWithContext:(id)context
{
    // prepare context stack
    self.contextStack = [[HBContextStack new] autorelease];
    [self.contextStack push:[HBContextState stateWithContext:context data:nil]];

    // visit for real now
    NSString* result = [self visitNode:self.rootNode];
    
    return result;
}


#pragma mark -
#pragma mark Utilies

- (HBStatementsEvaluator)noopStatementsEvaluator
{
    return ^(id context, HBDataContext* data) {
        return @"";
    };
}

- (BOOL) expressionCanBeHelperCall:(HBAstExpression*)expression
{
    HBAstContextualValue* mainValue = expression.mainValue;
    if (mainValue.isDataValue) return false;
    if (mainValue.keyPath.count != 1) return false;
    
    if ([[mainValue.keyPath[0] key] isEqualToString:@"this"]) return false;
    
    return true;
}

- (BOOL) expressionIsHelperCall:(HBAstExpression*)expression
{
    if (expression.positionalParameters && expression.positionalParameters.count > 0) return true;
    if (expression.namedParameters && expression.namedParameters.count > 0) return true;
    
    if (![self expressionCanBeHelperCall:expression]) return false;
    
    // now, the only way to know is to search for the helper in registry.
    return [self helperForExpression:expression] != nil;
    
}

- (HBHelper*)helperForExpression:(HBAstExpression*)expression
{
    if (![self expressionCanBeHelperCall:expression]) return nil;
    
    NSString* helperName = [expression.mainValue.keyPath[0] key]; // we've checked this is valid right above
    return [self.template helperWithName:helperName];
}

- (void) evaluateContextualParametersInExpression:(HBAstExpression*)expression positionalParameters:(NSArray**)positionalParameters namedParameters:(NSDictionary**)namedParameters
{
    if (expression.positionalParameters) {
        NSMutableArray* _positionalParameters = [NSMutableArray array];
        *positionalParameters = _positionalParameters;
        for (HBAstValue* param in expression.positionalParameters) {
            id evaluatedParam = [self visitNode:param];
            if (nil == evaluatedParam) evaluatedParam = [NSNull null];
            [_positionalParameters addObject:evaluatedParam];
        }
    }
    
    if (expression.namedParameters) {
        NSMutableDictionary* _namedParameters = [NSMutableDictionary dictionary];
        *namedParameters = _namedParameters;
        for (NSString* paramName in expression.namedParameters) {
            HBAstValue* param = expression.namedParameters[paramName];
            id evaluatedParam = [self visitNode:param];
            if (nil == evaluatedParam) evaluatedParam = [NSNull null];
            _namedParameters[paramName] = evaluatedParam;
        }
    }
}

- (void) throwHelperNotFoundException:(NSString*)helperName
{
    NSException* myException = [NSException
                                exceptionWithName:@"HelperNotFound"
                                reason:[NSString stringWithFormat:@"Helper '%@' could not be found", helperName]
                                userInfo:nil];
    
    @throw myException;
}

- (void) throwPartialNotFoundException:(NSString*)partialName
{
    NSException* myException = [NSException
                                exceptionWithName:@"PartialNotFound"
                                reason:[NSString stringWithFormat:@"Partial '%@' could not be found", partialName]
                                userInfo:nil];
    
    @throw myException;
}

#pragma mark -
#pragma mark Visiting High-level nodes

- (id) visitBlockTag:(HBAstBlockTag*)node
{
    NSString* (^evaluateStatements)(id, HBDataContext*, NSArray*, BOOL) = ^(id context, HBDataContext* data, NSArray* statements, BOOL pushContext) {
        NSMutableString* result = [NSMutableString string];
        if (!statements || statements.count == 0) return (NSString*)nil;
        
        if (pushContext) [self.contextStack push:[HBContextState stateWithContext:context data:data]];
        for (HBAstNode* statement in statements) {
            id statementResult = [self visitNode:statement];
            if (statementResult && [statementResult isKindOfClass:[NSString class]])
                [result appendString:statementResult];
        }
        if (pushContext) [self.contextStack pop];
        
        return (NSString*)result;
    };
    
    HBStatementsEvaluator forwardStatementsEvaluator = ^(id context, HBDataContext* data) {
        return evaluateStatements(context, data, node.statements, true);
    };
    
    HBStatementsEvaluator inverseStatementsEvaluator = ^(id context, HBDataContext* data) {
        return evaluateStatements(nil, nil, node.inverseStatements, false);
    };
    
    
    if ([self expressionIsHelperCall:node.expression]) {
        // This is a block helper. Evaluate expression params and invoke helper
        
        HBHelper* helper = (HBHelper*)[self helperForExpression:node.expression];
        if (!helper) [self throwHelperNotFoundException:[node.expression.mainValue.keyPath[0] key]];
        
        NSArray* positionalParameters = nil;
        NSDictionary* namedParameters = nil;
        [self evaluateContextualParametersInExpression:node.expression positionalParameters:&positionalParameters namedParameters:&namedParameters];
        
        HBHelperCallingInfo* callingInfo = [[HBHelperCallingInfo alloc] init];
        
        callingInfo.context = self.contextStack.current.context;
        callingInfo.data = self.contextStack.current.dataContext;
        callingInfo.positionalParameters = positionalParameters;
        callingInfo.namedParameters = namedParameters;
        callingInfo.statements = forwardStatementsEvaluator;
        callingInfo.inverseStatements = inverseStatementsEvaluator;
        
        NSString* helperResult = helper.block(callingInfo);
        [callingInfo release];
        
        return helperResult;
    } else {
        // This is a normal block.
        
        id evaluatedExpression = [self visitExpression:node.expression];
        HBDataContext* currentData = [[self.contextStack current] dataContext];
                                      
        if (evaluatedExpression && [evaluatedExpression respondsToSelector:@selector(objectAtIndexedSubscript:)]) {
            // Array-like context
            id<NSFastEnumeration> arrayLike = evaluatedExpression;
            NSInteger index = 0;
            HBDataContext* arrayData = [[self.contextStack current] dataContextCopyOrNew];
            NSMutableString* result = [NSMutableString string];
            for (id arrayElement in arrayLike) {
                arrayData[@"index"] = @(index);
                id statementEvaluation = forwardStatementsEvaluator(arrayElement, arrayData);
                if (statementEvaluation) [result appendString:statementEvaluation];
                index++;
            }
            [arrayData release];
            
            // special case for empty array-like contexts. Evaluate inverse section if they're empty (as per .js implementation).
            if (index == 0) {
                return inverseStatementsEvaluator(evaluatedExpression, currentData);
            } else {
                return result;
            }
            
        } else if (evaluatedExpression && [evaluatedExpression respondsToSelector:@selector(objectForKeyedSubscript:)]) {
            // Dictionary-like context
            return forwardStatementsEvaluator(evaluatedExpression, currentData);
            
        } else {
            // String of scalar context
            if ([HBHandlebars evaluateObjectAsBool:evaluatedExpression]) {
                return forwardStatementsEvaluator(evaluatedExpression, currentData);
            } else {
                return inverseStatementsEvaluator(evaluatedExpression, currentData);
            }
        }
    }
    return nil;
}

- (id) visitComment:(HBAstComment*)node
{
    return nil;
}

- (id) visitPartialTag:(HBAstPartialTag*)node
{
    HBAstValue* partialNameNode = node.partialName;
    NSString* partialName = nil;
    
    // XXX - use sourceRepresentation method once it's defined on all astNodes
    if ([partialNameNode isKindOfClass:[HBAstNumber class]]) {
        partialName = [[(HBAstNumber*)partialNameNode litteralValue] stringValue];
    } else if ([partialNameNode isKindOfClass:[HBAstString class]]) {
        partialName = [(HBAstString*)partialNameNode litteralValue];
    } else if ([partialNameNode isKindOfClass:[HBAstContextualValue class]]) {
        partialName = [(HBAstContextualValue*)partialNameNode sourceRepresentation];
    }

    HBPartial* partial = [self.template partialWithName:partialName];
    
    // throw if partial not found
    if (!partial) {
        [self throwPartialNotFoundException:partialName];
    }
    
    BOOL shouldPopContext = false;
    if (node.context) {
        id evaluatedContext = [self visitNode:node.context];
        HBDataContext* data = self.contextStack.current.dataContext;
        [self.contextStack push:[HBContextState stateWithContext:evaluatedContext data:data]];
        shouldPopContext = true;
    }
    
    NSMutableString* buffer = [NSMutableString string];
    for (HBAstNode* statement in partial.astStatements) {
        id result = [self visitNode:statement];
        if (result && [result isKindOfClass:[NSString class]])
            [buffer appendString:result];
    }
    
    if (shouldPopContext) [self.contextStack pop];
    
    return buffer;
}

- (id) visitProgram:(HBAstProgram*)node
{
    NSMutableString* buffer = [NSMutableString string];
    for (HBAstNode* statement in node.statements) {
        id result = [self visitNode:statement];
        if (result && [result isKindOfClass:[NSString class]])
            [buffer appendString:result];
    }
    return buffer;
}

- (id) visitRawText:(HBAstRawText*)node
{
    return node.litteralValue;
}

- (id) visitSimpleTag:(HBAstSimpleTag*)node
{
    if (!node.expression) return nil;
    
    // helpers
    if ([self expressionIsHelperCall:node.expression]) {
        HBHelper* helper = (HBHelper*)[self helperForExpression:node.expression];
        if (!helper) [self throwHelperNotFoundException:[node.expression.mainValue.keyPath[0] key]];
        NSArray* positionalParameters = nil;
        NSDictionary* namedParameters = nil;
        [self evaluateContextualParametersInExpression:node.expression positionalParameters:&positionalParameters namedParameters:&namedParameters];

        HBHelperCallingInfo* callingInfo = [[HBHelperCallingInfo alloc] init];

        callingInfo.context = self.contextStack.current.context;
        callingInfo.data = self.contextStack.current.dataContext;
        callingInfo.positionalParameters = positionalParameters;
        callingInfo.namedParameters = namedParameters;
        callingInfo.statements = [self noopStatementsEvaluator];
        callingInfo.inverseStatements = [self noopStatementsEvaluator];
        
        NSString* helperResult = helper.block(callingInfo);
        [callingInfo release];

        return helperResult;
    }
    
    // native expressions
    {
        id evaluatedExpression = [self visitExpression:node.expression];
        if (evaluatedExpression && [evaluatedExpression respondsToSelector:@selector(renderValueForHandlebars)]) {
            NSString* renderedValue = [evaluatedExpression renderValueForHandlebars];
            if (node.escape) renderedValue = [HBHandlebars escapeHTML:renderedValue];
            return renderedValue;
        }
    }

    return nil;
}

- (id) visitTag:(HBAstTag*)node
{
    return nil;
}


#pragma mark -
#pragma mark Expressions

- (id) visitContextualValue:(HBAstContextualValue*)node
{
    return [self.contextStack.current evaluateContextualValue:node];
}

- (id) visitExpression:(HBAstExpression*)node
{
    return [self visitContextualValue:node.mainValue];
}

- (id) visitKeyPathComponent:(HBAstKeyPathComponent*)node
{
    return nil;
}

- (id) visitNumber:(HBAstNumber*)node
{
    return node.litteralValue;
}

- (id) visitString:(HBAstString*)node
{
    return node.litteralValue;
}

- (id) visitValue:(HBAstValue*)node
{
    return nil;
}

@end
