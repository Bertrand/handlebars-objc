//
//  HBHandlebarsKVCValidation.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/17/13.
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

/**
 Protocol your data classes should implement to filter what keys can be accessed by Handlebars templates.
 If you don't implement this protocol, only objective-C properties will be accessible.

*/
@protocol HBHandlebarsKVCValidation <NSObject>

/**
 List the name of the property Handlebars can access on this class via KVC
 
 Your object should implement this method to fine-tune the values handlebars can access using Key-Value Coding. 
 By default, only declared properties can be accessed by Handlebars (except for CoreData NSManagedObjects where all CoreData properties are accessible). 
 
 @return the list of accessible properties on the class
 */
+ (NSArray*) validKeysForHandlebars;
@end
