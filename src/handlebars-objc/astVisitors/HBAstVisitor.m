//
//  HBAstVisitor.m
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

#import "HBAstVisitor.h"
#import "HBAst.h" 



@implementation HBAstVisitor

+ (SEL)visitorMethodForAstClassName:(NSString*)classname;
{
    static NSMutableDictionary* methodNames = nil;
    if (methodNames == nil) {
        methodNames = [[NSMutableDictionary alloc] init];
    }
    
    if (methodNames[classname] == nil) {
        NSAssert([classname hasPrefix:@"HBAst"], @"Ast class names must all start with 'HBAst' (%@)", classname);
        NSString* shortenedNodeClass = [classname substringFromIndex:5];
        NSString* methodName = [NSString stringWithFormat:@"visit%@:", shortenedNodeClass];
        methodNames[classname] = methodName;
    }
    
    return NSSelectorFromString(methodNames[classname]);
}

- (id) initWithRootAstNode:(HBAstNode*) rootNode;
{
    self = [super init];
    self.rootNode = rootNode;
    return self;
}

- (id) visitNode:(HBAstNode*)node
{
    NSString* nodeClass = NSStringFromClass([node class]);
    SEL visitorMethodSelector = [[self class] visitorMethodForAstClassName:nodeClass];
    NSMethodSignature* visitorMethodSignature = [self methodSignatureForSelector:visitorMethodSelector];
    
    id returnValue = nil;
    
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:visitorMethodSignature];
    [invocation setTarget:self];
    [invocation setSelector:visitorMethodSelector];
    [invocation setArgument:&node atIndex:2]; // first 2 args are hidden arguments in objc dispatch.
    [invocation invoke];
    [invocation getReturnValue:&returnValue];
    [[returnValue retain] autorelease];

    return returnValue;
}


#pragma mark -
#pragma mark High-level nodes

- (id) visitBlockTag:(HBAstBlockTag*)node
{
    return nil;
}

- (id) visitComment:(HBAstComment*)node
{
    return nil;
}

- (id) visitPartialTag:(HBAstPartialTag*)node
{
    return nil;
}

- (id) visitProgram:(HBAstProgram*)node
{
    return nil;
}

- (id) visitRawText:(HBAstRawText*)node
{
    return nil;
}

- (id) visitSimpleTag:(HBAstSimpleTag*)node
{
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
    return nil;
}

- (id) visitExpression:(HBAstExpression*)node
{
    return nil;
}

- (id) visitKeyPathComponent:(HBAstKeyPathComponent*)node
{
    return nil;
}

- (id) visitNumber:(HBAstNumber*)node
{
    return nil;
}

- (id) visitString:(HBAstString*)node
{
    return nil;
}

- (id) visitValue:(HBAstValue*)node
{
    return nil;
}



@end
