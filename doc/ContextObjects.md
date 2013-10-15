# Context Objects #

Context objects is the data you provide at runtime when rendering objects. 

In the following example: 

```
[HBHandlebars renderTemplateString:@"{{a}}" withContext:@{ @"a" : @"a simple value"} error:&error]
```

The context is an NSDictionary litterals. In most examples you'll find throughout handlebars-objc documentation, context objects are plist-compatible Foundation objects (NSDictionary, NSArray, NSString, NSNumber). 

By far, this is the simplest way to use handlebars-objc. But not the only one.

In many case, you'll want to use existing objects from your application as context objects. In general, those objects will not be plist-compatible objects. 
This documents details how handlebars-objc accesses data in objects. 


## Access to properties ##

Handlebars tries several methods in order when accessing a property on an object: 

 - using keyed subscripting operators 
 - using secured Key-Value Coding 

If no method succeeds, nil is returned. 

### Accessing properties using subscripting operators ###

If an object responds to the following keyed subscripting operator method: 

```objc
- (id)objectForKeyedSubscript:(id)key
```

Then handlebars-objc will use this method to access its properties. 

If you don't know what this method is, please read [Cland documentation](http://clang.llvm.org/docs/ObjectiveCLiterals.html) about Objective-C literals to find out. 

One way to make your data objects compatible with handlebars-objc is to implement this method.  
This is the way to go if you don't know up-front what properties your object may have.

Suppose your objects are wrappers around arbitrary XML objects your receive from the network. You don't know at implementation-time what properties your objects will respond to.
In this case, using the keyed subscripting method is the way to go. 

### Accessing properties using Key-Value Coding ###

If previous method did not work, handlebars-objc will try to access an object property using Key-Value Coding method valueForKey: defined on NSObject.
However, for security reasons, handlebars-objc will not call valueForKey: for any key.

By default, handlebars-objc will try valueForKey: only for declared objective-C properties on the object. 

If this doesn't fit your need, you can override that behaviour by implementing the following method on your object class: 

```objc
+ (NSArray*) validKeysForHandlebars;
```

Simply return an array listing all the keys that you want to allow access from templates and you're done.  

Why such a limitation?
Allowing arbitrary access from templates to properties of an object through Key-Value Coding is very dangerous. Here is why: 

When trying to get an object property, the runtime will in particular search for a method with the same name as the property. 
If found, this method will be invoked and its return value will be used as the property value. 

This means any method with no argument can be easily invoked from a template if no care is taken when providing property access through Key-Value Coding. 

Many applications will download templates from the network. That means handlebars-objc must make the asumption that template cannot be trusted and access to properties via Key-Value Coding must be controled. 

Limiting access to declared objective-C properties is a good tradeoff. 




