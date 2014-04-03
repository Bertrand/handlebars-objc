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
#import "HBErrorHandling_Private.h"
#import "HBEscapedString.h"
#import "HBEscapedString_Private.h"

@interface HBAstEvaluationVisitor()
@property (retain, nonatomic) HBContextStack* contextStack;
@property (retain, nonatomic) NSMutableArray* escapingModeStack;
@end

//
//
// The following two macros are a trick to circumvent NSMutableString ignoring the
// capacity in initWithCapacity: initializer
//
// Instead, we use a CFMutableString with capped length. Those are optimized for real
// and will show much better performances. But they do not autogrow beyond the capped
// length.
//
// So we use a capped CF string until we reach its max size and then fallback to
// normal NSMutableString beyond.
//
// The key of course is to properly evaluate resulting string length.
//
// We use macros instead of a method call since benchmark gave much better results this
// way.
//
//

#define CREATE_FASTER_MUTABLE_STRING(__buffer_name__, __estimated_length__) \
    BOOL __buffer_name__##usingCappedString = true; \
    NSInteger __buffer_name__##cappedLength = (__estimated_length__); \
    NSMutableString* __buffer_name__ = (NSMutableString*)CFStringCreateMutable(0, __buffer_name__##cappedLength)

#define APPEND_STRING_TO_FASTER_MUTABLE_STRING(__buffer_name__, __string_to_append__) \
    if (__buffer_name__##usingCappedString && ([__buffer_name__ length] + [__string_to_append__ length] > __buffer_name__##cappedLength)) { \
        NSMutableString* __buffer_name__##newBuffer = [__buffer_name__ mutableCopy]; \
        [__buffer_name__ release]; \
        __buffer_name__ = __buffer_name__##newBuffer; \
        __buffer_name__##usingCappedString = false; \
    } \
    if ([__string_to_append__ isKindOfClass:[HBEscapedString class]]) { \
        [__buffer_name__ appendString:[__string_to_append__ actualString]]; \
    } else { \
        [__buffer_name__ appendString:__string_to_append__]; \
    } \
    do {} while(0)


@implementation HBAstEvaluationVisitor

#pragma mark -
#pragma mark 'public' API

- (id) initWithTemplate:(HBTemplate*)template
{
    self.template = template;
    NSAssert(template.program != nil, @"Invalid condition: template provided to HBAstEvaluationVisitor is not compiled or compilation failed");
    self = [self initWithRootAstNode:template.program];
    return self;
}

- (NSString*) evaluateWithContext:(id)context
{
    // Root data context
    HBDataContext* dataContext = nil;
    if (context) {
        dataContext = [[HBDataContext new] autorelease];
        dataContext[@"root"] = context;
    }
    
    // prepare context stack
    self.contextStack = [[HBContextStack new] autorelease];
    [self.contextStack push:[HBContextState stateWithContext:context data:dataContext]];

    // visit for real now
    NSString* result = [self visitNode:self.rootNode];
    
    return result;
}

#pragma mark -
#pragma Escaping Modes

- (void) pushEscapingMode:(NSString*)mode
{
    if (nil == self.escapingModeStack) self.escapingModeStack = [[[NSMutableArray alloc] init] autorelease];
    [self.escapingModeStack addObject:mode];
}

- (void) popEscapingMode
{
    NSAssert(self.escapingModeStack && self.escapingModeStack.count > 0, @"Escaping mode stack is empty");
    [self.escapingModeStack removeLastObject];
}

- (NSString*) currentEscapingMode
{
    return [self.escapingModeStack lastObject];
}

- (NSString*) escapeStringAccordingToCurrentMode:(NSString*)rawString
{
    return [self.template escapeString:rawString forTargetFormat:[self currentEscapingMode]];
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
    return [self.template helperForName:helperName];
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


#pragma mark -
#pragma mark Visiting High-level nodes

- (id) visitBlock:(HBAstBlock*)node
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
        if (!helper) {
            if (!self.error) // we report only one error for now.
                self.error = [HBHelperMissingError HBHelperMissingErrorWithHelperName:[node.expression.mainValue.keyPath[0] key]];
            return nil;
        }
        
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
        callingInfo.template = self.template;
        callingInfo.evaluationVisitor = self;
        callingInfo.invocationKind = HBHelperInvocationBlock;

        NSString* helperResult = helper.block(callingInfo);
        [callingInfo release];
        
        return helperResult;
    } else {
        // This is a normal block.
        
        id evaluatedExpression = [self visitExpression:node.expression];
        HBDataContext* currentData = [[self.contextStack current] dataContext];
                                      
        if ([HBHelperUtils isEnumerableByIndex:evaluatedExpression] ) {
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
            
        } else if (evaluatedExpression == nil || [evaluatedExpression isKindOfClass:[NSString class]] || [evaluatedExpression isKindOfClass:[NSNumber class]]) {
            // String of scalar context
            if ([HBHelperUtils evaluateObjectAsBool:evaluatedExpression]) {
                return forwardStatementsEvaluator(evaluatedExpression, currentData);
            } else {
                return inverseStatementsEvaluator(evaluatedExpression, currentData);
            }
        } else {
            // Dictionary-like context
            return forwardStatementsEvaluator(evaluatedExpression, currentData);            
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
    if (self.error) return nil;
    HBAstValue* partialNameNode = node.partialName;
    NSString* partialName = [partialNameNode sourceRepresentation];

    HBPartial* partial = [self.template partialForName:partialName];
    if (!partial) {
        if (!self.error) // we report only one error for now.
            self.error = [HBPartialMissingError HBPartialMissingErrorWithPartialName:partialName];
        return nil;
    }
    
    NSError* partialParseError = nil;
    [partial compile:&partialParseError];
    
    if (partialParseError) {
        if (!self.error) // we report only one error for now.
            self.error = partialParseError;
        return nil;
    }
    
    BOOL shouldPopContext = false;
    if (node.context) {
        id evaluatedContext = [self visitNode:node.context];
        HBDataContext* data = self.contextStack.current.dataContext;
        [self.contextStack push:[HBContextState stateWithContext:evaluatedContext data:data]];
        shouldPopContext = true;
    }
    
    if (node.namedParameters) {
        NSDictionary* partialParams = [self visitNode:node.namedParameters];
        self.contextStack.current.mergedAttributes = partialParams;
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
    CREATE_FASTER_MUTABLE_STRING(buffer, 1.2 * self.template.templateString.length);
    
    @autoreleasepool {
        for (HBAstNode* statement in node.statements) {
            id result = [self visitNode:statement];
            if (result && [result isKindOfClass:[NSString class]]) {
                APPEND_STRING_TO_FASTER_MUTABLE_STRING(buffer, result);
            }
        }
    }
    
    [buffer autorelease];
    return buffer;
}


- (id) visitRawText:(HBAstRawText*)node
{
    return node.litteralValue;
}

- (id) visitSimpleTag:(HBAstSimpleTag*)node
{
    if (!node.expression) return nil;
    
    NSString* renderedValue = renderForHandlebars([self visitExpression:node.expression]);
    if (node.escape && (![renderedValue isKindOfClass:[HBEscapedString class]]))
        renderedValue = [self escapeStringAccordingToCurrentMode:renderedValue];

    return renderedValue;
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

- (id) visitExpression:(HBAstExpression*)expression
{
    // helpers
    if ([self expressionIsHelperCall:expression]) {
        HBHelper* helper = (HBHelper*)[self helperForExpression:expression];
        if (!helper) {
            if (!self.error) // we report only one error for now.
                self.error = [HBHelperMissingError HBHelperMissingErrorWithHelperName:[expression.mainValue.keyPath[0] key]];
            return nil;
        }
        
        NSArray* positionalParameters = nil;
        NSDictionary* namedParameters = nil;
        [self evaluateContextualParametersInExpression:expression positionalParameters:&positionalParameters namedParameters:&namedParameters];
        
        HBHelperCallingInfo* callingInfo = [[HBHelperCallingInfo alloc] init];
        
        callingInfo.context = self.contextStack.current.context;
        callingInfo.data = self.contextStack.current.dataContext;
        callingInfo.positionalParameters = positionalParameters;
        callingInfo.namedParameters = namedParameters;
        callingInfo.statements = [self noopStatementsEvaluator];
        callingInfo.inverseStatements = [self noopStatementsEvaluator];
        callingInfo.template = self.template;
        callingInfo.evaluationVisitor = self;
        callingInfo.invocationKind = HBHelperInvocationExpression;
        
        NSString* helperResult = helper.block(callingInfo);
        [callingInfo release];
        
        return helperResult;
    }
    
    // simple contextual expression
    return [self visitContextualValue:expression.mainValue];
    
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

- (id) visitParametersHash:(HBAstParametersHash*)node
{
    NSMutableDictionary* namedParameters = [NSMutableDictionary dictionary];
    for (NSString* paramName in node) {
        HBAstValue* param = node[paramName];
        id evaluatedParam = [self visitNode:param];
        if (nil == evaluatedParam) evaluatedParam = [NSNull null];
        namedParameters[paramName] = evaluatedParam;
    }
    
    return namedParameters;
}

#pragma mark -

- (void) dealloc
{
    self.template = nil;
    self.error = nil;
    self.contextStack = nil;
    [super dealloc];
}

@end
