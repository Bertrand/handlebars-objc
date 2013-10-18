# Context Objects #

Context objects are the data you provide at runtime when rendering templates. 

Consider the following example: 

```
[HBHandlebars renderTemplateString:@"{{a}}" 
                       withContext:@{ @"a" : @"a simple value"} 
                             error:&error]
```

The context is an NSDictionary literal.  In most examples you'll find throughout handlebars-objc documentation, context objects are plist-compatible Foundation objects (NSDictionary, NSArray, NSString, NSNumber, etc.). 

By far, this is the simplest way to use handlebars-objc, but it's not the only one.

In many cases, you'll want context objects to be existing objects from your application, and those will not necessarily be arrays and dictionaries.  Don't panic, this is totally fine. And we'll see in a moment how to deal with this situation.

## How handlebars-objc accesses Objects properties ##

Handlebars tries several methods in order to access a property on an object in this order: 

 1. using keyed subscripting operators 
 2. using safe Key-Value Coding 

If no method succeeds, `nil` is returned. 

Let's look at each of those methods in detail. We'll start with the second one, Key-Value Coding, since this is the one you'll use most often.

### Accessing properties using safe Key-Value Coding ###

Handlebars-objc can try to access an object property using the `valueForKey:` method (See [Key-Value Coding introduction](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/Overview.html) on Apple's developer site for more details).  In short this means handlebars-objc is able to read your objects' attributes without any specific work from you. 

However, for security reasons, handlebars-objc will not run valueForKey: for just any key.

**By default, only attributes declared as Objective-C properties will be available to templates.**

The one exception to this principle is that all Core Data properties are also accessible on NSManagedObject instances. 

If this doesn't fit your needs, **you can override that behaviour** by implementing the following method on your object class: 

```objc
+ (NSArray*) validKeysForHandlebars;
```

This method should return an array listing all the keys that you want to allow access to.

### Accessing properties using subscripting operators ###

If an object responds to the following keyed subscripting operator method, then handlebars-objc will use this method to access its properties:

```objc
- (id)objectForKeyedSubscript:(id)key
```

If you haven't heard about this method, please read the [Clang documentation](http://clang.llvm.org/docs/ObjectiveCLiterals.html) about Objective-C literals.

One way to make your data objects compatible with handlebars-objc is to implement this method, and this is the way to go if you don't know up-front what properties your object may have.

For example, suppose your objects are wrappers around arbitrary XML objects you receive from the network. You don't know at implementation-time what properties your objects will respond to.  In this case, using the keyed subscripting method described above is the way to go. 

## Iterable collections ##

In many cases, Handlebars needs to know if an object should be treated as an iterable collection or not.  
This section explains why, and then explains how handlebars-objc decides if an object is an iterable collection.

### The need to identify iterable collections ###

For example, the following Handlebars template will perform different operations for both cases A and B.

```
// Handlebars template
{{#object}}{{name}}{{/object}}

// Case A
@{ @"object" : @[ @{ @"name" : @"Allan" }, 
                  @{ @"name" : @"David" } 
                ] 
 }

// Case B
@{ @"object" : @{ @"name" : @"Daniel" } 
 }
```

In case A, the object is an NSArray, and '{{#object}}' in the template means "iterate over the element of object".  
In case B, the object is an NSDictionary, and '{{#object}}' in the template means "context is now 'object'".

If handlebars-objc did not know it should iterate on NSArray objects, it would try to access the property 'name' on 'object' (an NSArray instance) and this would return nothing. 

In our example, the response is easy. An NSArray is a iterable collection, while an NSDictionary is not.  But if you provide your own objects as contexts to handlebars-objc, how does it decide which ones are collections and which ones are not? 

### How handlebars-objc decides that an object is an iterable collection ###

First rule: if an object is a subclass of NSArray, NSOrderedSet or NSSet, it is considered as an iterable collection. 

If you use your own objects as contexts, chances are you will one day want Handlebars to see some of your Classes as iterable collections. 

Second rule: 
 - if an object implements the [FastEnumeration](https://developer.apple.com/library/ios/documentation/cocoa/Reference/NSFastEnumeration_protocol/Reference/NSFastEnumeration.html) objective-C protocol 
AND
 - if an object responds to 'objectAtIndex:' or 'objectAtIndexedSubscript:'
 
Then handlebars-objc will identify it as an iterable collection. It will then use fast enumeration to iterate over its members. 


## FAQ ##

### Can I use CoreData objects as contexts? ###

Yes!

Handlebars-objc considers Core Data properties as valid for Key-Value Coding access (attributes, relationships, and fetched properties).  Since Core Data proxies to-many relationships as NSSet subclasses (if the relationship is unordered) or NSArray subclasses (if the relationship is ordered), handlebars-objc will also happily iterate over your to-many relationships. 

### Why does Handlebars limit access to some attributes that are normally accessible using Key-Value Coding? ###

Allowing arbitrary access from templates to properties of an object through Key-Value Coding is rather dangerous.

One way that Foundation tries to access an object property with Key-Value Coding is to search for a method with the same name as the property. If found, this method will be invoked and its return value will be used as the property value.  This means that any method with no argument can easily be invoked by trying to access a property with the same name using KVC.

Consider this example: 

```objc
@interface DBRecord : NSObject
- (void)deleteRecord;
@end

@implementation DBRecord
- (void)deleteRecord
{
    NSLog(@"Oooops, your record was just deleted!");
}
@end
```

If you were to add the following code in your app: 

```objc
id foo = [[DBRecord new] valueForKey:@"deleteRecord"];
```

In your console you would see: 

```
Oooops, your record was just deleted !
```


Since many applications will download templates from the network, handlebars-objc must make the assumption that **templates cannot be trusted**.  Access to properties via Key-Value Coding must thus be controled. 

Limiting access to declared Objective-C properties by default is a good tradeoff.
