//
//  JSONLineNumber.m
//  JSONParser
//
//  Created by Cory Kilger on 6/24/22.
//  Copyright © 2022 Cory Kilger. All rights reserved.
//

#import "JSONLineNumber.h"
#import "json_parser.h"

@implementation JSONLineNumber

static inline void startObject(json_position position, void *userInfo) {
    printf("start object\t%llu\t%llu\t%llu\n", position.line, position.codepoint, position.byte);
}

static inline void endObject(json_position position, void *userInfo) {
    printf("end object\t%llu\t%llu\t%llu\n", position.line, position.codepoint, position.byte);
}

static inline void startArray(json_position position, void *userInfo) {
    printf("start array\t%llu\t%llu\t%llu\n", position.line, position.codepoint, position.byte);
}

static inline void endArray(json_position position, void *userInfo) {
    printf("end array\t%llu\t%llu\t%llu\n", position.line, position.codepoint, position.byte);
}

static inline void foundString(const char * string, uint64_t length, json_position position, void *userInfo) {
    char buffer[length+1];
    memcpy(buffer, string, length);
    buffer[length] = 0;
    printf("%llu\t%llu\t%llu\t%s\n", position.line, position.codepoint, position.byte, buffer);
}

static inline void foundNumber(double number, json_position position, void *userInfo) {
    printf("number\t%llu\t%llu\t%llu\t%f\n", position.line, position.codepoint, position.byte, number);
}

static inline void foundTrue(json_position position, void *userInfo) {
    printf("true\t%llu\t%llu\t%llu\ttrue\n", position.line, position.codepoint, position.byte);
}

static inline void foundFalse(json_position position, void *userInfo) {
    printf("false\t%llu\t%llu\t%llu\tfalse\n", position.line, position.codepoint, position.byte);
}

static inline void foundNull(json_position position, void *userInfo) {
    printf("null\t%llu\t%llu\t%llu\tnull\n", position.line, position.codepoint, position.byte);
}

+ (BOOL)parseData:(NSData *)data {
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
    
    return (parseError == 0);
}

@end
