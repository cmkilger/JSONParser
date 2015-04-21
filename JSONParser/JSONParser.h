//
//  JSONParser.h
//  JSONParser
//
//  Created by Cory Kilger on 4/20/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * JSONParserErrorDomain;

@class JSONParser;

@protocol JSONParserDelegate <NSObject>

- (void)parserDidStartObject:(JSONParser *)parser;
- (void)parserDidEndObject:(JSONParser *)parser;
- (void)parserDidStartArray:(JSONParser *)parser;
- (void)parserDidEndArray:(JSONParser *)parser;
- (void)parser:(JSONParser *)parser foundString:(NSString *)string;
- (void)parser:(JSONParser *)parser foundNumber:(NSNumber *)number;
- (void)parserFoundTrue:(JSONParser *)parser;
- (void)parserFoundFalse:(JSONParser *)parser;
- (void)parserFoundNull:(JSONParser *)parser;

@end

@interface JSONParser : NSObject

@property (nullable, weak) id<JSONParserDelegate> delegate;

- (BOOL)parseData:(NSData *)data error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
