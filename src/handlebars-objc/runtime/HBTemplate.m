//
//  HBTemplate.m
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/1/13.
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

#import "HBTemplate.h"
#import "HBTemplate_Private.h"
#import "HBAst.h"
#import "HBAstEvaluationVisitor.h"
#import "HBParser.h"
#import "HBHelperRegistry.h"
#import "HBBuiltinHelpersRegistry.h"
#import "HBExecutionContext.h"
#import "HBExecutionContext_Private.h"
#import "HBPartial.h"
#import "HBPartialRegistry.h"
#import "HBAstParserPostprocessingVisitor.h"

@implementation HBTemplate

- (id) initWithString:(NSString*)string
{
    self = [super init];
    if (self) {
        self.templateString = string;
    }
    return self;
}

- (void) setTemplateString:(NSString *)templateString
{
    if (templateString != _templateString) {
        [_templateString release];
        _templateString = [templateString retain];
        self.program = nil; // this guy is invalid now. 
    }
}

- (NSString*)renderWithContext:(id)context error:(NSError**)error
{
    NSError* parseError = nil;
    [self compile:&parseError];
    
    if (parseError) {
        if (error) *error = parseError;
        return nil;
    }
    
    HBAstEvaluationVisitor* visitor = [[HBAstEvaluationVisitor alloc] initWithTemplate:self];
    NSString* renderedString = [visitor evaluateWithContext:context];
    
    if (error) *error = [[visitor.error retain] autorelease];
    [visitor release];
    
    return renderedString;
}

- (BOOL) compile:(NSError**)error
{
    if (nil == self.program) {
        self.program = [HBParser astFromString:self.templateString error:error];
        if (!*error && self.program) {
            HBAstParserPostprocessingVisitor* postProcessingVisitor = [[HBAstParserPostprocessingVisitor alloc] init];
            [postProcessingVisitor visitNode:self.program];
            [postProcessingVisitor release];
        }
    }
    return (nil != self.program);
}

#pragma mark -
#pragma mark Helpers

- (HBHelperRegistry*) helpers
{
    if (!self.templateLocalExecutionContext)
        self.templateLocalExecutionContext = [[HBExecutionContext new] autorelease];
    
    return self.templateLocalExecutionContext.helpers;
}

- (HBHelper*) helperForName:(NSString*)name
{
    HBHelper* helper = nil;
    
    helper = self.helpers[name];
    if (!helper && self.sharedExecutionContext) helper = [self.sharedExecutionContext helperForName:name];
    if (!helper) helper = [[HBExecutionContext globalExecutionContext] helperForName:name];
    if (!helper) helper = [HBBuiltinHelpersRegistry builtinRegistry][name];
    
    return helper;
}

#pragma mark -
#pragma mark Partials

- (HBPartialRegistry*) partials
{
    if (!self.templateLocalExecutionContext)
        self.templateLocalExecutionContext = [[HBExecutionContext new] autorelease];
    
    return self.templateLocalExecutionContext.partials;
}

- (HBPartial*) partialForName:(NSString*)name
{
    HBPartial* partial = nil;
    
    partial = self.partials[name];
    if (!partial && self.sharedExecutionContext) partial = [self.sharedExecutionContext partialForName:name];
    if (!partial) partial = [[HBExecutionContext globalExecutionContext] partialForName:name];
    
    return partial;
}

#pragma mark -
#pragma mark Localization of strings

- (NSString*) localizedString:(NSString*)string
{
    NSString* localizedVersion = nil;
    if (self.sharedExecutionContext) localizedVersion = [self.sharedExecutionContext localizedString:string];
    if (!localizedVersion) localizedVersion = [[HBExecutionContext globalExecutionContext] localizedString:string];
    if (!localizedVersion) localizedVersion = string;
    
    return localizedVersion;
}

#pragma mark -
#pragma mark Escaping 

- (NSString*) escapeString:(NSString*)rawString forTargetFormat:(NSString*)formatName
{
    NSString* escapedString = nil;
    
    if (self.sharedExecutionContext) escapedString = [self.sharedExecutionContext escapeString:rawString forTargetFormat:formatName];
    if (!escapedString) escapedString = [[HBExecutionContext globalExecutionContext] escapeString:rawString forTargetFormat:formatName];
    
    // well known formats
    
    // html
    if (!escapedString && (formatName == nil || [formatName isEqualToString:@"text/html"] || [formatName isEqual:@"html"])) {
        return [HBEscapingFunctions htmlEscapingFunction](rawString);
    }
    
    // url params
    if (!escapedString && ([formatName isEqual:@"urlParam"] || [formatName isEqual:@"text/x-query-parameter"])) {
        return [HBEscapingFunctions urlParameterEscapingFunction](rawString);
    }
    
    return escapedString;
}

#pragma mark -

- (void) dealloc
{
    self.templateString = nil;
    self.program = nil;
    self.templateLocalExecutionContext = nil;
    self.sharedExecutionContext = nil;

    [super dealloc];
}

@end
