//
//  HBAstParserTestVisitor.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 9/29/13.
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

#import "HBAstParserTestVisitor.h"

@interface HBAstParserTestVisitor()

@property (retain, nonatomic) NSMutableString* result;
@property NSInteger indentation;

@end

#define add_cr() [_result appendString:@"\n"]

@implementation HBAstParserTestVisitor

- (NSString*) testStringRepresentation
{
    self.result = [[NSMutableString new] autorelease];
    
    [self visitNode:self.rootNode];

    NSString* result = [[self.result retain] autorelease];
    self.result = nil;
    return result;
}

#pragma mark -
#pragma mark High-level nodes

- (id) visitBlock:(HBAstBlock*)node
{
    [_result appendString:@"BLOCK:\n  {{ "];
    if (node.expression) [self visitNode:node.expression];
    [_result appendString:@" }}\n"];
    
    if (node.statements) {
        [_result appendString:@"  PROGRAM:\n"];
        for (HBAstNode* statement in node.statements) {
            [_result appendString:@"    "];
            [self visitNode:statement];
            add_cr();
        }
    }
    
    if (node.inverseStatements) {
        [_result appendString:@"  {{^}}\n"];
        for (HBAstNode* statement in node.inverseStatements) {
            [_result appendString:@"    "];
            [self visitNode:statement];
            add_cr();
        }
    }
    return nil;
}

- (id) visitComment:(HBAstComment*)node
{
    [_result appendFormat:@"{{! '%@' }}", node.litteralValue];    
    return nil;
}

- (id) visitPartialTag:(HBAstPartialTag*)node
{
    [_result appendString:@"{{> "];
    if (node.partialName) [self visitNode:node.partialName];
    [_result appendString:@" "];
    if (node.context) {
        [self visitNode:node.context];
        [_result appendString:@" "];
    }
    
    if (node.namedParameters) {
        [self visitNode:node.namedParameters];
        [_result appendString:@" "];
    }
    
    [_result appendString:@"}}"];

    return nil;
}

- (id) visitProgram:(HBAstProgram*)node
{
    for (HBAstNode* statement in node.statements) {
        [self visitNode:statement];
        add_cr();
    }
    return nil;
}

- (id) visitRawText:(HBAstRawText*)node
{
    [_result appendFormat:@"CONTENT[ '%@' ]", node.litteralValue];
    return nil;
}

- (id) visitSimpleTag:(HBAstSimpleTag*)node
{
    [_result appendString:node.left_wsc ? @"{{~ " : @"{{ "];
    if (node.expression) [self visitNode:node.expression];
    [_result appendString:node.right_wsc ? @" ~}}": @" }}"];
    return nil;
}

- (id) visitTag:(HBAstTag*)node
{
    if (node.expression) [self visitNode:node.expression];
    return nil;
}


#pragma mark -
#pragma mark Expressions

- (id) visitContextualValue:(HBAstContextualValue*)node
{
    if (node.isDataValue) [_result appendString:@"@"];
    node.hasPathIdentifier ? [_result appendString:@"PATH:"] : [_result appendString:@"ID:"];
    for (HBAstKeyPathComponent* pathComponent in node.keyPath) [self visitNode:pathComponent];
    return nil;
}

- (id) visitExpression:(HBAstExpression*)node
{
    if (node.mainValue) [self visitNode:node.mainValue];
    [_result appendString:@" ["];
    BOOL firstPositionalParameter = true;
    if (node.positionalParameters) {
        for (HBAstValue* parameter in node.positionalParameters) {
            if (!firstPositionalParameter) [_result appendString:@", "];
            firstPositionalParameter = false;
            [self visitNode:parameter];
        }
    }
    [_result appendString:@"]"];
    
    if (node.namedParameters) {
        [self visitNode:node.namedParameters];
    }
    return nil;
}

- (id) visitKeyPathComponent:(HBAstKeyPathComponent*)node
{
    if (node.leadingSeparator) [_result appendString:node.leadingSeparator];
    [_result appendString:node.key];
    return nil;
}

- (id) visitNumber:(HBAstNumber*)node
{
    if (node.isBoolean) {
        [node.litteralValue boolValue] ? [_result appendString:@"BOOLEAN{true}"] : [_result appendString:@"BOOLEAN{false}"];
    } else {
        [_result appendFormat:@"NUMBER{%@}", [node.litteralValue stringValue]];
    }
    return nil;
}

- (id) visitString:(HBAstString*)node
{
    [_result appendFormat:@"\"%@\"", node.litteralValue];
    return nil;
}

- (id) visitValue:(HBAstValue*)node
{
    return nil;
}

- (id) visitParametersHash:(HBAstParametersHash*)node
{
    [_result appendString:@" HASH{"];
    BOOL firstNamedParameter = true;
    for (HBAstValue* parameterName in node) {
        if (!firstNamedParameter) [_result appendString:@", "];
        firstNamedParameter = false;
        [_result appendFormat:@"%@=", parameterName];
        [self visitNode:node[parameterName]];
    }
    [_result appendString:@"}"];
    
    return nil;
}


#pragma mark -

- (void) dealloc
{
    self.result = nil;
    [super dealloc];
}

@end
