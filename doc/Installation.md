# Installation #


There are 3 options to use handlebars-objc in your project.  
Let's start with the easiest one. 

## CocoaPods ##

CocoaPods is a very clever packaging system for Objective-C library and is by far the cleanest way to include external development frameworks in your Cocoa or UIKit projects. 

Please read the instructions at http://cocoapods.org to get started. 

To use handlebars-objc in your project simply add the handlebars-objc pod to your Podfile: 

```
pod "handlebars-objc, "~> 1.0.0"
```
 

## Binary distribution ##

(coming soon)

## Include handlebars-obj as a subproject in XCode##

 - copy the sources of handlebars-objc into your project directory (or best, use a git submodule)
 - add handlebars-objc.xcodeproj to your project (no need to add the whole sources to your project)

If your project targets iOS

  - modify your project build settings and add "$(TEMP_ROOT)/Headers" to your headers search path (without the quotes). 
  - add handlebars-objc-ios as a target dependency to your target
  - link against libhandlebars-objc-ios.a

If your project targets MacOS 
  
  - add handlebars-objc-osx as a target dependency to your target
  - link against handlebars-objc-osx.framework

