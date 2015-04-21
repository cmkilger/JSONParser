//
//  JSONParser.m
//  JSONParser
//
//  Created by Cory Kilger on 4/20/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

#import "JSONParser.h"
#import "json_parser.h"
#import <objc/runtime.h>
#import <objc/objc-class.h>

NSString * JSONParserErrorDomain = @"JSONParserErrorDomain";

typedef struct {
    void * parser;
    void * delegate;
    IMP startObject;
    IMP endObject;
    IMP startArray;
    IMP endArray;
    IMP foundString;
    IMP foundNumber;
    IMP foundTrue;
    IMP foundFalse;
    IMP foundNull;
} JSONParserDelegateImplementations;

@implementation JSONParser

void startObject(void *userInfo) {
    JSONParserDelegateImplementations * imps = (JSONParserDelegateImplementations *)userInfo;
    IMP imp = imps->startObject;
    if (imp) {
        imp((__bridge id)(imps->delegate), @selector(parserDidStartObject:), imps->parser);
    }
//    JSONParser * parser = (__bridge JSONParser *)(userInfo);
//    id<JSONParserDelegate> delegate = parser.delegate;
//    if ([delegate respondsToSelector:@selector(parserDidStartObject:)]) {
//        [delegate parserDidStartObject:parser];
//    }
}

void endObject(void *userInfo) {
    JSONParserDelegateImplementations * imps = (JSONParserDelegateImplementations *)userInfo;
    IMP imp = imps->endObject;
    if (imp) {
        imp((__bridge id)(imps->delegate), @selector(parserDidEndObject:), imps->parser);
    }
//    JSONParser * parser = (__bridge JSONParser *)(userInfo);
//    id<JSONParserDelegate> delegate = parser.delegate;
//    if ([delegate respondsToSelector:@selector(parserDidEndObject:)]) {
//        [delegate parserDidEndObject:parser];
//    }
}

void startArray(void *userInfo) {
    JSONParserDelegateImplementations * imps = (JSONParserDelegateImplementations *)userInfo;
    IMP imp = imps->startArray;
    if (imp) {
        imp((__bridge id)(imps->delegate), @selector(parserDidStartArray:), imps->parser);
    }
//    JSONParser * parser = (__bridge JSONParser *)(userInfo);
//    id<JSONParserDelegate> delegate = parser.delegate;
//    if ([delegate respondsToSelector:@selector(parserDidStartArray:)]) {
//        [delegate parserDidStartArray:parser];
//    }
}

void endArray(void *userInfo) {
    JSONParserDelegateImplementations * imps = (JSONParserDelegateImplementations *)userInfo;
    IMP imp = imps->endArray;
    if (imp) {
        imp((__bridge id)(imps->delegate), @selector(parserDidEndArray:), imps->parser);
    }
//    JSONParser * parser = (__bridge JSONParser *)(userInfo);
//    id<JSONParserDelegate> delegate = parser.delegate;
//    if ([delegate respondsToSelector:@selector(parserDidEndArray:)]) {
//        [delegate parserDidEndArray:parser];
//    }
}

void foundString(const char * string, uint64_t length, void * userInfo) {
    JSONParserDelegateImplementations * imps = (JSONParserDelegateImplementations *)userInfo;
    IMP imp = imps->foundString;
    if (imp) {
        imp((__bridge id)(imps->delegate), @selector(parser:foundString:), imps->parser, [[NSString alloc] initWithUTF8String:string]);
    }
//    JSONParser * parser = (__bridge JSONParser *)(userInfo);
//    id<JSONParserDelegate> delegate = parser.delegate;
//    if ([delegate respondsToSelector:@selector(parser:foundString:)]) {
//        [delegate parser:parser foundString:[[NSString alloc] initWithUTF8String:string]];
//    }
}

void foundNumber(double number, void * userInfo) {
    JSONParserDelegateImplementations * imps = (JSONParserDelegateImplementations *)userInfo;
    IMP imp = imps->foundNumber;
    if (imp) {
        imp((__bridge id)(imps->delegate), @selector(parser:foundNumber:), imps->parser, [[NSNumber alloc] initWithDouble:number]);
    }
//    JSONParser * parser = (__bridge JSONParser *)(userInfo);
//    id<JSONParserDelegate> delegate = parser.delegate;
//    if ([delegate respondsToSelector:@selector(parser:foundNumber:)]) {
//        [delegate parser:parser foundNumber:@(number)];
//    }
}

