//
//  HBHelperCallingInfo.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/4/13.
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
#import "HBHelper.h"

@class HBDataContext;

typedef NSString* (^HBStatementsEvaluator)(id context, HBDataContext* data);

@interface HBHelperCallingInfo : NSObject

@property (readonly, retain, nonatomic) id context;
@property (readonly, retain, nonatomic) HBDataContext* data;

@property (readonly, retain, nonatomic) NSArray* positionalParameters;
@property (readonly, retain, nonatomic) NSDictionary* namedParameters;

@property (readonly, copy, nonatomic) HBStatementsEvaluator statements;
@property (readonly, copy, nonatomic) HBStatementsEvaluator inverseStatements;


// Shortcut APIs.

// Positional parameters can be accessed using array subscript API
// Accessing a non-existing index will return nil without raising any exception

- (id) objectAtIndexedSubscript:(NSUInteger)index;

// Named parameters can be accessed using keyed subscript API

- (id)objectForKeyedSubscript:(id)key;

@end
