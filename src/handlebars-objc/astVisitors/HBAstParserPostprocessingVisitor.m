//
//  HBAstParserPostprocessingVisitor.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 3/23/14.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
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

#import "HBAstParserPostprocessingVisitor.h"
#import "HBAstRawText.h"
#import "HBAstTag.h"

@interface HBAstParserPostprocessingVisitor()

@property (retain, nonatomic) HBAstRawText* lastVisitedRawTextNode;
@property (retain, nonatomic) HBAstTag* lastVisitedTag;

@end


@implementation HBAstParserPostprocessingVisitor

- (void) trimEndingWhiteSpaces:(HBAstRawText*)node
{
    NSString* string = node.litteralValue;
    if (!string) return;
    
    NSInteger i = [string length] - 1;
    NSInteger l = i;
    while ((i >= 0)
           && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[string characterAtIndex:i]]) {
        i--;
    }
    
    if (i < l) {
        node.litteralValue = [string substringToIndex:i+1];
    }
}

- (void) trimStartingWhiteSpaces:(HBAstRawText*)node
{
    NSString* string = node.litteralValue;
    
    NSInteger i = 0;
    while ((i < [string length])
           && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[string characterAtIndex:i]]) {
        i++;
    }
    
    if (i > 0) {
        node.litteralValue = [string substringFromIndex:i];
    }
}

- (void) processTag:(HBAstTag*)tag
{
    self.lastVisitedTag = tag;
    HBAstRawText* lastRawTextNode = self.lastVisitedRawTextNode;
    self.lastVisitedRawTextNode = nil;
    
    if (!lastRawTextNode) return;
    
    if (lastRawTextNode && tag.left_wsc) {
        [self trimEndingWhiteSpaces:lastRawTextNode];
    }
}

#pragma mark -
#pragma mark High-level nodes

- (id) visitBlock:(HBAstBlock*)node
{
    [self processTag:node.openTag];
    self.lastVisitedRawTextNode = nil;
    if (node.statements) {
        for (HBAstNode* statement in node.statements) {
            [self visitNode:statement];
        }
    }

    if (node.elseTag) [self processTag:node.elseTag];

    if (node.inverseStatements) {
        for (HBAstNode* statement in node.inverseStatements) {
            [self visitNode:statement];
        }
    }
    
    [self processTag:node.closeTag];
    
    return nil;
}

- (id) visitComment:(HBAstComment*)node
{
    self.lastVisitedTag = nil;
    self.lastVisitedRawTextNode = nil;
    return nil;
}

- (id) visitPartialTag:(HBAstPartialTag*)node
{
    [self processTag:node];
    self.lastVisitedRawTextNode = nil;
    return nil;
}

- (id) visitProgram:(HBAstProgram*)node
{
    for (HBAstNode* statement in node.statements) {
        [self visitNode:statement];
    }
    return nil;
}

- (id) visitRawText:(HBAstRawText*)node
{
    self.lastVisitedRawTextNode = node;
    if (self.lastVisitedTag && self.lastVisitedTag.right_wsc) {
        [self trimStartingWhiteSpaces:node];
    }
    self.lastVisitedTag = nil;
    return nil;
}

- (id) visitSimpleTag:(HBAstSimpleTag*)node
{
    [self processTag:node];
    self.lastVisitedRawTextNode = nil;
    return nil;
}

- (id) visitTag:(HBAstTag*)node
{
    NSAssert(true, @"should not reach");
   return nil;
}


#pragma mark -

- (void) dealloc
{
    self.lastVisitedRawTextNode = nil;
    self.lastVisitedTag = nil;
    
    [super dealloc];
}

@end