void foundTrue(void *userInfo) {
    JSONParserDelegateImplementations * imps = (JSONParserDelegateImplementations *)userInfo;
    IMP imp = imps->foundTrue;
    if (imp) {
        imp((__bridge id)(imps->delegate), @selector(parserFoundTrue:), imps->parser);
    }
//    JSONParser * parser = (__bridge JSONParser *)(userInfo);
//    id<JSONParserDelegate> delegate = parser.delegate;
//    if ([delegate respondsToSelector:@selector(parserFoundTrue:)]) {
//        [delegate parserFoundTrue:parser];
//    }
}

void foundFalse(void *userInfo) {
    JSONParserDelegateImplementations * imps = (JSONParserDelegateImplementations *)userInfo;
    IMP imp = imps->foundFalse;
    if (imp) {
        imp((__bridge id)(imps->delegate), @selector(parserFoundFalse:), imps->parser);
    }
//    JSONParser * parser = (__bridge JSONParser *)(userInfo);
//    id<JSONParserDelegate> delegate = parser.delegate;
//    if ([delegate respondsToSelector:@selector(parserFoundFalse:)]) {
//        [delegate parserFoundFalse:parser];
//    }
}

void foundNull(void *userInfo) {
    JSONParserDelegateImplementations * imps = (JSONParserDelegateImplementations *)userInfo;
    IMP imp = imps->foundNull;
    if (imp) {
        imp((__bridge id)(imps->delegate), @selector(parserFoundNull:), imps->parser);
    }
//    JSONParser * parser = (__bridge JSONParser *)(userInfo);
//    id<JSONParserDelegate> delegate = parser.delegate;
//    if ([delegate respondsToSelector:@selector(parserFoundNull:)]) {
//        [delegate parserFoundNull:parser];
//    }
}

- (BOOL)parseData:(NSData *)data error:(NSError **)error {
    JSONParserDelegateImplementations imps;
    imps.parser = (__bridge void *)(self);
    imps.delegate = (__bridge void *)(_delegate);
    
    Method method;
    Class delegateClass = [_delegate class];
    imps.startObject = (method = class_getInstanceMethod(delegateClass, @selector(parserDidStartObject:))) ? method_getImplementation(method) : NULL;
    imps.endObject = (method = class_getInstanceMethod(delegateClass, @selector(parserDidEndObject:))) ? method_getImplementation(method) : NULL;
    imps.startArray = (method = class_getInstanceMethod(delegateClass, @selector(parserDidStartArray:))) ? method_getImplementation(method) : NULL;
    imps.endArray = (method = class_getInstanceMethod(delegateClass, @selector(parserDidEndArray:))) ? method_getImplementation(method) : NULL;
    imps.foundString = (method = class_getInstanceMethod(delegateClass, @selector(parser:foundString:))) ? method_getImplementation(method) : NULL;
    imps.foundNumber = (method = class_getInstanceMethod(delegateClass, @selector(parser:foundNumber:))) ? method_getImplementation(method) : NULL;
    imps.foundTrue = (method = class_getInstanceMethod(delegateClass, @selector(parserFoundTrue:))) ? method_getImplementation(method) : NULL;
    imps.foundFalse = (method = class_getInstanceMethod(delegateClass, @selector(parserFoundFalse:))) ? method_getImplementation(method) : NULL;
    imps.foundNull = (method = class_getInstanceMethod(delegateClass, @selector(parserFoundNull:))) ? method_getImplementation(method) : NULL;
    
    json_parser parser;
    parser.userInfo = &imps;
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
    
    if (parseError && error) {
        NSDictionary * userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"JSON is not in the correct format", @"Error message when failing to parse JSON")};
        *error = [NSError errorWithDomain:JSONParserErrorDomain code:1000 userInfo:userInfo];
    }
    
    return parseError;
}

@end
