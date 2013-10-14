//
//  HBErrorHandling_Private.h
//  handlebars-objc
//
//  Created by Bertrand Guiheneuf on 10/14/13.
//  Copyright (c) 2013 Fotonauts. All rights reserved.
//



@interface HBParseError()

+ (instancetype) parseErrorWithLineNumber:(NSInteger)lineNumber positionInBuffer:(NSInteger)positionInBuffer contextInBuffer:(NSString*)context lowLevelParserDescription:(NSString*)parserError;

@end

@interface HBHelperMissingError()

+ (instancetype) HBHelperMissingErrorWithHelperName:(NSString*)helperName;

@end

@interface HBPartialMissingError()

+ (instancetype) HBPartialMissingErrorWithPartialName:(NSString*)partialName;

@end