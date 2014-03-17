//
//  HBTestSubexpressions.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 3/17/14.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "HBHandlebars.h"


@interface HBTestSubexpressions : XCTestCase

@end


NSString* xrenderWithHelpersReturningError(NSString* string, id context, NSDictionary* blocks, NSError** error)
{
    HBTemplate* template = [[HBTemplate alloc] initWithString:string];
    [template.helpers registerHelperBlocks:blocks];
    
    NSString* result = [template renderWithContext:context error:error];
    [template release];
    return result;
}

NSString* xrenderWithHelpers(NSString* string, id context, NSDictionary* blocks)
{
    return xrenderWithHelpersReturningError(string, context, blocks, nil);
}


@implementation HBTestSubexpressions

- (HBHelperBlock) lolStringHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        return @"LOL";
    };
}

- (HBHelperBlock) duplicateHelper
{
    return ^(HBHelperCallingInfo* callingInfo) {
        return [NSString stringWithFormat:@"%@%@", callingInfo[0], callingInfo[0]];
    };
}

#pragma mark -
#pragma mark Tests from Handlebars.js

- (void) testArgLessHelper
{
    id string = @"{{foo (bar)}}!";
    id hash = @{ };
    
    NSString* result = xrenderWithHelpers(string, hash, @{ @"foo" : [self duplicateHelper], @"bar" : [self lolStringHelper]});
    XCTAssertEqualObjects(result, @"LOLLOL!");
}

//    it("arg-less helper", function() {
//        var string   = "{{foo (bar)}}!";
//        var context  = {};
//        var helpers  = {
//        foo: function(val) {
//            return val+val;
//        },
//        bar: function() {
//            return "LOL";
//        }
//        };
//        shouldCompileTo(string, [context, helpers], "LOLLOL!");
//    });


//    
//    it("helper w args", function() {
//        var string   = '{{blog (equal a b)}}';
//        
//        var context  = { bar: "LOL" };
//        var helpers  = {
//        blog: function(val) {
//            return "val is " + val;
//        },
//        equal: function(x, y) {
//            return x === y;
//        }
//        };
//        shouldCompileTo(string, [context, helpers], "val is true");
//    });
//    
//    it("supports much nesting", function() {
//        var string   = '{{blog (equal (equal true true) true)}}';
//        
//        var context  = { bar: "LOL" };
//        var helpers  = {
//        blog: function(val) {
//            return "val is " + val;
//        },
//        equal: function(x, y) {
//            return x === y;
//        }
//        };
//        shouldCompileTo(string, [context, helpers], "val is true");
//    });
//    
//    it("provides each nested helper invocation its own options hash", function() {
//        var string = '{{equal (equal true true) true}}';
//        
//        var lastOptions = null;
//        var helpers  = {
//        equal: function(x, y, options) {
//            if (!options || options === lastOptions) {
//                throw new Error("options hash was reused");
//            }
//            lastOptions = options;
//            return x === y;
//        }
//        };
//        shouldCompileTo(string, [{}, helpers], "true");
//    });
//    
//    it("with hashes", function() {
//        var string   = '{{blog (equal (equal true true) true fun="yes")}}';
//        
//        var context  = { bar: "LOL" };
//        var helpers  = {
//        blog: function(val) {
//            return "val is " + val;
//        },
//        equal: function(x, y) {
//            return x === y;
//        }
//        };
//        shouldCompileTo(string, [context, helpers], "val is true");
//    });
//    
//    it("as hashes", function() {
//        var string   = '{{blog fun=(equal (blog fun=1) "val is 1")}}';
//        
//        var helpers  = {
//        blog: function(options) {
//            return "val is " + options.hash.fun;
//        },
//        equal: function(x, y) {
//            return x === y;
//        }
//        };
//        shouldCompileTo(string, [{}, helpers], "val is true");
//    });
//    
//    it("in string params mode,", function() {
//        var template = CompilerContext.compile('{{snog (blorg foo x=y) yeah a=b}}', {stringParams: true});
//        
//        var helpers = {
//        snog: function(a, b, options) {
//            equals(a, 'foo');
//            equals(options.types.length, 2, "string params for outer helper processed correctly");
//            equals(options.types[0], 'sexpr', "string params for outer helper processed correctly");
//            equals(options.types[1], 'ID', "string params for outer helper processed correctly");
//            return a + b;
//        },
//            
//        blorg: function(a, options) {
//            equals(options.types.length, 1, "string params for inner helper processed correctly");
//            equals(options.types[0], 'ID', "string params for inner helper processed correctly");
//            return a;
//        }
//        };
//        
//        var result = template({
//        foo: {},
//        yeah: {}
//        }, {helpers: helpers});
//        
//        equals(result, "fooyeah");
//    });
//    
//    it("as hashes in string params mode", function() {
//        
//        var template = CompilerContext.compile('{{blog fun=(bork)}}', {stringParams: true});
//        
//        var helpers  = {
//        blog: function(options) {
//            equals(options.hashTypes.fun, 'sexpr');
//            return "val is " + options.hash.fun;
//        },
//        bork: function() {
//            return "BORK";
//        }
//        };
//        
//        var result = template({}, {helpers: helpers});
//        equals(result, "val is BORK");
//    });
//    
//    it("subexpression functions on the context", function() {
//        var string   = "{{foo (bar)}}!";
//        var context  = {
//        bar: function() {
//            return "LOL";
//        }
//        };
//        var helpers  = {
//        foo: function(val) {
//            return val+val;
//        }
//        };
//        shouldCompileTo(string, [context, helpers], "LOLLOL!");
//    });
//    
//    it("subexpressions can't just be property lookups", function() {
//        var string   = "{{foo (bar)}}!";
//        var context  = {
//        bar: "LOL"
//        };
//        var helpers  = {
//        foo: function(val) {
//            return val+val;
//        }
//        };
//        shouldThrow(function() {
//            shouldCompileTo(string, [context, helpers], "LOLLOL!");
//        });
//    });

@end
