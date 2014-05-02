# Installation #


There are 3 options to use handlebars-objc in your project.

Let's start with the easiest one. 


## Option 1: CocoaPods ##

CocoaPods is a very clever packaging system for Objective-C libraries and is by far the cleanest way to include external development frameworks in your Cocoa or UIKit projects. 

Please read the instructions at http://cocoapods.org to get started. 

To use handlebars-objc in your project, simply add the handlebars-objc pod to your Podfile: 

```
pod 'handlebars-objc', '~> 1.0.0'
```
 

## Option 2: Binary distribution ##

Go to https://github.com/fotonauts/handlebars-objc/releases and download the latest release. Then, uncompress the zip file. The resulting folder contains:
 - an OS X framework in the osx folder
 - an iOS framework in the ios folder
 - API documentation in the api_doc folder
 - Higher level documentation in the doc folder
 
To use the framework, copy the version you need (ios or osx) into your project and add it to the frameworks your project links against.


## Option 3: Include handlebars-objc as a subproject in Xcode ##

 - copy the sources of handlebars-objc into your project directory (or best, use a git submodule)
 - add handlebars-objc.xcodeproj to your project (no need to add all of the sources to your project)

If your project targets iOS:

  - modify your project build settings and add "$(TEMP_ROOT)/Headers" to your header search path (without the quotes). 
  - add handlebars-objc-ios as a target dependency to your target
  - link against libhandlebars-objc-ios.a

If your project targets OS X:
  
  - add handlebars-objc-osx as a target dependency to your target
  - link against Handlebars.framework

