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
@class HBTemplate;

typedef NSString* (^HBStatementsEvaluator)(id context, HBDataContext* data);

/**
 Invocation kind. Lets helper know if it was invoked as a block helper or an expression helper.
 */
typedef NS_ENUM(NSUInteger, HBHelperInvocationKind) {
    /** helper invoked as expression helper */
    HBHelperInvocationExpression    = 0,
    /** helper invoked as block helper */
    HBHelperInvocationBlock         = 1,
};

/**
 
 Understanding HBHelperCallingInfo is central to the development of Handlebars helpers in handlebars-objc. If you're not trying to develop a helper, you don't need to read this document. 
 
 If you are trying to develop a helper, you *need* to read this documentation in details.
 
 ## Prerequisites ##
 
 This page assumes you know enough about herlps and their usage in Handlebars templates.

 Please see [Handlebars.js documentation](http://handlebars.js) for details about helpers. In particular, please read the "Helpers" section in Handlebars.js documentation of [expressions](http://handlebarsjs.com/expressions.html) and the page specific to [block helpers](http://handlebarsjs.com/block_helpers.html).
 
 In particular, make sure you understand what is a Handlebars context, what are helper parameters, and the difference between expression helpers and block helpers.
 
 Now let's dive a little bit deeper into HBHelperCallingInfo.
 
 ## What is HBHelperCallingInfo ##
 
 The typical implementation of a helper using an objective-C block looks like the following:
 
     HBHelperBlock myHelper = (^)(HBHelperCallingInfo* callingInfo) {
         // helper code
         // ....
         return result; // where result is a string containing what we'll be inserted in the evaluated template where the helper was called.
     }
 
 As you can see, the helper implementation blocks receive an single argument of class HBHelperCallingInfo which holds all the contextual information usable by the helper at calling time:
 
 - Handlebars context
 - Private data set by other helpers in parent scopes
 - Parameters passed to the helpers in template expression
 - Template block passed to the helper (Block helpers only)
 - Inverse section passed to the helper (Block helpers only). 
 
 ## Context ## 
 
 You access the context using the <context> property:
 
    ...
    NSString* authorName = callingInfo.context[@"author_name"]; 
    ...

 Contexts are usual objective-C objects, provided by the application using handlebars-objc, and your application should consider those objects immutable. It is a *huge* mistake to modify contexts passed to your helper. You can try to copy them, you can even replace them by new objects when evaluating blocks passed to the helper, but you should never modify the context you do not own. Really. 
 
 ## Helper parameters ##
 
 One of the key feature of Handlebars.js is the ability for template writers to pass parameters to the helpers. Those parameters, directly specified in the template (and not in the context), can be general view configuration settings (that's why they should never be set in context), and can be anything, valid in a Handlebars expression (context identifiers, string or number literals, boolean literals or private variables). 
 
 Your helper implementation can access parameters using the <positionalParameters> and <namedParameters> properties. 
 
 ## Private variables ## 
 
 Another important feature of Handlebars.js is the ability for block helpers to write private variables available to descendant blocks. Please see [Handlebars.js helper page](http://handlebarsjs.com/block_helpers.html) for some information about private variables in block helpers. 
 
 You access private variables set by parent helpers using the <data> property. 
 
 If your helper needs to set a private variable, please make sure to carefully read the documentation of <HBDataContext>. 
 
 ## Executing the block passed to the helper ##
 
 Block helpers generally receive a sub-template to execute. In handlebars-objc, they are called "Helper statements".
 Depending on the nature of your helper, this block can be used to iterate over some contextual value (like for instance the #each built-in helper), or act as a conditional block (like the #if built-in template). 
 
 To access and evaluate the statements, use the <statements> property.
 
 Note that even if a template uses your helper with an empty block or as an expression helper, handlebars-objc always provide a non-nil <statements> value (which is a no-op).
 
 ## Inverse section ##
 
 Block helper used as conditional in Handlebars templates can optionally receive an inverse section that is executed when the helper condition is not met. 
 (Please see the #if built-in helper in Handlebars.js [documentation](http://handlebarsjs.com/block_helpers.html) for an example). 
 
 You access the inverse section using the <inverseStatement> property. 
 
 Note that even when a templates provides no inverse section, handlebars-objc always sets one (that is a no-op) in the callingInfo. In other words you can safely assume you can evaluate the inverse statements of a helper in your implementation.
 
 
 */

@interface HBHelperCallingInfo : NSObject

/**
 Handlebars context
 
 Handlebars context is the data model provided to the template for rendering.
 It can be any objective-C object, but unless you know what you're doing, you
 should make sure you provide property-list objects.
 See [Apple documentation](https://developer.apple.com/library/mac/documentation/general/conceptual/devpedia-cocoacore/PropertyList.html) for a list of such objects.
 
 @since v1.0
 */
