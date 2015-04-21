//
//  JSONParser.m
//  JSONParser
//
//  Created by Cory Kilger on 4/20/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

#import "JSONParser.h"
#import "json_parser.h"

@implementation JSONParser

void startObject(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    id<JSONParserDelegate> delegate = parser.delegate;
    if ([delegate respondsToSelector:@selector(parserDidStartObject:)]) {
        [delegate parserDidStartObject:parser];
    }
}

void endObject(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    id<JSONParserDelegate> delegate = parser.delegate;
    if ([delegate respondsToSelector:@selector(parserDidEndObject:)]) {
        [delegate parserDidEndObject:parser];
    }
}

void startArray(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    id<JSONParserDelegate> delegate = parser.delegate;
    if ([delegate respondsToSelector:@selector(parserDidStartArray:)]) {
        [delegate parserDidStartArray:parser];
    }
}

void endArray(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    id<JSONParserDelegate> delegate = parser.delegate;
    if ([delegate respondsToSelector:@selector(parserDidEndArray:)]) {
        [delegate parserDidEndArray:parser];
    }
}

void foundString(const char * string, uint64_t length, void * userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    id<JSONParserDelegate> delegate = parser.delegate;
    if ([delegate respondsToSelector:@selector(parser:foundString:)]) {
        [delegate parser:parser foundString:[[NSString alloc] initWithUTF8String:string]];
    }
}

void foundNumber(double number, void * userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    id<JSONParserDelegate> delegate = parser.delegate;
    if ([delegate respondsToSelector:@selector(parser:foundNumber:)]) {
        [delegate parser:parser foundNumber:@(number)];
    }
}

void foundTrue(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    id<JSONParserDelegate> delegate = parser.delegate;
    if ([delegate respondsToSelector:@selector(parserFoundTrue:)]) {
        [delegate parserFoundTrue:parser];
    }
}

void foundFalse(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    id<JSONParserDelegate> delegate = parser.delegate;
    if ([delegate respondsToSelector:@selector(parserFoundFalse:)]) {
        [delegate parserFoundFalse:parser];
    }
}

void foundNull(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    id<JSONParserDelegate> delegate = parser.delegate;
    if ([delegate respondsToSelector:@selector(parserFoundNull:)]) {
        [delegate parserFoundNull:parser];
    }
}

- (void)parseData:(NSData *)data {
    json_parser parser;
    parser.userInfo = (__bridge void *)(self);
    parser.startObject = startObject;
    parser.endObject = endObject;
    parser.startArray = startArray;
    parser.endArray = endArray;
    parser.foundString = foundString;
    parser.foundNumber = foundNumber;
    parser.foundTrue = foundTrue;
    parser.foundFalse = foundFalse;
    parser.foundNull = foundNull;
    
    uint8_t error;
    uint64_t length;
    size_t size = data.length;
    char * buffer = malloc(size);
    parseJSON(data.bytes, &length, &error, &parser, buffer, size);
    free(buffer);
}

@end
