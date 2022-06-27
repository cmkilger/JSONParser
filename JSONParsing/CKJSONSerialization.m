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

@property (strong) id root;
@property (strong) NSString * currentKey;
@property (strong) NSMutableArray * containers;
@property (strong) NSMutableDictionary * currentObject;
@property (strong) NSMutableArray * currentArray;

@end

@implementation CKJSONSerialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _containers = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error {
    id result = nil;
    @autoreleasepool {
        JSONParser * parser = [[JSONParser alloc] init];
        CKJSONSerialization * treeParser = [[CKJSONSerialization alloc] init];
        parser.delegate = treeParser;
        [parser parseData:data error:error];
        result = treeParser->_root;
    }
    return result;
}


#pragma mark - Parser delegate
    
- (void)parserDidStartObject:(JSONParser *)parser position:(JSONPosition)position {
    NSMutableDictionary * object = [[NSMutableDictionary alloc] init];
    if (_currentKey && _currentObject) {
        [_currentObject setObject:object forKey:_currentKey];
        _currentKey = nil;
    } else if (_currentArray) {
        [_currentArray addObject:object];
    } else if (_root == nil) {
        _root = object;
    }
    [_containers addObject:object];
    _currentObject = object;
    _currentArray = nil;
}

- (void)parserDidEndObject:(JSONParser *)parser position:(JSONPosition)position {
    [_containers removeLastObject];
    id container = [_containers lastObject];
    if ([container isKindOfClass:[NSMutableDictionary class]]) {
        _currentObject = container;
        _currentArray = nil;
    } else if ([container isKindOfClass:[NSMutableArray class]]) {
        _currentObject = nil;
        _currentArray = container;
    }
}

- (void)parserDidStartArray:(JSONParser *)parser position:(JSONPosition)position {
    NSMutableArray * array = [[NSMutableArray alloc] init];
    if (_currentKey && _currentObject) {
        [_currentObject setObject:array forKey:_currentKey];
        _currentKey = nil;
    } else if (_currentArray) {
        [_currentArray addObject:array];
    } else if (_root == nil) {
        _root = array;
    }
    [_containers addObject:array];
    _currentObject = nil;
    _currentArray = array;
}

- (void)parserDidEndArray:(JSONParser *)parser position:(JSONPosition)position {
    [_containers removeLastObject];
    id container = [_containers lastObject];
    if ([container isKindOfClass:[NSMutableDictionary class]]) {
        _currentObject = container;
        _currentArray = nil;
    } else if ([container isKindOfClass:[NSMutableArray class]]) {
        _currentObject = nil;
        _currentArray = container;
    }
}

- (void)parser:(JSONParser *)parser foundString:(NSString *)string position:(JSONPosition)position {
    if (_currentObject) {
        if (_currentKey) {
            [_currentObject setObject:string forKey:_currentKey];
            _currentKey = nil;
        } else {
            _currentKey = string;
        }
    } else if (_currentArray) {
        [_currentArray addObject:string];
    } else {
        _root = string;
    }
}

- (void)parser:(JSONParser *)parser foundNumber:(NSNumber *)number position:(JSONPosition)position {
    if (_currentObject) {
        [_currentObject setObject:number forKey:_currentKey];
        _currentKey = nil;
    } else if (_currentArray) {
        [_currentArray addObject:number];
    } else if (_root == nil) {
        _root = number;
    }
}

- (void)parserFoundTrue:(JSONParser *)parser position:(JSONPosition)position {
    if (_currentObject) {
        [_currentObject setObject:@(YES) forKey:_currentKey];
        _currentKey = nil;
    } else if (_currentArray) {
        [_currentArray addObject:@(YES)];
    } else if (_root == nil) {
        _root = @(YES);
    }
}

- (void)parserFoundFalse:(JSONParser *)parser position:(JSONPosition)position {
    if (_currentObject) {
        [_currentObject setObject:@(NO) forKey:_currentKey];
        _currentKey = nil;
    } else if (_currentArray) {
        [_currentArray addObject:@(NO)];
    } else if (_root == nil) {
        _root = @(NO);
    }
}

- (void)parserFoundNull:(JSONParser *)parser position:(JSONPosition)position {
    if (_currentObject) {
        [_currentObject setObject:[NSNull null] forKey:_currentKey];
        _currentKey = nil;
    } else if (_currentArray) {
        [_currentArray addObject:[NSNull null]];
    } else if (_root == nil) {
        _root = [NSNull null];
    }
}

@end
