//
//  JSONParser.m
//  JSONParser
//
//  Created by Cory Kilger on 4/20/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

#import "JSONParser.h"
#import "json_parser.h"

NSString * JSONParserErrorDomain = @"JSONParserErrorDomain";

@implementation JSONParser

static inline void startObject(json_position position, void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserDidStartObject:parser position:*((JSONPosition*)&position)];
}

static inline void endObject(json_position position, void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserDidEndObject:parser position:*((JSONPosition*)&position)];
}

static inline void startArray(json_position position, void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserDidStartArray:parser position:*((JSONPosition*)&position)];
}

static inline void endArray(json_position position, void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserDidEndArray:parser position:*((JSONPosition*)&position)];
}

static inline void foundString(const char * string, uint64_t length, json_position position, void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parser:parser foundString:CFBridgingRelease(CFStringCreateWithBytes(NULL, (const UInt8 *)string, (CFIndex)length, kCFStringEncodingUTF8, false)) position:*((JSONPosition*)&position)];
}

static inline void foundNumber(double number, json_position position, void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parser:parser foundNumber:CFBridgingRelease(CFNumberCreate(NULL, kCFNumberDoubleType, &number)) position:*((JSONPosition*)&position)];
}

static inline void foundTrue(json_position position, void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserFoundTrue:parser position:*((JSONPosition*)&position)];
}

static inline void foundFalse(json_position position, void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserFoundFalse:parser position:*((JSONPosition*)&position)];
}

static inline void foundNull(json_position position, void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserFoundNull:parser position:*((JSONPosition*)&position)];
}

- (BOOL)parseData:(NSData *)data error:(NSError **)error {
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
    
    uint8_t parseError;
    uint64_t length;
    size_t size = data.length;
    char * buffer = malloc(size);
    parseJSON(data.bytes, &length, &parseError, &parser, buffer, size);
    free(buffer);
    
    if (error) {
        if (parseError && error) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"JSON is not in the correct format", @"Error message when failing to parse JSON")};
            *error = [NSError errorWithDomain:JSONParserErrorDomain code:1000 userInfo:userInfo];
        } else {
            *error = nil;
        }
    }
    
    return (parseError == 0);
}

@end
