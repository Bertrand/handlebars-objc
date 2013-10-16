//
//  HBHelperUtils.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/13/13.
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
 HBHelperUtils is a class containing methods useful when writing helpers. 
 
 */

@interface HBHelperUtils : NSObject

/**
 Escape HTML characters in a string
 
 This method escapes a string so it will display properly if used in an HTML document.
 It should be used in helpers implementation when returning a value.
 
 @param string the string to HTML-escape.
 @since v1.0
 */
+ (NSString*)escapeHTML:(NSString *)string;

/**
 Evaluate the boolean value of any object.
 
 This method evaluate any object as a @true of @false value.
 - NSNumber : return true if the corresponding value is greater than zero, false otherwise.
 - NSString : return true if the string is not empty.
 - NSArray : return true if the array is not empty.
 - otherwise : return false
 @param object the object to evaluate
 @since v1.0
 */
+ (BOOL)evaluateObjectAsBool:(id)object;

/**
 Get the NSInteger value of any object.
 
 This method evaluate any object as an integer.
 - NSNumber : the result of -[NSNumber integerValue].
 - NSString : return the length of the string.
 - NSArray : return the length of the array.
 - otherwise : return 0
 @param object the object to evaluate
 @since v1.0
 */
+ (NSInteger)evaluateObjectAsInteger:(id)object;

/** 
 Test if a value can be enumerated as an array
 
 This method tests several heuristics in order to determine if value is an array-like object. 
 An object is considered as an array-like value by handlebars-objc if it's an NSArray subclass, an NSOrderedSet subclass or an NSSet subclass or if:
 - if conforms to the [NSFastEnumeration](https://developer.apple.com/library/ios/documentation/cocoa/Reference/NSFastEnumeration_protocol/Reference/NSFastEnumeration.html) protocol
 - it responds to objectAtIndex: or to objectAtIndexedSubscript:
 
 Those object can then enumerated using NSFastEnumeration for (... in ...) constructs.
 
 If calling this method on an object returns true, then <arrayFromValue:> can be used to retrieve convert the collection to a plain NSArray.
 This is for instance very useful in helpers doing some sorting on the collection.
 
 Note: even though NSSet is not an ordered collection, it is included here because in practice enumeration of a NSSet is the only way one could want to use it in a template. 
 
 @param value the value to test
 @return true if the value is an array-like value, false otherwise.
 @see arrayFromValue:
 @since v1.0.0
 */
+ (BOOL) isEnumerableByIndex:(id)value;


/**
 Return an array containing the elements of an enumerable indexed value.
 
 This method returns an NSArray for any enumerable array-like value supported by handlebars-objc
 If the value is already an NSArray, it is directly returned. 
 
 Enumerable array-like values must conform to the NSFastEnumeration protocol and must also implement the indexed subscripting method: 
 
    - (id) objectAtIndexedSubscript:(NSUInteger)index;

 @param value enumerable indexed value
 @since v1.0
 */
+ (NSArray*) arrayFromValue:(id)value;


/**
 Test if a value can be enumerated as an dictionary
 
 This method tests several heuristics in order to determine if value is an dictionary-like object.
 An object is considered as an array-like value by handlebars-objc if:
 - if conforms to the [NSFastEnumeration](https://developer.apple.com/library/ios/documentation/cocoa/Reference/NSFastEnumeration_protocol/Reference/NSFastEnumeration.html) protocol
 - it responds to objectForKeyedSubscript:
 
 Of course, NSDictionary and its subclasses meet this two conditions.
 
 Because of this definition, those object can then be iterated on like this:
 
    if ([HBHelperUtils isEnumerableByKey:value]) {
        id<NSFastEnumeration> dictionaryLike = value;
        for (id key in dictionaryLike) {
            id prop = dictionaryLike[key];
            NSLog(@"value of key %@ is %@", key, prop);
        }
    }
 
 @param value the value to test
 @return true if the value is enumerable by key, false otherwise.
 @since v1.0.0
 */
+ (BOOL) isEnumerableByKey:(id)value;

/**
 Return the value of a dictionary-like object for a key
 
 For any object implementing the keyed subscripting method: 
    - (id)objectForKeyedSubscript:(id)key;
 
 return the result of value[key]
 
 
 @param value value supporting keyed subscripting access
 @param key the key
 @since v1.0
 */
+ (id) valueOf:(id)value forKey:(NSString*)key;

@end
