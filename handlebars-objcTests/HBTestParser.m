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

- (NSString*)astString:(NSString*)handlebarsString
{
    HBAstProgram* program = [HBParser astFromString:handlebarsString];
    HBAstParserTestVisitor* visitor = [[HBAstParserTestVisitor alloc] initWithRootAstNode:program];
    [program release];
    NSString* parsedString = [visitor testStringRepresentation];
    [visitor release];
    
    return parsedString;
}

- (void)testOnlyRawText
{
    XCTAssertEqualObjects([self astString:@"a string"], @"CONTENT[ 'a string' ]\n", @"parse raw text");
}

- (void)testSimpleMustaches
{
    XCTAssertEqualObjects([self astString:@"{{foo}}"], @"{{ ID:foo [] }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo:}}"], @"{{ ID:foo: [] }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo}}"], @"{{ ID:foo [] }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo?}}"], @"{{ ID:foo? [] }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo_}}"], @"{{ ID:foo_ [] }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo-}}"], @"{{ ID:foo- [] }}\n");
}

- (void)testSimpleMustachesWithData
{
    XCTAssertEqualObjects([self astString:@"{{@foo}}"], @"{{ @ID:foo [] }}\n");
}

- (void) testParsesMustachesWithPaths
{
    XCTAssertEqualObjects([self astString:@"{{foo/bar}}"], @"{{ PATH:foo/bar [] }}\n");
}

- (void) testParsesMustachesWithDashInAPath
{
    XCTAssertEqualObjects([self astString:@"{{foo-bar}}"], @"{{ ID:foo-bar [] }}\n");
}

- (void) testParsesMustachesWithParameters
{
    XCTAssertEqualObjects([self astString:@"{{foo bar}}"], @"{{ ID:foo [ID:bar] }}\n");
}

- (void) testParsesMustachesWithStringParameters
{
    XCTAssertEqualObjects([self astString:@"{{foo bar \"baz\" }}"], @"{{ ID:foo [ID:bar, \"baz\"] }}\n");
}

- (void) testParsesMustachesWithIntegerParameters
{
    XCTAssertEqualObjects([self astString:@"{{foo 1}}"], @"{{ ID:foo [INTEGER{1}] }}\n");
}

- (void) testParsesMustachesWithBooleanParameters
{
    XCTAssertEqualObjects([self astString:@"{{foo true}}"], @"{{ ID:foo [BOOLEAN{true}] }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo false}}"], @"{{ ID:foo [BOOLEAN{false}] }}\n");
}

- (void) testParsesMutachesWithDataParameters
{
    XCTAssertEqualObjects([self astString:@"{{foo @bar}}"], @"{{ ID:foo [@ID:bar] }}\n");
}

- (void) testParsesMustachesWithHashArguments
{
    XCTAssertEqualObjects([self astString:@"{{foo bar=baz}}"], @"{{ ID:foo [] HASH{bar=ID:baz} }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo bar=1}}"], @"{{ ID:foo [] HASH{bar=INTEGER{1}} }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo bar=true}}"], @"{{ ID:foo [] HASH{bar=BOOLEAN{true}} }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo bar=false}}"], @"{{ ID:foo [] HASH{bar=BOOLEAN{false}} }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo bar=@baz}}"], @"{{ ID:foo [] HASH{bar=@ID:baz} }}\n");
    
    XCTAssertEqualObjects([self astString:@"{{foo bar=baz bat=bam}}"], @"{{ ID:foo [] HASH{bar=ID:baz, bat=ID:bam} }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo bar=baz bat=\"bam\"}}"], @"{{ ID:foo [] HASH{bar=ID:baz, bat=\"bam\"} }}\n");
    
    XCTAssertEqualObjects([self astString:@"{{foo bat='bam'}}"], @"{{ ID:foo [] HASH{bat=\"bam\"} }}\n");
    
    XCTAssertEqualObjects([self astString:@"{{foo omg bar=baz bat=\"bam\"}}"], @"{{ ID:foo [ID:omg] HASH{bar=ID:baz, bat=\"bam\"} }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo omg bar=baz bat=\"bam\" baz=1}}"], @"{{ ID:foo [ID:omg] HASH{bar=ID:baz, bat=\"bam\", baz=INTEGER{1}} }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo omg bar=baz bat=\"bam\" baz=true}}"], @"{{ ID:foo [ID:omg] HASH{bar=ID:baz, bat=\"bam\", baz=BOOLEAN{true}} }}\n");
    XCTAssertEqualObjects([self astString:@"{{foo omg bar=baz bat=\"bam\" baz=false}}"], @"{{ ID:foo [ID:omg] HASH{bar=ID:baz, bat=\"bam\", baz=BOOLEAN{false}} }}\n");
}

