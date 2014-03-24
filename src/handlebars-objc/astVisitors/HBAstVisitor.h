//
//  HBAstVisitor.h
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

#import <Foundation/Foundation.h>

#import "HBAst.h"

@interface HBAstVisitor : NSObject

@property (retain, nonatomic) HBAstNode* rootNode;

// designated initializer

- (id) initWithRootAstNode:(HBAstNode*)rootNode;

// visiting a node

- (id) visitNode:(HBAstNode*)node;


// -- Methods that must be implemented by concrete subclasses --


// High-level nodes

- (id) visitBlock:(HBAstBlock*)node;
- (id) visitPartialTag:(HBAstPartialTag*)node;
- (id) visitComment:(HBAstComment*)node;
- (id) visitProgram:(HBAstProgram*)node;
- (id) visitRawText:(HBAstRawText*)node;
- (id) visitSimpleTag:(HBAstSimpleTag*)node;
- (id) visitTag:(HBAstTag*)node;

// Expressions

- (id) visitContextualValue:(HBAstContextualValue*)node;
- (id) visitExpression:(HBAstExpression*)node;
- (id) visitKeyPathComponent:(HBAstKeyPathComponent*)node;
- (id) visitNumber:(HBAstNumber*)node;
- (id) visitString:(HBAstString*)node;
- (id) visitValue:(HBAstValue*)node;
- (id) visitParametersHash:(HBAstParametersHash*)node;

@end
