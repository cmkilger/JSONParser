//
//  json_parser.c
//  JSONParser
//
//  Created by Cory Kilger on 4/20/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

#include "json_parser.h"
#include <tgmath.h>

uint64_t UTF8Character(const char * json, uint8_t * length_p, uint8_t * error_p);
void parseJSONObject(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser, char * stringBuffer, size_t bufferSize);
void parseJSONArray(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser, char * stringBuffer, size_t bufferSize);
void parseJSONString(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser, char * stringBuffer, size_t bufferSize);
void parseJSONTrue(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser);
void parseJSONFalse(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser);
void parseJSONNull(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser);
void parseJSONNumber(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser);

uint64_t UTF8Character(const char * json, uint8_t * length_p, uint8_t * error_p) {
    uint8_t byte = json[0];
    uint64_t character = 0;
    uint8_t length;
    
    // Determine number of bytes
    if ((byte & 0x80) == 0) {
        length = 1;
        character = byte;
    } else if ((byte & 0xe0) == 0xc0) {
        length = 2;
        character = (byte & 0x1f);
    } else if ((byte & 0xf0) == 0xe0) {
        length = 3;
        character = (byte & 0xf);
    } else if ((byte & 0xf8) == 0xf0) {
        length = 4;
        character = (byte & 0x7);
    } else if ((byte & 0xfc) == 0xf8) {
        length = 5;
        character = (byte & 0x3);
    } else if ((byte & 0xfe) == 0xfc) {
        length = 6;
        character = (byte & 0x1);
    }
    
    // Return with an error
    else if (error_p) {
        *error_p = 1;
        return -1;
    }
    
    // Extra data from additional bytes
    for (int i = 1; i < length; i++) {
        byte = json[i];
        if ((byte & 0xc0) != 0x80) {
            // Return with an error
            if (error_p) {
                *error_p = 1;
            }
            return -1;
        }
        character = (character << 6) + (byte & 0x3f);
    }
    
    // Return successfully
    if (error_p) {
        *error_p = 0;
    }
    *length_p = length;
    return character;
}

// Get next character, skipping whitespace
static inline uint64_t skipWhitespace(const char * json, uint64_t * length_p, uint8_t * error_p) {
    uint8_t error;
    uint8_t length = 0;
    unsigned char offset = 0;
    uint64_t character;
    do {
        offset += length;
        character = UTF8Character(&(json[offset]), &length, &error);
        if (error) {
            if (error_p) {
                *error_p = error;
            }
            return 0;
        }
    } while (isspace((int)character));
    if (error_p) {
        *error_p = 0;
    }
    *length_p = offset;
    return character;
}

void parseJSONObject(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser, char * stringBuffer, size_t bufferSize) {
    uint8_t error;
    uint8_t charLength;
    uint64_t length;
    uint64_t offset = 0;
    uint64_t character;
    
    // Check for {
    character = UTF8Character(json, &charLength, &error);
    offset += charLength;
    if (error || character != '{') {
        if (error_p) {
            *error_p = error;
        }
        return;
    }
    
    if (jsonParser && jsonParser->startObject) {
        jsonParser->startObject(jsonParser->userInfo);
    }
    
    // Check for end if empty
    character = skipWhitespace(&(json[offset]), &length, &error);
    offset += length;
    if (character == '}') {
        offset++;
        if (jsonParser && jsonParser->endObject) {
            jsonParser->endObject(jsonParser->userInfo);
        }
        *length_p = offset;
        return;
    }
    
    while (1) {
        
        // Get key
        parseJSONString(&(json[offset]), &length, &error, jsonParser, stringBuffer, bufferSize);
        offset += length;
        if (error) {
            if (error_p) {
                *error_p = error;
            }
            return;
        }
        
        // Get next character, skipping whitespace
        character = skipWhitespace(&(json[offset]), &length, &error);
        offset += length+1;
        
        // Get :
        if (character != ':') {
            if (error_p) {
                *error_p = error;
            }
            return;
        }
        
        // Get value
        parseJSON(&(json[offset]), &length, &error, jsonParser, stringBuffer, bufferSize);
        offset += length;
        if (error) {
            if (error_p) {
                *error_p = error;
            }
            return;
        }
        
        // Get next character, skipping whitespace
        character = skipWhitespace(&(json[offset]), &length, &error);
        offset += length+1;
        
        // Get :
        switch (character) {
            case ',': {
                // Continue loop
            } break;
                
            case '}': {
                if (jsonParser && jsonParser->endObject) {
                    jsonParser->endObject(jsonParser->userInfo);
                }
                *length_p = offset;
                return;
            } break;
                
            default: {
                if (error_p) {
                    *error_p = error;
                }
                return;
            }
        }
    }
}