- (void) testParsesContentsFollowedByAMustache
{
    XCTAssertEqualObjects([self astString:@"foo bar {{baz}}"], @"CONTENT[ \'foo bar \' ]\n{{ ID:baz [] }}\n");
}

- (void) testParsesAPartial
{
    XCTAssertEqualObjects([self astString:@"{{> foo }}"], @"{{> ID:foo }}\n");
}

- (void) testParsesAPartialWithContext
{
    XCTAssertEqualObjects([self astString:@"{{> foo bar}}"], @"{{> ID:foo ID:bar }}\n");
}

- (void) testParsesAPartialWithAComplexName
{
    XCTAssertEqualObjects([self astString:@"{{> shared/partial?.bar}}"], @"{{> PATH:shared/partial?.bar }}\n");
}

- (void) testParsesAComment
{
    XCTAssertEqualObjects([self astString:@"{{! this is a comment }}"], @"{{! ' this is a comment ' }}\n");
}

- (void) testParsesAMultilineComment
{
    XCTAssertEqualObjects([self astString:@"{{!\nthis is a multi-line comment\n}}"], @"{{! \'\nthis is a multi-line comment\n\' }}\n");
}

- (void) testParsesAnInverseSection
{
    XCTAssertEqualObjects([self astString:@"{{#foo}} bar {{^}} baz {{/foo}}"], @"BLOCK:\n  {{ ID:foo [] }}\n  PROGRAM:\n    CONTENT[ ' bar ' ]\n  {{^}}\n    CONTENT[ ' baz ' ]\n\n");
}

- (void) testParsesAnInverseElseStyleSection
{
    XCTAssertEqualObjects([self astString:@"{{#foo}} bar {{else}} baz {{/foo}}"], @"BLOCK:\n  {{ ID:foo [] }}\n  PROGRAM:\n    CONTENT[ ' bar ' ]\n  {{^}}\n    CONTENT[ ' baz ' ]\n\n");
}

- (void) testParsesEmptyBlocks
{
    XCTAssertEqualObjects([self astString:@"{{#foo}}{{/foo}}"], @"BLOCK:\n  {{ ID:foo [] }}\n\n");
}

- (void) testParsesEmptyBlocksWithEmptyInverseSection
{
    XCTAssertEqualObjects([self astString:@"{{#foo}}{{^}}{{/foo}}"], @"BLOCK:\n  {{ ID:foo [] }}\n\n");
}

- (void) testParsesEmptyBlocksWithEmptyInverseElseStyleSection
{
    XCTAssertEqualObjects([self astString:@"{{#foo}}{{else}}{{/foo}}"], @"BLOCK:\n  {{ ID:foo [] }}\n\n");
}

- (void) testParsesNonEmptyBlocksWithEmptyInverseSection
{
    XCTAssertEqualObjects([self astString:@"{{#foo}} bar {{^}}{{/foo}}"], @"BLOCK:\n  {{ ID:foo [] }}\n  PROGRAM:\n    CONTENT[ ' bar ' ]\n\n");
}

- (void) testParsesNonEmptyBlocksWithEmptyInverseElseStyleSection
{
    XCTAssertEqualObjects([self astString:@"{{#foo}} bar {{else}}{{/foo}}"], @"BLOCK:\n  {{ ID:foo [] }}\n  PROGRAM:\n    CONTENT[ ' bar ' ]\n\n");
}

- (void) testParsesEmptyBlocksWithNonEmptyInverseSection
{
    XCTAssertEqualObjects([self astString:@"{{#foo}}{{^}} bar {{/foo}}"], @"BLOCK:\n  {{ ID:foo [] }}\n  {{^}}\n    CONTENT[ ' bar ' ]\n\n");
}

- (void) testParsesEmptyBlocksWithNonEmptyInverseElseStyleSection
{
    XCTAssertEqualObjects([self astString:@"{{#foo}}{{else}} bar {{/foo}}"], @"BLOCK:\n  {{ ID:foo [] }}\n  {{^}}\n    CONTENT[ ' bar ' ]\n\n");
}

- (void) testParsesAStandaloneInverseSection
{
    XCTAssertEqualObjects([self astString:@"{{^foo}}bar{{/foo}}"], @"BLOCK:\n  {{ ID:foo [] }}\n  {{^}}\n    CONTENT[ 'bar' ]\n\n");
}

- (void) testParsesASingleDotInMustache
{
    XCTAssertEqualObjects([self astString:@"{{.}}"], @"{{ ID:. [] }}\n");
}

@end
