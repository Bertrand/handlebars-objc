# Release Notes #

## v1.1 ##

##### Handlebars.js 2.0 compatibility #####
 - @index, @first and @last data in #each helper
 - Subexpressions in helpers using parenthesized sub helpers invocation
 - Whitespace control in tags via {{~ ... ~}}
 - Raw block helpers via {{{{ ... }}}}
 - Access to upper-level data contexts via @../
 - Hash parameters in partial tag
 - Access to root context via @root data 
 - Decimal litterals 
 - includeZero in #if and #unless helpers controls the boolean value of 0
 
##### Handlebars.objc specifics #####
 - Support for custom escaping modes 
 - Support for string localization
 - Travis CI support 
 - [#4](https://github.com/fotonauts/handlebars-objc/pull/4) Fix a memory leak ([@randomsequence](https://github.com/randomsequence)) 
 
## v1.0.1 ##

 - Fix public headers in OS X framework
 - Fix installation documentation (including project sources) 


## v1.0.0 ##

 - Initial release
 
