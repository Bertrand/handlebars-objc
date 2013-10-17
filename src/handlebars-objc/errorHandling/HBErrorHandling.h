//
//  HBErrorHandling.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/14/13.
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


extern NSString* HBErrorDomain;


/** 
    Error codes used in handlebars-obc
 */
typedef NS_ENUM(NSInteger, HBErrorCode) {
    /** used when a parse error occurs */
    HBErrorCodeGenericParseError    = 0,
    /** used when a helper referenced in a template doesn't exist */
    HBErrorCodeHelperMissingError   = 100,
    /** used when a partial references in a template doesn't exist */
    HBErrorCodePartialMissingError  = 200
};

/**
 HBParseError errors can be generated when a template file contains errors.
 */
@interface HBParseError: NSError

/**
 line number where error can be found
 */
- (NSInteger) lineNumber;

/**
 position in buffer of error 
 */
- (NSInteger) positionInBuffer;

/** 
 string containing the buffer area around error
 */
- (NSString*) contextInBuffer;

/**
 a detailed error string returned by low-level parser.
 */
- (NSString*) lowLevelParserDescription;

@end


/** 
 HBHelperMissingError instances can be generated when a helper was invoked in a template but could not be found at runtime.
 */
@interface HBHelperMissingError: NSError

/**
 name of the missing helper
 */
- (NSString*) helperName;

@end

/**
 HBPartialMissingError instances can be generated when a partial was referenced in a template but could not be found at runtime.
 */
@interface HBPartialMissingError: NSError

/**
 name of the missing partial 
 */
- (NSString*) partialName;

@end