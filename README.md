handlebars-objc
===============

handlebars-objc is a complete implementation of Handlebars.js for Objective-C that aim at being 100% compatible with the original Javascript version. 


What is Handlebars?
===============================

(Please see the [main Handlebars site](http://handlebarsjs.com/) for a more thorough description of what Handlebars is).

In general, you should use handlebars if you need to generate text documents (HTML documents, for instance) and you want to maintain a clean separation between your views (the templates) and your model.

An increasingly popular option is to use Mustache for this purpose. Mustache is a very simple templating language available in most languages. 

Unfortunately, using Mustache rapidly becomes an implementation nightmare when trying to implement localization, formating of dates and many other basic User Interface needs. 
Developper quickly find themselves adding view-specific data into their model to circumvent the limitations of their templating system. 

Handlebars is a pragmatic superset of Mustache that addresses most shortcomings of its ancestor with the addition of helpers and block helpers.

Helpers are small rendering functions provided by the hosting application that can be used in templates. 

Helpers generally help formatting raw data from your models (think iso 8601 dates) while block helpers provide support for custom iterators and conditional constructs. 

Blocks helpers have even been used to implement a clean cache-compatible compositional view system in ruby-on-rails. 

Handlebars implementations are available for [Javascript](http://handlebarsjs.com/), [Java](https://github.com/jknack/handlebars.java) or [Ruby](https://github.com/cowboyd/handlebars.rb). 

In short, if your looking for a templating system with a clean view/model separation and want to render them in Objective-C and in Javascript (or Java), Handlebars is probably what you need. 

What handlebars-objc is not 
===========================

Handlebars-objc doesn't try to be more versatile than other Handlebars implementations. As such it doesn't try to give control over rendering to the hosting application. beyond helpers implementation. Helpers are generally simple to write and can easily be ported to other Handlebars implementation. Any other mechanism would break potential compatibility with other Handlebars implementation, and would probably increase global warming. 

Some implementations of Mustache provide extensions similar to Handlebars, and if you intend to render your templates only on a Mac or an iPhone, I strongly suggest you take a look at [GRMustache](https://github.com/groue/GRMustache]). GRMustache is a fantastic library if you're looking for more control over rendering (and more control in general). Plus, GRMustache doesn't increase global warming. 


Getting Started
===============

Integrate handlebars-objc into your project
-------------------------------------------

CocoaPods submission coming soon. 

In the meantime here's how to integrate HBHandlebars as a subproject. 

  - copy the sources of handlebars-objc into your project directory (or best, use a git submodule)
  - add handlebars-objc.xcodeproj to your project (no need to add the whole sources to your project)

Then if your project targets iOS:

  - modify your project build settings and add "$(TEMP_ROOT)/Headers" to your headers search path (without the quotes). 
  - add handlebars-objc-ios as a target dependency to your target
  - link against libhandlebars-objc-ios.a

If your project targets MacOS 
  
  - add handlebars-objc-osx as a target dependency to your target
  - link against handlebars-objc-osx.framework

Render your first template 
--------------------------
Add this import clause to your objective-C implementation 

```objc
  #import <HBHandlebars/HBHandlebars>; 
```

Then add 

```objc
  NSError* error = nil;
  NSString* result = [HBHandlebars renderTemplateString:@"Hello {{value}}!" withContext:@{ @"value" : @"Bertrand"} error:&error]; 
  NSLog(@"handlebars template evaluated to : %@", result); 
```

Run your application, and in your logs, you should see "Hello Bertrand!". 

Congratulations! You've just rendered your first Handlebars template. 

Going Further
-------------
If you like to read reference documentation, read the [public API reference documentation](http://fotonauts.github.io/handlebars-objc/api_doc/).

The doc folder contains some guides that will help you learn how to use handlebars-objc step by step:
 - [Introduction](https://github.com/fotonauts/handlebars-objc/blob/master/README.md) (This guide)
 - [Writing Helpers](https://github.com/fotonauts/handlebars-objc/blob/master/doc/WritingHelpers.md) (Work in progress)

