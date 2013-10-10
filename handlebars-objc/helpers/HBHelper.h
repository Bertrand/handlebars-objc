//
//  HBHelper.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/2/13.
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

@class HBHelperCallingInfo;
typedef NSString* (^HBHelperBlock)(HBHelperCallingInfo* info);

#import "HBHelperCallingInfo.h"

/** 
 
 HBHelper is the class representing Handlebars helpers. Currently, the only way to implement a helper in handlebars-objc is to provide a block of type HBHelperBlock: 
 
    typedef NSString* (^HBHelperBlock)(HBHelperCallingInfo* callingInfo);

 You generally do not create HBHelper instances directly, but instead directly provide a block helper to the global execution context (see HBTemplate  (See <
 In templates, helpers can be called with parameters (see [Handlebars.js]( http://handlebarsjs.com/expressions.html )).
 Those calling parameters as well as the current context are available in the callingInfo parameter. 
 
 Please see <HBHelperCallingInfo> for more details.
 */
@class HBDataContext;

@interface HBHelper : NSObject

/** 
 block executed by helper
 */
@property (copy) HBHelperBlock block;

@end