void parseJSONArray(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser, char * stringBuffer, size_t bufferSize) {
    uint8_t error;
    uint8_t charLength;
    uint64_t length;
    uint64_t offset = 0;
    uint64_t character;
    
    // Check for [
    character = UTF8Character(json, &charLength, &error);
    offset += charLength;
    if (error || character != '[') {
        if (error_p) {
            *error_p = error;
        }
        return;
    }
    
    if (jsonParser && jsonParser->startArray) {
        jsonParser->startArray(jsonParser->userInfo);
    }
    
    while (1) {
        
        // Get value
        parseJSON(&(json[offset]), &length, &error, jsonParser, stringBuffer, bufferSize);
        offset += length;
        if (error) {
            if (error_p) {
                *error_p = error;
            }
            return;
        }
        
        // Get next character, skipping whitespace
        character = skipWhitespace(&(json[offset]), &length, &error);
        offset += length+1;
        
        // Get , or end
        switch (character) {
            case ',': {
                // Continue loop
            } break;
                
            case ']': {
                if (jsonParser && jsonParser->endArray) {
                    jsonParser->endArray(jsonParser->userInfo);
                }
                *length_p = offset;
                return;
            } break;
                
            default: {
                if (error_p) {
                    *error_p = error;
                }
                return;
            }
        }
    }
}

static inline uint64_t parseUTF16(const char * json, uint8_t * length_p, uint8_t * error_p) {
    char digit1, digit2, digit3, digit4;
    if ((digit1 = json[0]) && (digit2 = json[1]) && (digit3 = json[2]) && (digit4 = json[3])) {
        digit1 = (('0' <= digit1 && digit1 <= '9') ? digit1 - '0' : (('a' <= digit1 && digit1 <= 'f') ? digit1 - 'a' + 10 : (('A' <= digit1 && digit1 <= 'F') ? digit1 - 'A' + 10 : -1)));
        digit2 = (('0' <= digit2 && digit2 <= '9') ? digit2 - '0' : (('a' <= digit2 && digit2 <= 'f') ? digit2 - 'a' + 10 : (('A' <= digit2 && digit2 <= 'F') ? digit2 - 'A' + 10 : -1)));
        digit3 = (('0' <= digit3 && digit3 <= '9') ? digit3 - '0' : (('a' <= digit3 && digit3 <= 'f') ? digit3 - 'a' + 10 : (('A' <= digit3 && digit3 <= 'F') ? digit3 - 'A' + 10 : -1)));
        digit4 = (('0' <= digit4 && digit4 <= '9') ? digit4 - '0' : (('a' <= digit4 && digit4 <= 'f') ? digit4 - 'a' + 10 : (('A' <= digit4 && digit4 <= 'F') ? digit4 - 'A' + 10 : -1)));
        
        if (digit1 == -1 || digit2 == -1 || digit3 == -1 || digit4 == -1) {
            if (error_p) {
                *error_p = 1;
            }
            return 0;
        }
        
        uint64_t value1 = (digit1 << 12) + (digit2 << 8) + (digit3 << 4) + digit4;
        if (0xd800 <= value1 && value1 <= 0xdbff) {
            if (json[4] == '\\' && json[5] == 'u') {
                if ((digit1 = json[6]) && (digit2 = json[7]) && (digit3 = json[8]) && (digit4 = json[9])) {
                    digit1 = (('0' <= digit1 && digit1 <= '9') ? digit1 - '0' : (('a' <= digit1 && digit1 <= 'f') ? digit1 - 'a' + 10 : (('A' <= digit1 && digit1 <= 'F') ? digit1 - 'A' + 10 : -1)));
                    digit2 = (('0' <= digit2 && digit2 <= '9') ? digit2 - '0' : (('a' <= digit2 && digit2 <= 'f') ? digit2 - 'a' + 10 : (('A' <= digit2 && digit2 <= 'F') ? digit2 - 'A' + 10 : -1)));
                    digit3 = (('0' <= digit3 && digit3 <= '9') ? digit3 - '0' : (('a' <= digit3 && digit3 <= 'f') ? digit3 - 'a' + 10 : (('A' <= digit3 && digit3 <= 'F') ? digit3 - 'A' + 10 : -1)));
                    digit4 = (('0' <= digit4 && digit4 <= '9') ? digit4 - '0' : (('a' <= digit4 && digit4 <= 'f') ? digit4 - 'a' + 10 : (('A' <= digit4 && digit4 <= 'F') ? digit4 - 'A' + 10 : -1)));
                    if (digit1 == -1 || digit2 == -1 || digit3 == -1 || digit4 == -1) {
                        if (error_p) {
                            *error_p = 1;
                        }
                        return 0;
                    }
                    
                    uint64_t value2 = (digit1 << 12) + (digit2 << 8) + (digit3 << 4) + digit4;
                    if (0xdc00 <= value2 && value2 <= 0xdfff) {
                        value1 -= 0xd800;
                        value2 -= 0xdc00;
                        *length_p = 10;
                        return 0x10000 + (value1 << 10) + value2;
                    } else {
                        if (error_p) {
                            *error_p = 1;
                        }
                        return 0;
                    }
                } else {
                    if (error_p) {
                        *error_p = 1;
                    }
                    return 0;
                }
            } else {
                if (error_p) {
                    *error_p = 1;
                }
                return 0;
            }
        } else {
            *length_p = 4;
            return value1;
        }
    } else {
        if (error_p) {
            *error_p = 1;
        }
        return 0;
    }
}

