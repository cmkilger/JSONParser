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

void startObject(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserDidStartObject:parser];
}

void endObject(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserDidEndObject:parser];
}

void startArray(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserDidStartArray:parser];
}

void endArray(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserDidEndArray:parser];
}

void foundString(const char * string, uint64_t length, void * userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parser:parser foundString:CFBridgingRelease(CFStringCreateWithBytes(NULL, (const UInt8 *)string, (CFIndex)length, kCFStringEncodingUTF8, false))];
}

void foundNumber(double number, void * userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parser:parser foundNumber:CFBridgingRelease(CFNumberCreate(NULL, kCFNumberDoubleType, &number))];
}

void foundTrue(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserFoundTrue:parser];
}

void foundFalse(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserFoundFalse:parser];
}

void foundNull(void *userInfo) {
    JSONParser * parser = (__bridge JSONParser *)(userInfo);
    [parser->_delegate parserFoundNull:parser];
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
