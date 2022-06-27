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

typedef struct {
    UInt64 byte;
    UInt64 line;
    UInt64 codepoint;
} JSONPosition;

@class JSONParser;

@protocol JSONParserDelegate <NSObject>

- (void)parserDidStartObject:(JSONParser *)parser position:(JSONPosition)position;
- (void)parserDidEndObject:(JSONParser *)parser position:(JSONPosition)position;
- (void)parserDidStartArray:(JSONParser *)parser position:(JSONPosition)position;
- (void)parserDidEndArray:(JSONParser *)parser position:(JSONPosition)position;
- (void)parser:(JSONParser *)parser foundString:(NSString *)string position:(JSONPosition)position;
- (void)parser:(JSONParser *)parser foundNumber:(NSNumber *)number position:(JSONPosition)position;
- (void)parserFoundTrue:(JSONParser *)parser position:(JSONPosition)position;
- (void)parserFoundFalse:(JSONParser *)parser position:(JSONPosition)position;
- (void)parserFoundNull:(JSONParser *)parser position:(JSONPosition)position;

@end

@interface JSONParser : NSObject

@property (nullable, weak) id<JSONParserDelegate> delegate;

- (BOOL)parseData:(NSData *)data error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