static inline uint64_t appendCharacter(uint64_t character, char * stringBuffer, size_t bufferSize, uint64_t stringLength, uint8_t * error_p) {
    uint64_t newLength = stringLength;
    
    // One byte
    if (character < 0x80) {
        newLength = stringLength + 1;
        if (bufferSize <= newLength) {
            if (error_p) {
                *error_p = 1;
            }
            return stringLength;
        } else {
            stringBuffer[stringLength] = (char)character;
        }
    }
    
    // Two bytes
    else if (character <= 0x7ff) {
        newLength = stringLength + 2;
        if (bufferSize <= newLength) {
            if (error_p) {
                *error_p = 1;
            }
            return stringLength;
        } else {
            stringBuffer[stringLength] = (char)((character >> 6) + 0xc0);
            stringBuffer[stringLength+1] = (char)((character & 0x3f) + 0x80);
        }
    }
    
    // Three bytes
    else if (character <= 0xffff) {
        newLength = stringLength + 3;
        if (bufferSize <= newLength) {
            if (error_p) {
                *error_p = 1;
            }
            return stringLength;
        } else {
            stringBuffer[stringLength] = (char)((character >> 12) + 0xe0);
            stringBuffer[stringLength+1] = (char)(((character >> 6) & 0x3f) + 0x80);
            stringBuffer[stringLength+2] = (char)((character & 0x3f) + 0x80);
        }
    }
    
    // Four bytes
    else if (character <= 0x1fffff) {
        newLength = stringLength + 4;
        if (bufferSize <= newLength) {
            if (error_p) {
                *error_p = 1;
            }
            return stringLength;
        } else {
            stringBuffer[stringLength] = (char)((character >> 18) + 0xf0);
            stringBuffer[stringLength+1] = (char)(((character >> 12) & 0x3f) + 0x80);
            stringBuffer[stringLength+2] = (char)(((character >> 6) & 0x3f) + 0x80);
            stringBuffer[stringLength+3] = (char)((character & 0x3f) + 0x80);
        }
    }
    
    // Five bytes
    else if (character <= 0x3ffffff) {
        newLength = stringLength + 4;
        if (bufferSize <= newLength) {
            if (error_p) {
                *error_p = 1;
            }
            return stringLength;
        } else {
            stringBuffer[stringLength] = (char)((character >> 24) + 0xf8);
            stringBuffer[stringLength+1] = (char)(((character >> 18) & 0x3f) + 0x80);
            stringBuffer[stringLength+2] = (char)(((character >> 12) & 0x3f) + 0x80);
            stringBuffer[stringLength+2] = (char)(((character >> 6) & 0x3f) + 0x80);
            stringBuffer[stringLength+4] = (char)((character & 0x3f) + 0x80);
        }
    }
    
    // Six bytes
    else if (character <= 0x7fffffff) {
        newLength = stringLength + 4;
        if (bufferSize <= newLength) {
            if (error_p) {
                *error_p = 1;
            }
            return stringLength;
        } else {
            stringBuffer[stringLength] = (char)((character >> 30) + 0xfc);
            stringBuffer[stringLength+1] = (char)(((character >> 24) & 0x3f) + 0x80);
            stringBuffer[stringLength+2] = (char)(((character >> 18) & 0x3f) + 0x80);
            stringBuffer[stringLength+2] = (char)(((character >> 12) & 0x3f) + 0x80);
            stringBuffer[stringLength+2] = (char)(((character >> 6) & 0x3f) + 0x80);
            stringBuffer[stringLength+5] = (char)((character & 0x3f) + 0x80);
        }
    }
    
    // Error
    else {
        if (error_p) {
            *error_p = 1;
        }
    }
    
    // Return
    return newLength;
}

