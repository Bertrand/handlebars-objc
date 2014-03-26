//
//  HBTestParser.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 9/29/13.
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

#import <XCTest/XCTest.h>
#import "HBAst.h"
#import "HBAstParserTestVisitor.h"
#import "HBParser.h"

extern int hb_debug;

@interface HBTestParser : XCTestCase
@end

@implementation HBTestParser

- (NSString*)astString:(NSString*)handlebarsString error:(NSError**)error
{
    NSError* parseError = nil;
    HBAstProgram* program = [HBParser astFromString:handlebarsString error:&parseError];
    if (parseError) {
        if (error) *error = parseError;
        return nil;
    }
    
    HBAstParserTestVisitor* visitor = [[HBAstParserTestVisitor alloc] initWithRootAstNode:program];
    NSString* parsedString = [visitor testStringRepresentation];
    [visitor release];
    
    return parsedString;
}

- (void) testParsingFailure
{
    NSError* error = nil;
    [self astString:@"a\na\na {{ string" error:&error];
    XCTAssert(nil != error, @"erroneus template should not generate a parsing error error");
}


// Tests from Handlebars.js

- (void)testOnlyRawText
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"a string" error:&error], @"CONTENT[ 'a string' ]\n", @"parse raw text");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void)testSimpleMustaches
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{foo}}" error:&error], @"{{ ID:foo [] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo:}}" error:&error], @"{{ ID:foo: [] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo}}" error:&error], @"{{ ID:foo [] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo?}}" error:&error], @"{{ ID:foo? [] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo_}}" error:&error], @"{{ ID:foo_ [] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo-}}" error:&error], @"{{ ID:foo- [] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void)testSimpleMustachesWithData
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{@foo}}" error:&error], @"{{ @ID:foo [] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesMustachesWithPaths
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{foo/bar}}" error:&error], @"{{ PATH:foo/bar [] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesMustachesWithDashInAPath
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{foo-bar}}" error:&error], @"{{ ID:foo-bar [] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesMustachesWithParameters
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{foo bar}}" error:&error], @"{{ ID:foo [ID:bar] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesMustachesWithStringParameters
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{foo bar \"baz\" }}" error:&error], @"{{ ID:foo [ID:bar, \"baz\"] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesMustachesWithIntegerParameters
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{foo 1}}" error:&error], @"{{ ID:foo [NUMBER{1}] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}
    
- (void) testParsesMustachesWithFloatParameters
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{foo 3.14159}}" error:&error], @"{{ ID:foo [NUMBER{3.14159}] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesMustachesWithBooleanParameters
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{foo true}}" error:&error], @"{{ ID:foo [BOOLEAN{true}] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo false}}" error:&error], @"{{ ID:foo [BOOLEAN{false}] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesMutachesWithDataParameters
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{foo @bar}}" error:&error], @"{{ ID:foo [@ID:bar] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesMustachesWithHashArguments
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{foo bar=baz}}" error:&error], @"{{ ID:foo [] HASH{bar=ID:baz} }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo bar=1}}" error:&error], @"{{ ID:foo [] HASH{bar=NUMBER{1}} }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo bar=true}}" error:&error], @"{{ ID:foo [] HASH{bar=BOOLEAN{true}} }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo bar=false}}" error:&error], @"{{ ID:foo [] HASH{bar=BOOLEAN{false}} }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo bar=@baz}}" error:&error], @"{{ ID:foo [] HASH{bar=@ID:baz} }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([self astString:@"{{foo bar=baz bat=bam}}" error:&error], @"{{ ID:foo [] HASH{bar=ID:baz, bat=ID:bam} }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo bar=baz bat=\"bam\"}}" error:&error], @"{{ ID:foo [] HASH{bar=ID:baz, bat=\"bam\"} }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([self astString:@"{{foo bat='bam'}}" error:&error], @"{{ ID:foo [] HASH{bat=\"bam\"} }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([self astString:@"{{foo omg bar=baz bat=\"bam\"}}" error:&error], @"{{ ID:foo [ID:omg] HASH{bar=ID:baz, bat=\"bam\"} }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo omg bar=baz bat=\"bam\" baz=1}}" error:&error], @"{{ ID:foo [ID:omg] HASH{bar=ID:baz, bat=\"bam\", baz=NUMBER{1}} }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo omg bar=baz bat=\"bam\" baz=true}}" error:&error], @"{{ ID:foo [ID:omg] HASH{bar=ID:baz, bat=\"bam\", baz=BOOLEAN{true}} }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    XCTAssertEqualObjects([self astString:@"{{foo omg bar=baz bat=\"bam\" baz=false}}" error:&error], @"{{ ID:foo [ID:omg] HASH{bar=ID:baz, bat=\"bam\", baz=BOOLEAN{false}} }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesContentsFollowedByAMustache
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"foo bar {{baz}}" error:&error], @"CONTENT[ \'foo bar \' ]\n{{ ID:baz [] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesAPartial
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{> foo }}" error:&error], @"{{> ID:foo }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesAPartialWithContext
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{> foo bar}}" error:&error], @"{{> ID:foo ID:bar }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesAPartialWithAComplexName
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{> shared/partial?.bar}}" error:&error], @"{{> PATH:shared/partial?.bar }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesAPartialWithContextAndNamedParameters
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{> foo bar a=b c='d'}}" error:&error], @"{{> ID:foo ID:bar  HASH{a=ID:b, c=\"d\"} }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesAComment
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{! this is a comment }}" error:&error], @"{{! ' this is a comment ' }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesAMultilineComment
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{!\nthis is a multi-line comment\n}}" error:&error], @"{{! \'\nthis is a multi-line comment\n\' }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesAnInverseSection
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{#foo}} bar {{^}} baz {{/foo}}" error:&error], @"BLOCK:\n  {{ ID:foo [] }}\n  PROGRAM:\n    CONTENT[ ' bar ' ]\n  {{^}}\n    CONTENT[ ' baz ' ]\n\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesAnInverseElseStyleSection
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{#foo}} bar {{else}} baz {{/foo}}" error:&error], @"BLOCK:\n  {{ ID:foo [] }}\n  PROGRAM:\n    CONTENT[ ' bar ' ]\n  {{^}}\n    CONTENT[ ' baz ' ]\n\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesEmptyBlocks
{
    NSError* error = nil;
   XCTAssertEqualObjects([self astString:@"{{#foo}}{{/foo}}" error:&error], @"BLOCK:\n  {{ ID:foo [] }}\n\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesEmptyBlocksWithEmptyInverseSection
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{#foo}}{{^}}{{/foo}}" error:&error], @"BLOCK:\n  {{ ID:foo [] }}\n\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesEmptyBlocksWithEmptyInverseElseStyleSection
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{#foo}}{{else}}{{/foo}}" error:&error], @"BLOCK:\n  {{ ID:foo [] }}\n\n");
}

- (void) testParsesNonEmptyBlocksWithEmptyInverseSection
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{#foo}} bar {{^}}{{/foo}}" error:&error], @"BLOCK:\n  {{ ID:foo [] }}\n  PROGRAM:\n    CONTENT[ ' bar ' ]\n\n");
}

- (void) testParsesNonEmptyBlocksWithEmptyInverseElseStyleSection
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{#foo}} bar {{else}}{{/foo}}" error:&error], @"BLOCK:\n  {{ ID:foo [] }}\n  PROGRAM:\n    CONTENT[ ' bar ' ]\n\n");
}

- (void) testParsesEmptyBlocksWithNonEmptyInverseSection
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{#foo}}{{^}} bar {{/foo}}" error:&error], @"BLOCK:\n  {{ ID:foo [] }}\n  {{^}}\n    CONTENT[ ' bar ' ]\n\n");
}

- (void) testParsesEmptyBlocksWithNonEmptyInverseElseStyleSection
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{#foo}}{{else}} bar {{/foo}}" error:&error], @"BLOCK:\n  {{ ID:foo [] }}\n  {{^}}\n    CONTENT[ ' bar ' ]\n\n");
}

- (void) testParsesAStandaloneInverseSection
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{^foo}}bar{{/foo}}" error:&error], @"BLOCK:\n  {{ ID:foo [] }}\n  {{^}}\n    CONTENT[ 'bar' ]\n\n");
}

- (void) testParsesASingleDotInMustache
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{.}}" error:&error], @"{{ ID:. [] }}\n");
}

- (void) testParsesSubexpressions
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{foo (bar param)}}" error:&error], @"{{ ID:foo [ID:bar [ID:param]] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesSubexpressionsWithMultipleBooleanParams
{
    NSError* error = nil;
    XCTAssertEqualObjects([self astString:@"{{foo (bar true true)}}" error:&error], @"{{ ID:foo [ID:bar [BOOLEAN{true}, BOOLEAN{true}]] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testParsesWhiteSpaceControlChars
{
    NSError* error = nil;
    
    XCTAssertEqualObjects([self astString:@"{{~foo}}" error:&error], @"{{~ ID:foo [] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
    
    XCTAssertEqualObjects([self astString:@"{{foo~}}" error:&error], @"{{ ID:foo [] ~}}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testSupportsEscapedEscapeCharactersAfterEscapedMustaches
{
    NSError* error = nil;
    
    XCTAssertEqualObjects([self astString:@"{{foo}} \\{{bar}} \\\\{{baz}}" error:&error], @"{{ ID:foo [] }}\nCONTENT[ ' ' ]\nCONTENT[ '{{' ]\nCONTENT[ 'bar}} ' ]\nCONTENT[ '\\' ]\n{{ ID:baz [] }}\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}

- (void) testRawBlockParsing
{
    NSError* error = nil;
    
    XCTAssertEqualObjects([self astString:@"aaa {{{{foo}}}} {{a}} {{{{/foo}}}} bbbb" error:&error], @"CONTENT[ 'aaa ' ]\nBLOCK:\n  {{ ID:foo [] }}\n  PROGRAM:\n    CONTENT[ ' {{a}} ' ]\n\nCONTENT[ ' bbbb' ]\n");
    XCTAssert(!error, @"evaluation should not generate an error");
}
@end
