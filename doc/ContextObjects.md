# Context Objects #

Context objects are the data you provide at runtime when rendering templates. 

In the following example: 

```
[HBHandlebars renderTemplateString:@"{{a}}" withContext:@{ @"a" : @"a simple value"} error:&error]
```

The context is an NSDictionary litterals.  
In most examples you'll find throughout handlebars-objc documentation, context objects are plist-compatible Foundation objects (NSDictionary, NSArray, NSString, NSNumber). 

By far, this is the simplest way to use handlebars-objc. But it's not the only one.

In many case, you'll want context objects to be existing objects from your application, and those will not necessarily be Arrays and Dictionaries.
Don't panic, this is totally fine. And we'll see in a moment how to do it.


## How handlebars-objc accesses Objects properties ##

Handlebars tries several methods in order when accessing a property on an object: 

 1. using keyed subscripting operators 
 2. using safe Key-Value Coding 

If no method succeeds, nil is returned. 

Let's see those methods in details. We'll start with the second once since this is the one you'll use most often.

### Accessing properties using safe Key-Value Coding ###

Handlebars-objc can try to access an object property using Key-Value Coding valueForKey: (See [Key-Value Coding introduction](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/Overview.html) on Apple site for more details). 
In short this means handlebars-objc is able to read your objects' attributes without any specific work from you. 

However, for security reasons, handlebars-objc will not run valueForKey: for any key.

**By default, only attributes declared as objective-C properties will be available to templates.**

There is an exception to this principle. All CoreData properties are also accessible on NSManagedObject instances. 

If this doesn't fit your needs, **you can override that behaviour** by implementing the following method on your object class: 

```objc
+ (NSArray*) validKeysForHandlebars;
```

This method should return an array listing all the keys that you want to allow access to.

Let's see some example that will help understand what works out of the box and what doesn't. 

### Accessing properties using subscripting operators ###

If an object responds to the following keyed subscripting operator method: 

```objc
- (id)objectForKeyedSubscript:(id)key
```

Then handlebars-objc will use this method to access its properties. 

If you don't know what this method is, please read [Clang documentation](http://clang.llvm.org/docs/ObjectiveCLiterals.html) about Objective-C literals to find out. 

One way to make your data objects compatible with handlebars-objc is to implement this method.  
This is the way to go if you don't know up-front what properties your object may have.

Suppose your objects are wrappers around arbitrary XML objects your receive from the network. You don't know at implementation-time what properties your objects will respond to.
In this case, using the keyed subscripting method is the way to go. 

## Iterable collections ##

In many cases, Handlebars needs to know if an object should be treated as an iterable collection or not.  
This section explains why, and then explains how handlebars-objc decides if an object is an iterable-collection.

### The need to identify iterable collections ###

Lets take an example. The following Handlebars template: 

```
{{#object}}{{name}}{{/object}}
```

will not at all do the same operations if the context is: 

```
@{ @"object" : @[ @{ @"name" : @"Allan" }, @{ @"name" : @"David" } ] }
```

or if the context is 
```
@{ @"object" : @{ @"name" : @"Daniel" } }
```

In the first case, object is an NSArray and in this case '{{#object}}' means "iterate over the element of object".  
In the second case, object is an NSDictionary, and in this case '{{#object}}' means "context is now 'object'".

If handlebars-objc did not know it should iterate on NSArray objects, it would try to access the property 'name' on 'object' (an NSArray instance) and this would return nothing. 

In our example, the response is easy. An NSArray is a iterable collection, an NSDictionary is not. 

But if you provide your own objects as contexts to handlebars-objc, how does it decide which ones are collections and which ones are not? 

### How handlebars-objc decides that an object is an iterable collection ###

First rule: if an oject is a subclass of NSArray, NSOrderedSet or NSSet, it is considered as an iterable collection. 

If you use your own objects as contexts, chances are you will one day want Handlebars to see some of your Classes as iterable collections. 

Second rule: 
 - if an object implements the [FastEnumeration](https://developer.apple.com/library/ios/documentation/cocoa/Reference/NSFastEnumeration_protocol/Reference/NSFastEnumeration.html) objective-C protocol 
AND
 - if an object responds to 'objectAtIndex:' or 'objectAtIndexedSubscript:'
 
Then handlebars-objc will identify it as an iterable collection. It will then use fast iteration to iterate over its members. 


## FAQ ##

### Can I use CoreData objects as contexts? ###

Yes!

Handlebars-objc considers core data properties as valid for KVC access (attributes, relationships, fetched properties). 
And since CoreData proxies to-many relationships as NSSet subclasses (if relationship is unordered) or NSArray subclasses (if relationship is ordered), handlebars-objc will also happily iterate over your to-many relationships. 

### Why limiting the attributes accessible using Key-Value Coding ? ###

Allowing arbitrary access from templates to properties of an object through Key-Value Coding is rather dangerous.

When trying to get an object property using Key-Value Coding, Foundation will in particular search for a method with the same name as the property. 
If found, this method will be invoked and its return value will be used as the property value. 

This means any method with no argument can easily be invoked by trying to access a property with the same name using KVC.

Try this example: 

```objc
@interface DBRecord : NSObject
- (void)deleteRecord;
@end

@implementation DBRecord
- (void)deleteRecord
{
    NSLog(@"Oooops, your record was just deleted !");
}
@end
```

Somewhere in your app, do the following: 

```objc
id foo = [[DBRecord new] valueForKey:@"deleteRecord"];
```

And in your console your should see: 

```
Oooops, your record was just deleted !
```


Many applications will download templates from the network. That means handlebars-objc must make the asumption that **templates cannot be trusted**.  
Access to properties via Key-Value Coding must thus be controled. 

Limiting access to declared objective-C properties by default is a good tradeoff.




