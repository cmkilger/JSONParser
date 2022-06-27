//
//  json_parser.h
//  JSONParser
//
//  Created by Cory Kilger on 4/20/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

#ifndef __JSONParser__json_parser__
#define __JSONParser__json_parser__

#include <ctype.h>

typedef struct {
    uint64_t byte;
    uint64_t line;
    uint64_t codepoint;
} json_position;

typedef struct {
    void *userInfo;
    void(*startObject)(json_position position, void *userInfo);
    void(*endObject)(json_position position, void *userInfo);
    void(*startArray)(json_position position, void *userInfo);
    void(*endArray)(json_position position, void *userInfo);
    void(*foundString)(const char * string, uint64_t length, json_position position, void *userInfo);
    void(*foundNumber)(double number, json_position position, void *userInfo);
    void(*foundTrue)(json_position position, void *userInfo);
    void(*foundFalse)(json_position position, void *userInfo);
    void(*foundNull)(json_position position, void *userInfo);
} json_parser;

void parseJSON(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser, char * stringBuffer, size_t bufferSize);

#endif /* defined(__JSONParser__json_parser__) */
