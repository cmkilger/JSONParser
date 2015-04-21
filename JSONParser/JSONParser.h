//
//  JSONParser.h
//  JSONParser
//
//  Created by Cory Kilger on 4/20/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSONParser;

@protocol JSONParserDelegate <NSObject>

@optional
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

@property (weak) id<JSONParserDelegate> delegate;

- (void)parseData:(NSData *)data;

@end