void parseJSONString(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser, char * stringBuffer, size_t bufferSize) {
    uint8_t error;
    uint8_t length;
    uint64_t character;
    uint64_t offset = 0;
    
    // Check for "
    uint64_t spaceLength;
    character = skipWhitespace(json, &spaceLength, &error);
    offset = spaceLength+1;
    if (error || character != '"') {
        if (error_p) {
            *error_p = error;
        }
        return;
    }
    
    uint64_t stringLength = 0;
    while (1) {
        character = UTF8Character(&(json[offset]), &length, &error);
        offset += length;
        if (error) {
            if (error_p) {
                *error_p = error;
            }
            return;
        }
        
        if (character == '\\') {
            character = UTF8Character(&(json[offset]), &length, &error);
            offset += length;
            if (error) {
                if (error_p) {
                    *error_p = error;
                }
                return;
            }
            switch (character) {
                case '"': {
                    character = '"';
                } break;
                    
                case '\\': {
                    character = '\\';
                } break;
                    
                case '/': {
                    character = '/';
                } break;
                    
                case 'b': {
                    character = '\b';
                } break;
                    
                case 'f': {
                    character = '\f';
                } break;
                    
                case 'n': {
                    character = '\n';
                } break;
                    
                case 'r': {
                    character = '\r';
                } break;
                    
                case 't': {
                    character = '\t';
                } break;
                    
                case 'u': {
                    character = parseUTF16(&(json[offset]), &length, &error);
                    offset += length;
                } break;
                    
                default:
                    break;
            }
        } else if (character == '"') {
            stringBuffer[stringLength] = 0;
            if (jsonParser && jsonParser->foundString) {
                jsonParser->foundString(stringBuffer, stringLength, jsonParser->userInfo);
            }
            if (error_p) {
                *error_p = 0;
            }
            *length_p = offset;
            return;
        }
        
        // Append character to buffer
        stringLength = appendCharacter(character, stringBuffer, bufferSize, stringLength, &error);
        if (error) {
            if (error_p) {
                *error_p = error;
            }
            return;
        }
    }
}

void parseJSONTrue(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser) {
    uint8_t error;
    uint64_t length;
    skipWhitespace(json, &length, &error);
    if (!error && json[0+length] == 't' && json[1+length] == 'r' && json[2+length] == 'u' && json[3+length] == 'e') {
        *length_p = 4+length;
        if (jsonParser && jsonParser->foundTrue) {
            jsonParser->foundTrue(jsonParser->userInfo);
        }
    } else if (error_p) {
        *error_p = 1;
    }
}

void parseJSONFalse(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser) {
    uint8_t error;
    uint64_t length;
    skipWhitespace(json, &length, &error);
    if (!error && json[0+length] == 'f' && json[1+length] == 'a' && json[2+length] == 'l' && json[3+length] == 's' && json[4+length] == 'e') {
        *length_p = 5+length;
        if (jsonParser && jsonParser->foundFalse) {
            jsonParser->foundFalse(jsonParser->userInfo);
        }
    } else if (error_p) {
        *error_p = 1;
    }
}

