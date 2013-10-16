//
//  HBHandlebarsKVCValidation.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/17/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
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
