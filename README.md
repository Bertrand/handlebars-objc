[![Travis Build Status](https://api.travis-ci.org/fotonauts/handlebars-objc.png?branch=master)](https://travis-ci.org/fotonauts/handlebars-objc)

handlebars-objc
===============

handlebars-objc is a feature complete implementation of Handlebars.js v2.0 for Objective-C that is and will remain 100% compatible with the Javascript version. 


What is Handlebars?
===============================

(Please see the [main Handlebars site](http://handlebarsjs.com/) for a more thorough description of what Handlebars is).

In general, you should use handlebars if you need to generate text documents (HTML documents, for instance) and you want to maintain a clean separation between your views (the templates) and your model.

An increasingly popular option is to use Mustache for this purpose. Mustache is a very simple templating language available in most languages. 

Unfortunately, using Mustache rapidly becomes an implementation nightmare when trying to implement localization, formatting of dates, and many other basic user interface needs. 
Developers quickly find themselves adding view-specific data into their model to circumvent the limitations of their templating system. 

Handlebars is a pragmatic superset of Mustache that addresses most shortcomings of its ancestor with the addition of helpers and block helpers.

Helpers are small rendering functions provided by the hosting application that can be used in templates. 

Helpers generally help formatting raw data from your models (think iso 8601 dates), while block helpers provide support for custom iterators and conditional constructs. 

Block helpers have even been used to implement a clean cache-compatible compositional view system in Ruby on Rails at Fotonauts: the Reporter application (http://www.fotopedia.com/reporter) uses a compositional view system and is able to render its page exactly the same way server-side and client-side. It is written in Ruby, renders server-side templates within a Java front end using Handlebars.java and renders the exact same templates client-side using Handlebars.js.

All this thanks to Handlebars and a handful of very simple helpers shared between the Java and Javascript implementation. 

Handlebars implementations are available for [Javascript](http://handlebarsjs.com/), [Java](https://github.com/jknack/handlebars.java), [Ruby](https://github.com/cowboyd/handlebars.rb) (via [therubyracer](https://github.com/cowboyd/therubyracer)) and [PHP](https://github.com/XaminProject/handlebars.php). 

In short, if you're looking for a templating system with a clean view/model separation and want to render them in Objective-C and in Javascript (or Java), Handlebars is probably what you need. 

Please note that some implementations of Mustache provide extensions similar to Handlebars, and if you intend to render your templates only on a Mac or an iPhone, I strongly suggest you take a look at [GRMustache](https://github.com/groue/GRMustache). GRMustache is a fantastic library. 


Getting Started
===============

Integrate handlebars-objc into your project
-------------------------------------------

You have 3 options: 
 - [CocoaPods](https://github.com/fotonauts/handlebars-objc/blob/master/doc/Installation.md#cocoapods)
 - [Binary distribution](https://github.com/fotonauts/handlebars-objc/blob/master/doc/Installation.md#binary-distribution)
 - [Include handlebars-objc in your sources](https://github.com/fotonauts/handlebars-objc/blob/master/doc/Installation.md#include-handlebars-obj-as-a-subproject-in-xcode)

Render your first template 
--------------------------
Add this import clause to your objective-C implementation:

```objc
#import <HBHandlebars/HBHandlebars.h>
```

Then add:

```objc
NSError* error = nil;
NSString* result = [HBHandlebars renderTemplateString:@"Hello {{value}}!" 
                                          withContext:@{ @"value" : @"Bertrand"} 
                                                error:&error]; 
NSLog(@"handlebars template evaluated to : %@", result); 
```

Run your application, and in your logs you should see "Hello Bertrand!". 

Congratulations! You've just rendered your first Handlebars template. 

Going Further
-------------
If you like to read reference documentation, read the [Handlebars public API reference documentation](http://fotonauts.github.io/handlebars-objc/api_doc/).

Since handlebars-objc if fully compatible with handlebars.js, please refer to [handlebars.js documentation](http://handlebarsjs.com/) for a complete description of handlebars syntax. 

The doc folder contains some guides that will help you learn how to use handlebars-objc step by step:
 - [Introduction](https://github.com/fotonauts/handlebars-objc/blob/master/README.md): This guide
 - [Installation](https://github.com/fotonauts/handlebars-objc/blob/master/doc/Installation.md): how to install handlebars-objc in your XCode project
 - [Context Objects](https://github.com/fotonauts/handlebars-objc/blob/master/doc/ContextObjects.md): How Handlebars accesses data in your context objects
 - [Writing Helpers](https://github.com/fotonauts/handlebars-objc/blob/master/doc/WritingHelpers.md): Learn how to write your own helpers
 - [Controlling Escaping](https://github.com/fotonauts/handlebars-objc/blob/master/doc/ControllingEscaping.md): Learn how to control escaping of values within your templates
 - [Localizing String](https://github.com/fotonauts/handlebars-objc/blob/master/doc/LocalizingStrings.md): Localize strings within your templates
 