void parseJSONNull(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser) {
    uint8_t error;
    uint64_t length;
    skipWhitespace(json, &length, &error);
    if (!error && json[0+length] == 'n' && json[1+length] == 'u' && json[2+length] == 'l' && json[3+length] == 'l') {
        *length_p = 4+length;
        if (jsonParser && jsonParser->foundNull) {
            jsonParser->foundNull(jsonParser->userInfo);
        }
    } else if (error_p) {
        *error_p = 1;
    }
}

void parseJSONNumber(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser) {
    uint8_t error;
    uint8_t length;
    uint64_t character;
    uint64_t offset;
    
    double value = 0;
    
    uint64_t spaceLength;
    character = skipWhitespace(json, &spaceLength, &error);
    offset = spaceLength;
    
    uint8_t isNegative = 0;
    if (character == '-') {
        offset++;
        isNegative = 1;
        character = UTF8Character(&(json[offset]), &length, &error);
    }
    
    if (character == '0') {
        // Do nothing
    } else if ('1' <= character && character <= '9') {
        do {
            value = (value * 10) + character - '0';
            character = UTF8Character(&(json[++offset]), &length, &error);
        } while ('0' <= character && character <= '9');
    } else {
        if (error_p) {
            *error_p = error;
        }
        return;
    }
    
    if (character == '.') {
        uint8_t percision = 1;
        character = UTF8Character(&(json[++offset]), &length, &error);
        while ('0' <= character && character <= '9') {
            value += (character - '0')/pow(10, percision++);
            character = UTF8Character(&(json[++offset]), &length, &error);
        }
    }
    
    if (character == 'e' || character == 'E') {
        uint8_t isSmall = 0;
        int exponent = 0;
        character = UTF8Character(&(json[++offset]), &length, &error);
        if (character == '+') {
            isSmall = 0;
            offset++;
        } else if (character == '-') {
            isSmall = 1;
            offset++;
        }
        
        character = UTF8Character(&(json[offset]), &length, &error);
        if ('0' <= character && character <= '9') {
            exponent = (int)(character - '0');
        } else {
            if (error_p) {
                *error_p = error;
            }
            return;
        }
        
        character = UTF8Character(&(json[++offset]), &length, &error);
        while ('0' <= character && character <= '9') {
            exponent = (exponent * 10) + (int)(character - '0');
            character = UTF8Character(&(json[++offset]), &length, &error);
        }
        if (isSmall) {
            exponent *= -1;
        }
        value *= pow(10, exponent);
    }
    
    if (isNegative) {
        value *= -1;
    }
    
    *length_p = offset;
    
    if (jsonParser && jsonParser->foundNumber) {
        jsonParser->foundNumber(value, jsonParser->userInfo);
    }
}

void parseJSON(const char * json, uint64_t * length_p, uint8_t * error_p, json_parser * jsonParser, char * stringBuffer, size_t bufferSize) {
    uint8_t error;
    uint64_t length = 0;
    uint64_t offset = 0;
    uint64_t character;
    
    // Get next character, skipping whitespace
    character = skipWhitespace(&(json[offset]), &length, &error);
    offset += length;
    length = 0;
    
    // Find any type of element
    switch (character) {
        case '{': {
            parseJSONObject(&(json[offset]), &length, &error, jsonParser, stringBuffer, bufferSize);
        } break;
            
        case '[': {
            parseJSONArray(&(json[offset]), &length, &error, jsonParser, stringBuffer, bufferSize);
        } break;
            
        case '"': {
            parseJSONString(&(json[offset]), &length, &error, jsonParser, stringBuffer, bufferSize);
        } break;
            
        case 't': {
            parseJSONTrue(&(json[offset]), &length, &error, jsonParser);
        } break;
            
        case 'f': {
            parseJSONFalse(&(json[offset]), &length, &error, jsonParser);
        } break;
            
        case 'n': {
            parseJSONNull(&(json[offset]), &length, &error, jsonParser);
        } break;
            
        default: {
            if (character == '-' || (character >= '0' && character <= '9')) {
                parseJSONNumber(&(json[offset]), &length, &error, jsonParser);
            } else if (error_p) {
                *error_p = error;
            }
        }
    }
    
    *length_p = offset + length;
    
    // Return error if any
    if (error) {
        if (error_p) {
            *error_p = error;
        }
        return;
    }
}
