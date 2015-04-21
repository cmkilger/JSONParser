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
    void *userInfo;
    void(*startObject)(void *userInfo);
    void(*endObject)(void *userInfo);
    void(*startArray)(void *userInfo);
    void(*endArray)(void *userInfo);
    void(*foundString)(const char * string, uint64_t length, void *userInfo);
    void(*foundNumber)(double number, void *userInfo);
    void(*foundTrue)(void *userInfo);
    void(*foundFalse)(void *userInfo);
    void(*foundNull)(void *userInfo);
} json_parser;

void parseJSON(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser, char * stringBuffer, size_t bufferSize);

#endif /* defined(__JSONParser__json_parser__) */
