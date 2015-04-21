//
//  CKJSONSerialization.m
//  JSONParser
//
//  Created by Cory Kilger on 4/21/15.
//  Copyright (c) 2015 Cory Kilger. All rights reserved.
//

#import "CKJSONSerialization.h"
#import "JSONParser.h"

@interface CKJSONSerialization () <JSONParserDelegate>
//{
//    id _root;
//    NSString * _currentKey;
//    NSMutableArray * _containers;
//    NSMutableDictionary * _currentObject;
//    NSMutableArray * _currentArray;
//}

@property (assign) void * root;
@property (strong) NSString * currentKey;
@property (strong) NSMutableArray * containers;
@property (assign) CFMutableDictionaryRef currentObject;
@property (assign) CFMutableArrayRef currentArray;

@end

@implementation CKJSONSerialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _containers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    if (_root) {
        CFRelease(_root);
    }
    if (_currentObject) {
        CFRelease(_currentObject);
    }
    if (_currentArray) {
        CFRelease(_currentArray);
    }
}

+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error {
    id result = nil;
    @autoreleasepool {
        JSONParser * parser = [[JSONParser alloc] init];
        CKJSONSerialization * treeParser = [[CKJSONSerialization alloc] init];
        parser.delegate = treeParser;
        [parser parseData:data error:error];
        result = (__bridge id)(treeParser->_root);
    }
    return result;
}


#pragma mark - Parser delegate
    
- (void)parserDidStartObject:(JSONParser *)parser {
    CFMutableDictionaryRef object = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
//    id container;
    if (_currentKey && _currentObject) {
        CFDictionaryAddValue(_currentObject, (__bridge const void *)(_currentKey), object);
//        [container setObject:object forKey:_currentKey];
        _currentKey = nil;
    } else if (_currentArray) {
        CFArrayAppendValue(_currentArray, object);
//        [container addObject:object];
    } else if (_root == nil) {
        _root = object;
    }
    [_containers addObject:(__bridge id)(object)];
    _currentObject = object;
    _currentArray = nil;
}

- (void)parserDidEndObject:(JSONParser *)parser {
    [_containers removeLastObject];
    id container = [_containers lastObject];
    if ([container isKindOfClass:[NSMutableDictionary class]]) {
        _currentObject = (__bridge CFMutableDictionaryRef)(container);
        _currentArray = nil;
    } else if ([container isKindOfClass:[NSMutableArray class]]) {
        _currentObject = nil;
        _currentArray = (__bridge CFMutableArrayRef)(container);
    }
}

- (void)parserDidStartArray:(JSONParser *)parser {
    CFMutableArrayRef array = CFArrayCreateMutable(NULL, 0, NULL);
//    id container = [_containers lastObject];
    if (_currentKey && _currentObject) {
        CFDictionaryAddValue(_currentObject, (__bridge const void *)(_currentKey), array);
//        [container setObject:array forKey:_currentKey];
        _currentKey = nil;
    } else if (_currentArray) {
        CFArrayAppendValue(_currentArray, array);
//        [container addObject:array];
    } else if (_root == nil) {
        _root = array;
    }
    [_containers addObject:(__bridge id)(array)];
    _currentObject = nil;
    _currentArray = array;
}

- (void)parserDidEndArray:(JSONParser *)parser {
    [_containers removeLastObject];
    id container = [_containers lastObject];
    if ([container isKindOfClass:[NSMutableDictionary class]]) {
        _currentObject = (__bridge CFMutableDictionaryRef)(container);
        _currentArray = nil;
    } else if ([container isKindOfClass:[NSMutableArray class]]) {
        _currentObject = nil;
        _currentArray = (__bridge CFMutableArrayRef)(container);
    }
}

- (void)parser:(JSONParser *)parser foundString:(NSString *)string {
//    id container;
    if (_currentObject) {
        if (_currentKey) {
            CFDictionaryAddValue(_currentObject, (__bridge const void *)(_currentKey), (__bridge const void *)(string));
//            [container setObject:string forKey:_currentKey];
            _currentKey = nil;
        } else {
            _currentKey = string;
        }
    } else if (_currentArray) {
        CFArrayAppendValue(_currentArray, (__bridge const void *)(string));
//        [container addObject:string];
    } else {
        _root = (__bridge void *)(string);
    }
}

- (void)parser:(JSONParser *)parser foundNumber:(NSNumber *)number {
//    id container;
    if (_currentObject) {
        CFDictionaryAddValue(_currentObject, (__bridge const void *)(_currentKey), (__bridge const void *)(number));
//        [container setObject:number forKey:_currentKey];
        _currentKey = nil;
    } else if (_currentArray) {
        CFArrayAppendValue(_currentArray, (__bridge const void *)(number));
//        [container addObject:number];
    } else if (_root == nil) {
        _root = (__bridge void *)(number);
    }
}

- (void)parserFoundTrue:(JSONParser *)parser {
    //    id container;
    if (_currentObject) {
        CFDictionaryAddValue(_currentObject, (__bridge const void *)(_currentKey), (__bridge const void *)(@(YES)));
//        [container setObject:@(YES) forKey:_currentKey];
        _currentKey = nil;
    } else if (_currentArray) {
        CFArrayAppendValue(_currentArray, (__bridge const void *)(@(YES)));
//        [container addObject:@(YES)];
    } else if (_root == nil) {
        _root = (__bridge void *)(@(YES));
    }
}

- (void)parserFoundFalse:(JSONParser *)parser {
    //    id container;
    if (_currentObject) {
        CFDictionaryAddValue(_currentObject, (__bridge const void *)(_currentKey), (__bridge const void *)(@(NO)));
        //        [container setObject:@(YES) forKey:_currentKey];
        _currentKey = nil;
    } else if (_currentArray) {
        CFArrayAppendValue(_currentArray, (__bridge const void *)(@(NO)));
        //        [container addObject:@(YES)];
    } else if (_root == nil) {
        _root = (__bridge void *)(@(NO));
    }
}

- (void)parserFoundNull:(JSONParser *)parser {
    //    id container;
    if (_currentObject) {
        CFDictionaryAddValue(_currentObject, (__bridge const void *)(_currentKey), (__bridge const void *)([NSNull null]));
        //        [container setObject:@(YES) forKey:_currentKey];
        _currentKey = nil;
    } else if (_currentArray) {
        CFArrayAppendValue(_currentArray, (__bridge const void *)([NSNull null]));
        //        [container addObject:@(YES)];
    } else if (_root == nil) {
        _root = (__bridge void *)([NSNull null]);
    }
}

@end