@property (readonly, retain, nonatomic) id context;

/** 
 Handlebars private variables
 
 Handlebars supports setting and accessing private variables in helpers and in templates. For example, the #each helper, while iterating over an array, sets a private variable containing the current index. This private variable is named "index" and can be referred to as @index in templates and via the data access on HBHelperCallingInfo within helpers implementation. 
 While helpers can read and set private variables, they should never modify the data context they received directly but instead copy it first and modify the copy before passing it to descendant contexts. 
 
 Please see <HBDataContext> for more information.
 
 @see HBDataContext
 @since v1.0
 */
@property (readonly, retain, nonatomic) HBDataContext* data;

/** 
 helper positional parameters
 
 Handlebars helpers can be called with parameters within templates:
    
    {{render param1 param2 name1=param3 name2=param4}}
 
 The parameters accessor on HBHelperCallingInfo lets helpers developper access the first set of ordered and unamed parameters (param1 and param2 in our example) as an array.
 
 @since v1.0
 */
@property (readonly, retain, nonatomic) NSArray* positionalParameters;

/**
 named parameters 
 
 Handlebars helpers can be called with parameters within templates:
 
 {{render param1 param2 name1=param3 name2=param4}}
 
 The namedParameters accessor on HBHelperCallingInfo lets helpers developper access the set of named parameters (param3 and param4 in our example) as a dictionary where keys are parameter names and values are parameters value.

 @since v1.0
 */
@property (readonly, retain, nonatomic) NSDictionary* namedParameters;

/**
 block invocation kind
 
 Handlebars supports expression helpers and block helpers. Some helpers can be called as block helpers or as expression helper. This property lets helpers know how they are invoked.
 
 @since v1.1.0
 */
@property (readonly, assign, nonatomic) HBHelperInvocationKind invocationKind;

/**
 block statements (block helpers only)
 
 Block helpers (see [Handlebars.js documentation](http://handlebarsjs.com/block_helpers.html)) are helpers than can invoke the passed block with a new context. 
 For instance: 
 
    {{#each a}}
        {{value}} is a prime number.
    {{/each}}

 and the following context:
 
    {a : [ {value: 1}, {value: 3}, {value: 5}, {value: 7} ]} as
 
 will render as:

    1 is a prime number. 3 is a prime number. 5 is a prime number. 7 is a prime number.
 
 In this case, the "each" helper will iterate over the array parameter and will call the passed block (ie "{{value}} is a prime number.") with each array element as the new context. 
 
 The statements accessor on HBHelperCallingInfo is the way helpers implementers render the passed block. 
 
 For example the following helper implementation:
 
    ^(HBHelperCallingInfo* callInfo) {
        return callInfo.statements(@{ @"value" : "one" }, callInfo.data);
    }
 
 Will evaluate the passed block with context { value: "one"} (in json notation).
 
 And if we register this helper in the runtime as "valueOne", the following Handlebars template
 
    {{#valueOne}} Value is {{value}} {{/valueOne}} 
 
 will evaluate to "Value is one"
 
 @since v1.0
 */
@property (readonly, copy, nonatomic) HBStatementsEvaluator statements;

/** 
 inverse block statements (block helpers only)
 
 Block helpers can have inverse sections (see [Handlebars.js documentation](http://handlebarsjs.com/block_helpers.html)). Helpers implementation can evaluate the inverse section by using the inverseStatement property. See <statements> for a discussion on how to evaluate statements.
 
 @see statements
 @since v1.0
 */
@property (readonly, copy, nonatomic) HBStatementsEvaluator inverseStatements;

/** 
 template being evaluated when helper is invoked
 
 @return the template being evaluated
 @since v1.1
 */
@property (readonly, retain, nonatomic) HBTemplate* template;
    
/** @name Accessing calling parameters using Objective-C subscripting notation */

/**
 Access positional parameters
 
 Positional parameters can be accessed using objective-C indexed subscripting API. 
 For instance, 
 
    callInfo[1] 
 
 will return the value of calling parameter at index 1
 
 Accessing a non-existing index will return nil without raising any exception.
 
 @param index index of parameter to read
 @return the parameter value (can be nil)
 @since v1.0
 */
- (id) objectAtIndexedSubscript:(NSUInteger)index;

// Named parameters can be accessed using keyed subscript API

/**
 Access named parameters
 
 Named parameters can be accessed using objective-C keyed subscripting API. 
 For instance 
 
    callInfo[@"lang"]
 
 will return the value of calling parameter named "lang". 
 
 Accessing a non-existing parameter will return nil without raising any exception.
 
 @param key the name of the parameter to read
 @return the parameter value (can be nil)
 @since v1.0
 */
- (id)objectForKeyedSubscript:(id)key;

@end
